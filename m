From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 06/13] batman-adv: rename batadv_recvlist_node struct to make clear it is used by vis
Date: Sat, 19 Jan 2013 21:27:52 +0800
Message-ID: <1358602079-24024-7-git-send-email-ordex@autistici.org>
References: <1358602079-24024-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:57918 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751783Ab3ASN3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jan 2013 08:29:50 -0500
In-Reply-To: <1358602079-24024-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/types.h | 2 +-
 net/batman-adv/vis.c   | 6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index d17517c..c56e0d9 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -453,7 +453,7 @@ struct batadv_vis_info_entry {
 	uint8_t  quality;	/* quality = 0 client */
 } __packed;
 
-struct batadv_recvlist_node {
+struct batadv_vis_recvlist_node {
 	struct list_head list;
 	uint8_t mac[ETH_ALEN];
 };
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index 3d42b17..2e70ec1 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -36,7 +36,7 @@ static void batadv_free_info(struct kref *ref)
 {
 	struct batadv_vis_info *info;
 	struct batadv_priv *bat_priv;
-	struct batadv_recvlist_node *entry, *tmp;
+	struct batadv_vis_recvlist_node *entry, *tmp;
 
 	info = container_of(ref, struct batadv_vis_info, refcount);
 	bat_priv = info->bat_priv;
@@ -305,7 +305,7 @@ static void batadv_send_list_del(struct batadv_vis_info *info)
 static void batadv_recv_list_add(struct batadv_priv *bat_priv,
 				 struct list_head *recv_list, const char *mac)
 {
-	struct batadv_recvlist_node *entry;
+	struct batadv_vis_recvlist_node *entry;
 
 	entry = kmalloc(sizeof(*entry), GFP_ATOMIC);
 	if (!entry)
@@ -322,7 +322,7 @@ static int batadv_recv_list_is_in(struct batadv_priv *bat_priv,
 				  const struct list_head *recv_list,
 				  const char *mac)
 {
-	const struct batadv_recvlist_node *entry;
+	const struct batadv_vis_recvlist_node *entry;
 
 	spin_lock_bh(&bat_priv->vis.list_lock);
 	list_for_each_entry(entry, recv_list, list) {
-- 
1.8.0.2
