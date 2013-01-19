From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 04/13] batman-adv: group tt type definitions together
Date: Sat, 19 Jan 2013 21:27:50 +0800
Message-ID: <1358602079-24024-5-git-send-email-ordex@autistici.org>
References: <1358602079-24024-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:57780 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751621Ab3ASN3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jan 2013 08:29:43 -0500
In-Reply-To: <1358602079-24024-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/types.h | 58 +++++++++++++++++++++++++-------------------------
 1 file changed, 29 insertions(+), 29 deletions(-)

diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index db3fb25..9a66115 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -339,35 +339,6 @@ struct batadv_socket_packet {
 	struct batadv_icmp_packet_rr icmp_packet;
 };
 
-struct batadv_tt_common_entry {
-	uint8_t addr[ETH_ALEN];
-	struct hlist_node hash_entry;
-	uint16_t flags;
-	unsigned long added_at;
-	atomic_t refcount;
-	struct rcu_head rcu;
-};
-
-struct batadv_tt_local_entry {
-	struct batadv_tt_common_entry common;
-	unsigned long last_seen;
-};
-
-struct batadv_tt_global_entry {
-	struct batadv_tt_common_entry common;
-	struct hlist_head orig_list;
-	spinlock_t list_lock;	/* protects the list */
-	unsigned long roam_at; /* time at which TT_GLOBAL_ROAM was set */
-};
-
-struct batadv_tt_orig_list_entry {
-	struct batadv_orig_node *orig_node;
-	uint8_t ttvn;
-	atomic_t refcount;
-	struct rcu_head rcu;
-	struct hlist_node list;
-};
-
 #ifdef CONFIG_BATMAN_ADV_BLA
 struct batadv_backbone_gw {
 	uint8_t orig[ETH_ALEN];
@@ -393,6 +364,35 @@ struct batadv_claim {
 };
 #endif
 
+struct batadv_tt_common_entry {
+	uint8_t addr[ETH_ALEN];
+	struct hlist_node hash_entry;
+	uint16_t flags;
+	unsigned long added_at;
+	atomic_t refcount;
+	struct rcu_head rcu;
+};
+
+struct batadv_tt_local_entry {
+	struct batadv_tt_common_entry common;
+	unsigned long last_seen;
+};
+
+struct batadv_tt_global_entry {
+	struct batadv_tt_common_entry common;
+	struct hlist_head orig_list;
+	spinlock_t list_lock;	/* protects the list */
+	unsigned long roam_at; /* time at which TT_GLOBAL_ROAM was set */
+};
+
+struct batadv_tt_orig_list_entry {
+	struct batadv_orig_node *orig_node;
+	uint8_t ttvn;
+	atomic_t refcount;
+	struct rcu_head rcu;
+	struct hlist_node list;
+};
+
 struct batadv_tt_change_node {
 	struct list_head list;
 	struct batadv_tt_change change;
-- 
1.8.0.2
