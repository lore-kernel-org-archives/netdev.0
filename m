From: Marek Lindner <lindner_marek@yahoo.de>
Subject: [PATCH 2/8] batman-adv: correct several typ0s in the comments
Date: Wed, 24 Aug 2011 15:00:32 +0200
Message-ID: <1314190838-2273-3-git-send-email-lindner_marek@yahoo.de>
References: <1314190838-2273-1-git-send-email-lindner_marek@yahoo.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm9-vm0.bullet.mail.ukl.yahoo.com ([217.146.183.240]:31456 "HELO
	nm9-vm0.bullet.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751090Ab1HXNAx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 09:00:53 -0400
In-Reply-To: <1314190838-2273-1-git-send-email-lindner_marek@yahoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>

Several typos have been corrected and some sentences have been rephrased

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/bitarray.c          |    6 +++---
 net/batman-adv/gateway_client.c    |   10 +++++-----
 net/batman-adv/hard-interface.c    |    4 ++--
 net/batman-adv/main.h              |    4 ++--
 net/batman-adv/routing.c           |   19 +++++++++----------
 net/batman-adv/send.c              |   10 +++++-----
 net/batman-adv/soft-interface.c    |    2 +-
 net/batman-adv/translation-table.c |    8 ++++----
 net/batman-adv/translation-table.h |    2 +-
 net/batman-adv/types.h             |    4 ++--
 net/batman-adv/unicast.h           |    2 +-
 net/batman-adv/vis.c               |    2 +-
 12 files changed, 36 insertions(+), 37 deletions(-)

diff --git a/net/batman-adv/bitarray.c b/net/batman-adv/bitarray.c
index c1f4bfc..0be9ff3 100644
--- a/net/batman-adv/bitarray.c
+++ b/net/batman-adv/bitarray.c
@@ -97,12 +97,12 @@ static void bit_shift(unsigned long *seq_bits, int32_t n)
 			(seq_bits[i - word_num - 1] >>
 			 (WORD_BIT_SIZE-word_offset));
 		/* and the upper part of the right half and shift it left to
-		 * it's position */
+		 * its position */
 		/* for our example that would be: word[0] = 9800 + 0076 =
 		 * 9876 */
 	}
-	/* now for our last word, i==word_num, we only have the it's "left"
-	 * half. that's the 1000 word in our example.*/
+	/* now for our last word, i==word_num, we only have its "left" half.
+	 * that's the 1000 word in our example.*/
 
 	seq_bits[i] = (seq_bits[i - word_num] << word_offset);
 
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 056180e..619fb73 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -532,14 +532,14 @@ static bool is_type_dhcprequest(struct sk_buff *skb, int header_len)
 	pkt_len -= header_len + DHCP_OPTIONS_OFFSET + 1;
 
 	/* Access the dhcp option lists. Each entry is made up by:
-	 * - octect 1: option type
-	 * - octect 2: option data len (only if type != 255 and 0)
-	 * - octect 3: option data */
+	 * - octet 1: option type
+	 * - octet 2: option data len (only if type != 255 and 0)
+	 * - octet 3: option data */
 	while (*p != 255 && !ret) {
-		/* p now points to the first octect: option type */
+		/* p now points to the first octet: option type */
 		if (*p == 53) {
 			/* type 53 is the message type option.
-			 * Jump the len octect and go to the data octect */
+			 * Jump the len octet and go to the data octet */
 			if (pkt_len < 2)
 				goto out;
 			p += 2;
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index db7aacf..0d73e1e 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -249,7 +249,7 @@ static void hardif_activate_interface(struct hard_iface *hard_iface)
 
 	/**
 	 * the first active interface becomes our primary interface or
-	 * the next active interface after the old primay interface was removed
+	 * the next active interface after the old primary interface was removed
 	 */
 	primary_if = primary_if_get_selected(bat_priv);
 	if (!primary_if)
@@ -573,7 +573,7 @@ out:
 	return NOTIFY_DONE;
 }
 
-/* receive a packet with the batman ethertype coming on a hard
+/* incoming packets with the batman ethertype received on any active hard
  * interface */
 static int batman_skb_recv(struct sk_buff *skb, struct net_device *dev,
 			   struct packet_type *ptype,
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index a6df61a..3daa9b6 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -44,7 +44,7 @@
 #define PURGE_TIMEOUT 200
 #define TT_LOCAL_TIMEOUT 3600 /* in seconds */
 #define TT_CLIENT_ROAM_TIMEOUT 600
-/* sliding packet range of received originator messages in squence numbers
+/* sliding packet range of received originator messages in sequence numbers
  * (should be a multiple of our word size) */
 #define TQ_LOCAL_WINDOW_SIZE 64
 #define TT_REQUEST_TIMEOUT 3 /* seconds we have to keep pending tt_req */
@@ -133,7 +133,7 @@ enum dbg_level {
 #include <linux/mutex.h>	/* mutex */
 #include <linux/module.h>	/* needed by all modules */
 #include <linux/netdevice.h>	/* netdevice */
-#include <linux/etherdevice.h>  /* ethernet address classifaction */
+#include <linux/etherdevice.h>  /* ethernet address classification */
 #include <linux/if_ether.h>	/* ethernet header */
 #include <linux/poll.h>		/* poll_table */
 #include <linux/kthread.h>	/* kernel threads */
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 0f32c81..ec23f9f 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -75,10 +75,9 @@ static void update_transtable(struct bat_priv *bat_priv,
 
 	/* the ttvn increased by one -> we can apply the attached changes */
 	if (ttvn - orig_ttvn == 1) {
-		/* the OGM could not contain the changes because they were too
-		 * many to fit in one frame or because they have already been
-		 * sent TT_OGM_APPEND_MAX times. In this case send a tt
-		 * request */
+		/* the OGM could not contain the changes due to their size or
+		 * because they have already been sent TT_OGM_APPEND_MAX times.
+		 * In this case send a tt request */
 		if (!tt_num_changes) {
 			full_table = false;
 			goto request_table;
@@ -87,13 +86,13 @@ static void update_transtable(struct bat_priv *bat_priv,
 		tt_update_changes(bat_priv, orig_node, tt_num_changes, ttvn,
 				  (struct tt_change *)tt_buff);
 
-		/* Even if we received the crc into the OGM, we prefer
-		 * to recompute it to spot any possible inconsistency
+		/* Even if we received the precomputed crc with the OGM, we
+		 * prefer to recompute it to spot any possible inconsistency
 		 * in the global table */
 		orig_node->tt_crc = tt_global_crc(bat_priv, orig_node);
 
 		/* The ttvn alone is not enough to guarantee consistency
-		 * because a single value could repesent different states
+		 * because a single value could represent different states
 		 * (due to the wrap around). Thus a node has to check whether
 		 * the resulting table (after applying the changes) is still
 		 * consistent or not. E.g. a node could disconnect while its
@@ -228,7 +227,7 @@ static int is_bidirectional_neigh(struct orig_node *orig_node,
 	if (!neigh_node)
 		goto out;
 
-	/* if orig_node is direct neighbour update neigh_node last_valid */
+	/* if orig_node is direct neighbor update neigh_node last_valid */
 	if (orig_node == orig_neigh_node)
 		neigh_node->last_valid = jiffies;
 
@@ -473,7 +472,7 @@ static void update_orig(struct bat_priv *bat_priv, struct orig_node *orig_node,
 	if (router && (router->tq_avg > neigh_node->tq_avg))
 		goto update_tt;
 
-	/* if the TQ is the same and the link not more symetric we
+	/* if the TQ is the same and the link not more symmetric we
 	 * won't consider it either */
 	if (router && (neigh_node->tq_avg == router->tq_avg)) {
 		orig_node_tmp = router->orig_node;
@@ -1243,7 +1242,7 @@ int recv_tt_query(struct sk_buff *skb, struct hard_iface *recv_if)
 		}
 		break;
 	case TT_RESPONSE:
-		/* packet needs to be linearised to access the TT changes */
+		/* packet needs to be linearized to access the TT changes */
 		if (skb_linearize(skb) < 0)
 			goto out;
 
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 58d1447..57ae809 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -135,7 +135,7 @@ static void send_packet_to_if(struct forw_packet *forw_packet,
 							    "Forwarding"));
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"%s %spacket (originator %pM, seqno %d, TQ %d, TTL %d,"
-			" IDF %s, hvn %d) on interface %s [%pM]\n",
+			" IDF %s, ttvn %d) on interface %s [%pM]\n",
 			fwd_str, (packet_num > 0 ? "aggregated " : ""),
 			batman_packet->orig, ntohl(batman_packet->seqno),
 			batman_packet->tq, batman_packet->ttl,
@@ -313,7 +313,7 @@ void schedule_own_packet(struct hard_iface *hard_iface)
 			prepare_packet_buffer(bat_priv, hard_iface);
 		}
 
-		/* if the changes have been sent enough times */
+		/* if the changes have been sent often enough */
 		if (!atomic_dec_not_zero(&bat_priv->tt_ogm_append_cnt))
 			reset_packet_buffer(bat_priv, hard_iface);
 	}
@@ -454,7 +454,7 @@ static void _add_bcast_packet_to_list(struct bat_priv *bat_priv,
 }
 
 /* add a broadcast packet to the queue and setup timers. broadcast packets
- * are sent multiple times to increase probability for beeing received.
+ * are sent multiple times to increase probability for being received.
  *
  * This function returns NETDEV_TX_OK on success and NETDEV_TX_BUSY on
  * errors.
@@ -612,7 +612,7 @@ void purge_outstanding_packets(struct bat_priv *bat_priv,
 				  &bat_priv->forw_bcast_list, list) {
 
 		/**
-		 * if purge_outstanding_packets() was called with an argmument
+		 * if purge_outstanding_packets() was called with an argument
 		 * we delete only packets belonging to the given interface
 		 */
 		if ((hard_iface) &&
@@ -641,7 +641,7 @@ void purge_outstanding_packets(struct bat_priv *bat_priv,
 				  &bat_priv->forw_bat_list, list) {
 
 		/**
-		 * if purge_outstanding_packets() was called with an argmument
+		 * if purge_outstanding_packets() was called with an argument
 		 * we delete only packets belonging to the given interface
 		 */
 		if ((hard_iface) &&
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 3e2f91f..6ba35a2 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -532,7 +532,7 @@ static int interface_set_mac_addr(struct net_device *dev, void *p)
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
-	/* only modify transtable if it has been initialised before */
+	/* only modify transtable if it has been initialized before */
 	if (atomic_read(&bat_priv->mesh_state) == MESH_ACTIVE) {
 		tt_local_remove(bat_priv, dev->dev_addr,
 				"mac address changed", false);
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index fb6931d..6004cd8 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -369,8 +369,8 @@ static void tt_local_set_pending(struct bat_priv *bat_priv,
 	tt_local_event(bat_priv, tt_local_entry->addr,
 		       tt_local_entry->flags | flags);
 
-	/* The local client has to be merked as "pending to be removed" but has
-	 * to be kept in the table in order to send it in an full tables
+	/* The local client has to be marked as "pending to be removed" but has
+	 * to be kept in the table in order to send it in a full table
 	 * response issued before the net ttvn increment (consistency check) */
 	tt_local_entry->flags |= TT_CLIENT_PENDING;
 }
@@ -1137,12 +1137,12 @@ static bool send_other_tt_response(struct bat_priv *bat_priv,
 	orig_ttvn = (uint8_t)atomic_read(&req_dst_orig_node->last_ttvn);
 	req_ttvn = tt_request->ttvn;
 
-	/* I have not the requested data */
+	/* I don't have the requested data */
 	if (orig_ttvn != req_ttvn ||
 	    tt_request->tt_data != req_dst_orig_node->tt_crc)
 		goto out;
 
-	/* If it has explicitly been requested the full table */
+	/* If the full table has been explicitly requested */
 	if (tt_request->flags & TT_FULL_TABLE ||
 	    !req_dst_orig_node->tt_buff)
 		full_table = true;
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
index d4122cb..e6b564d 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -49,7 +49,7 @@ uint16_t tt_local_crc(struct bat_priv *bat_priv);
 uint16_t tt_global_crc(struct bat_priv *bat_priv, struct orig_node *orig_node);
 void tt_free(struct bat_priv *bat_priv);
 int send_tt_request(struct bat_priv *bat_priv,
-		    struct orig_node *dst_orig_node, uint8_t hvn,
+		    struct orig_node *dst_orig_node, uint8_t ttvn,
 		    uint16_t tt_crc, bool full_table);
 bool send_tt_response(struct bat_priv *bat_priv,
 		      struct tt_query_packet *tt_request);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 25bd1db..bd0ced8 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -57,7 +57,7 @@ struct hard_iface {
  *	@batman_seqno_reset: time when the batman seqno window was reset
  *	@gw_flags: flags related to gateway class
  *	@flags: for now only VIS_SERVER flag
- *	@last_real_seqno: last and best known squence number
+ *	@last_real_seqno: last and best known sequence number
  *	@last_ttl: ttl of last received packet
  *	@last_bcast_seqno: last broadcast sequence number received by this host
  *
@@ -156,7 +156,7 @@ struct bat_priv {
 	atomic_t bcast_seqno;
 	atomic_t bcast_queue_left;
 	atomic_t batman_queue_left;
-	atomic_t ttvn; /* tranlation table version number */
+	atomic_t ttvn; /* translation table version number */
 	atomic_t tt_ogm_append_cnt;
 	atomic_t tt_local_changes; /* changes registered in a OGM interval */
 	/* The tt_poss_change flag is used to detect an ongoing roaming phase.
diff --git a/net/batman-adv/unicast.h b/net/batman-adv/unicast.h
index 62f54b9..8fd5535 100644
--- a/net/batman-adv/unicast.h
+++ b/net/batman-adv/unicast.h
@@ -24,7 +24,7 @@
 
 #include "packet.h"
 
-#define FRAG_TIMEOUT 10000	/* purge frag list entrys after time in ms */
+#define FRAG_TIMEOUT 10000	/* purge frag list entries after time in ms */
 #define FRAG_BUFFER_SIZE 6	/* number of list elements in buffer */
 
 int frag_reassemble_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index 8b75cc5..fb9b19f 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -131,7 +131,7 @@ static void vis_data_insert_interface(const uint8_t *interface,
 			return;
 	}
 
-	/* its a new address, add it to the list */
+	/* it's a new address, add it to the list */
 	entry = kmalloc(sizeof(*entry), GFP_ATOMIC);
 	if (!entry)
 		return;
-- 
1.7.5.3
