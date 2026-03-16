#!/bin/bash

api="https://api.aninetapi.com/api/Manga"
user_id=0
user_agent="Dart/2.19 (dart:io)"

function _get() {
    curl --request GET \
        --url "$api/$1" \
        --user-agent "$user_agent" \
        --header "content-type: application/json" \
        ${2:+--header "authorization: Bearer $token"}
}

function _post() {
    curl --request POST \
        --url "$api/$1" \
        --user-agent "$user_agent" \
        --header "content-type: application/json" \
        ${3:+--header "authorization: Bearer $token"} \
        ${2:+--data "$2"}
}

function _put() {
    curl --request PUT \
        --url "$api/$1" \
        --user-agent "$user_agent" \
        --header "content-type: application/json" \
        --header "authorization: Bearer $token" \
        ${2:+--data "$2"}
}

function _delete() {
    curl --request DELETE \
        --url "$api/$1" \
        --user-agent "$user_agent" \
        --header "content-type: application/json" \
        --header "authorization: Bearer $token"
}

# 1 - email: (string): <email>
# 2 - password: (string): <password>
function login() {
    local response=$(_post "Login" "{\"email\":\"$1\",\"password\":\"$2\"}")
    if [ -n "$(jq -r '.token' <<< "$response")" ]; then
        token=$(jq -r '.token' <<< "$response")
        user_id=$(jq -r '.userId' <<< "$response")
    fi
    echo "$response"
}

# 1 - name: (string): <name>
# 2 - email: (string): <email>
# 3 - password: (string): <password>
function register() {
    _post "Register" "{\"name\":\"$1\",\"email\":\"$2\",\"password\":\"$3\"}"
}

function get_cookies() {
    _get "GetCookies"
}

function get_update_link() {
    _get "GetUpdateLink"
}

function get_genres() {
    _get "Genre"
}

function get_avatars() {
    _get "MangaAvatars"
}

# 1 - user_id: (integer): <user_id>
function get_user_info() {
    _get "MangaUser?userId=$1"
}

# 1 - user_id: (integer): <user_id>
function get_user_latest_comments() {
    _get "UserLatestComments?userId=$1"
}

# 1 - user_id: (integer): <user_id>
function get_user_favorites() {
    _get "GetFavoriteManga?userId=$1"
}

# 1 - user_id: (integer): <user_id>
function get_user_feed() {
    _get "UserFeed?userId=$1"
}

# 1 - skip: (integer): <skip - default: 0>
# 2 - take: (integer): <take - default: 10>
function get_last_updates() {
    _get "LatestNotifications?userId=$user_id&skip=${1:-0}&take=${2:-10}"
}

# 1 - skip: (integer): <skip - default: 0>
# 2 - take: (integer): <take - default: 10>
function get_predictions() {
    _get "GetPrediction?userId=$user_id&skip=${1:-0}&take=${2:-10}"
}

# 1 - skip: (integer): <skip - default: 0>
# 2 - take: (integer): <take - default: 100>
function get_hot_mangas() {
    _get "Hot?userId=$user_id&skip=${1:-0}&take=${2:-100}"
}

# 1 - skip: (integer): <skip - default: 0>
# 2 - take: (integer): <take - default: 100>
function get_new_mangas() {
    _get "NewManga?userId=$user_id&skip=${1:-0}&take=${2:-100}"
}

# 1 - name: (string): <name>
function search_manga() {
    _get "FastSearch?name=$1"
}

# 1 - name: (string): <name>
# 2 - count: (integer): <count - default: 100>
# 3 - skip: (integer): <skip - default: 0>
function search_user_by_name() {
    _get "UserByName?name=$1&count=${2:-100}&skip=${3:-0}"
}

# 1 - manga_id: (integer): <manga_id>
function get_manga_info() {
    _get "Description?mangaId=$1"
}

# 1 - manga_id: (integer): <manga_id>
# 2 - skip: (integer): <skip - default: 0>
# 3 - take: (integer): <take - default: 100>
# 4 - sort: (string): <replies, likes - default: date>
function get_manga_comments() {
    _get "CommentsForList?mangaId=$1&skip=${2:-0}&take=${3:-100}&sort=${4:-date}"
}

# 1 - manga_id: (integer): <manga_id>
# 2 - skip: (integer): <skip - default: 0>
# 3 - take: (integer): <take - default: 10000>
# 4 - manga_provider_id: (integer): <manga_provider_id - default: 1>
function get_manga_chapters() {
    _get "GetChapters?mangaId=$1&skip=${2:-0}&take=${3:-10000}&mangaProviderId=${4:-1}"
}

# 1 - manga_id: (integer): <manga_id>
# 2 - count: (integer): <count - default: 5>
function get_similar_mangas() {
    _get "SimilarManga?Id=$1&count=${2:-5}"
}

# 1 - new_mangas: (boolean): <true, false - default: false>
# 2 - has_manga: (boolean): <true, false - default: true>
# 3 - sort: (string): <sort - default: members>
# 4 - statuses: (integer): <statuses - default: 1>
# 5 - manga_webtoon: (integer): <manga_webtoon - default: 0>
# 6 - minimum_chapters: (integer): <minimum_chapters - default: 0>
# 7 - maximum_chapters: (integer): <maximum_chapters - default: 0>
# 8 - other_user_id: (integer): <other_user_id - default: 0>
# 9 - user_id: (integer): <user_id - default: 0>
# 10 - take: (integer): <take - default: 100>
# 11 - skip: (integer): <skip - default: 0>
function get_filtered_mangas() {
    _get "FilteredList?newMangas=${1:-false}&hasManga=${2:-true}&sort=${3:-members}&statuses=${4:-1}&mangaWebtoon=${5:-0}&minChapters=${6:-0}&maxChapters=${7:-0}&otherUserId=${8:-0}&userId=${9:-0}&take=${10:-100}&skip=${11:-0}"
}

# 1 - user_id: (integer): <user_id>
function ban_user() {
    _post "BanUser?userId=$1"
}

# 1 - manga_id: (integer): <manga_id>
function add_favorite() {
    _post "AddFavorite?userId=$user_id&mangaId=$1" "" auth
}

# 1 - manga_id: (integer): <manga_id>
function remove_favorite() {
    _delete "RemoveFavorite?userId=$user_id&mangaId=$1"
}

# 1 - user_id: (integer): <user_id>
function send_friend_request() {
    _post "MangaFriend?userId=$user_id&friendId=$1" "" auth
}

# 1 - user_id: (integer): <user_id>
function remove_friend_request() {
    _delete "RemoveMangaFriend?userId=$user_id&friendId=$1"
}

# 1 - manga_id: (integer): <manga_id>
# 2 - text: (string): <text>
# 3 - is_spoiler: (boolean): <true, false - default: false>
function comment_manga() {
    _post "Comment" \
        "{\"userId\":\"$user_id\",\"mangaId\":\"$1\",\"text\":\"$2\",\"spoilers\":\"${3:-false}\"}" \
        auth
}

# 1 - comment_id: (integer): <comment_id>
# 2 - text: (string): <text>
# 3 - is_spoiler: (boolean): <true, false - default: false>
function edit_comment() {
    _put "Comment" \
        "{\"commentId\":\"$1\",\"text\":\"$2\",\"isSpoiler\":\"${3:-false}\"}"
}

# 1 - comment_id: (integer): <comment_id>
function delete_comment() {
    _delete "Comment?commentId=$1"
}

# 1 - comment_id: (integer): <comment_id>
# 2 - is_like: (boolean): <true, false - default: true>
function like_comment() {
    _post "CommentLike" \
        "{\"userId\":\"$user_id\",\"commentId\":\"$1\",\"isLike\":\"${2:-true}\"}" \
        auth
}

# 1 - username: (string): <username - default: null>
# 2 - avatar_id: (integer): <avatar_id - default: 0>
# 3 - is_hentai: (boolean): <true, false - default: null>
# 4 - is_yaoi: (boolean): <true, false - default: null>
# 5 - is_incognito: (boolean): <true, false - default: null>
function edit_profile() {
    _put "ChangeUserInfo" \
        "{\"userId\":\"$user_id\",\"userName\":${1:-null},\"avatarId\":${2:-0},\"isHentai\":${3:-null},\"isYaoi\":${4:-null},\"isIncognito\":${5:-null}}"
}
