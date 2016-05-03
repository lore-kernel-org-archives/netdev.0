From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 11/15] batman-adv: Fix function names on new line starting with '*'
Date: Wed,  4 May 2016 06:23:46 +0800
Message-ID: <1462314230-16257-12-git-send-email-a@unstable.cc>
References: <1462314230-16257-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:25886 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756436AbcECWlJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2016 18:41:09 -0400
In-Reply-To: <1462314230-16257-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Some really long function names in batman-adv require a newline between
return type and the function name. This has lead to some lines starting
with *batadv_...

This * belongs to the return type and thus should be on the same line as
the return type.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/bridge_loop_avoidance.c |  6 +++---
 net/batman-adv/main.c                  |  8 ++++----
 net/batman-adv/network-coding.c        | 18 +++++++++---------
 3 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 60d33232bd10..2c9aa671a49b 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -200,9 +200,9 @@ static void batadv_claim_put(struct batadv_bla_claim *claim)
  *
  * Return: claim if found or NULL otherwise.
  */
-static struct batadv_bla_claim
-*batadv_claim_hash_find(struct batadv_priv *bat_priv,
-			struct batadv_bla_claim *data)
+static struct batadv_bla_claim *
+batadv_claim_hash_find(struct batadv_priv *bat_priv,
+		       struct batadv_bla_claim *data)
 {
 	struct batadv_hashtable *hash = bat_priv->bla.claim_hash;
 	struct hlist_head *head;
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index d64ddb961979..78c05a91ae6f 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -663,8 +663,8 @@ static void batadv_tvlv_handler_put(struct batadv_tvlv_handler *tvlv_handler)
  *
  * Return: tvlv handler if found or NULL otherwise.
  */
-static struct batadv_tvlv_handler
-*batadv_tvlv_handler_get(struct batadv_priv *bat_priv, u8 type, u8 version)
+static struct batadv_tvlv_handler *
+batadv_tvlv_handler_get(struct batadv_priv *bat_priv, u8 type, u8 version)
 {
 	struct batadv_tvlv_handler *tvlv_handler_tmp, *tvlv_handler = NULL;
 
@@ -722,8 +722,8 @@ static void batadv_tvlv_container_put(struct batadv_tvlv_container *tvlv)
  *
  * Return: tvlv container if found or NULL otherwise.
  */
-static struct batadv_tvlv_container
-*batadv_tvlv_container_get(struct batadv_priv *bat_priv, u8 type, u8 version)
+static struct batadv_tvlv_container *
+batadv_tvlv_container_get(struct batadv_priv *bat_priv, u8 type, u8 version)
 {
 	struct batadv_tvlv_container *tvlv_tmp, *tvlv = NULL;
 
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index 0d3bf4368e9b..1da8e0e1b18f 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -793,10 +793,10 @@ static bool batadv_can_nc_with_orig(struct batadv_priv *bat_priv,
  *
  * Return: the nc_node if found, NULL otherwise.
  */
-static struct batadv_nc_node
-*batadv_nc_find_nc_node(struct batadv_orig_node *orig_node,
-			struct batadv_orig_node *orig_neigh_node,
-			bool in_coding)
+static struct batadv_nc_node *
+batadv_nc_find_nc_node(struct batadv_orig_node *orig_node,
+		       struct batadv_orig_node *orig_neigh_node,
+		       bool in_coding)
 {
 	struct batadv_nc_node *nc_node, *nc_node_out = NULL;
 	struct list_head *list;
@@ -835,11 +835,11 @@ static struct batadv_nc_node
  *
  * Return: the nc_node if found or created, NULL in case of an error.
  */
-static struct batadv_nc_node
-*batadv_nc_get_nc_node(struct batadv_priv *bat_priv,
-		       struct batadv_orig_node *orig_node,
-		       struct batadv_orig_node *orig_neigh_node,
-		       bool in_coding)
+static struct batadv_nc_node *
+batadv_nc_get_nc_node(struct batadv_priv *bat_priv,
+		      struct batadv_orig_node *orig_node,
+		      struct batadv_orig_node *orig_neigh_node,
+		      bool in_coding)
 {
 	struct batadv_nc_node *nc_node;
 	spinlock_t *lock; /* Used to lock list selected by "int in_coding" */
-- 
2.8.2
