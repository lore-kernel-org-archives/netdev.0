From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH 20/20] batman-adv: Reformat multiline
	comments to consistent style
Date: Thu, 21 Jun 2012 18:57:56 +0200
Message-ID: <1340297876-29923-21-git-send-email-ordex@autistici.org>
References: <1340297876-29923-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1340297876-29923-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>

batman-adv doesn't follow the style for multiline comments that David S. Miller
prefers. All comments should be reformatted to follow this consistent style to
make the code slightly more readable.

Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
---
 net/batman-adv/bat_algo.h              |    4 +-
 net/batman-adv/bat_debugfs.c           |    4 +-
 net/batman-adv/bat_debugfs.h           |    5 +-
 net/batman-adv/bat_iv_ogm.c            |   75 ++++++++++++++++--------------
 net/batman-adv/bat_sysfs.c             |   13 +++---
 net/batman-adv/bat_sysfs.h             |    5 +-
 net/batman-adv/bitarray.c              |   17 +++----
 net/batman-adv/bitarray.h              |   10 ++--
 net/batman-adv/bridge_loop_avoidance.c |   67 ++++++++-------------------
 net/batman-adv/bridge_loop_avoidance.h |    4 +-
 net/batman-adv/gateway_client.c        |   41 ++++++++---------
 net/batman-adv/gateway_client.h        |    4 +-
 net/batman-adv/gateway_common.c        |    9 ++--
 net/batman-adv/gateway_common.h        |    4 +-
 net/batman-adv/hard-interface.c        |   23 ++++------
 net/batman-adv/hard-interface.h        |    4 +-
 net/batman-adv/hash.c                  |    4 +-
 net/batman-adv/hash.h                  |   24 +++++-----
 net/batman-adv/icmp_socket.c           |    7 ++-
 net/batman-adv/icmp_socket.h           |    4 +-
 net/batman-adv/main.c                  |   10 ++--
 net/batman-adv/main.h                  |   38 ++++++++--------
 net/batman-adv/originator.c            |   13 +++---
 net/batman-adv/originator.h            |    9 ++--
 net/batman-adv/packet.h                |   21 +++++----
 net/batman-adv/ring_buffer.c           |    4 +-
 net/batman-adv/ring_buffer.h           |    4 +-
 net/batman-adv/routing.c               |   67 +++++++++++++++------------
 net/batman-adv/routing.h               |    4 +-
 net/batman-adv/send.c                  |   32 ++++++-------
 net/batman-adv/send.h                  |    4 +-
 net/batman-adv/soft-interface.c        |   27 +++++------
 net/batman-adv/soft-interface.h        |    4 +-
 net/batman-adv/translation-table.c     |   78 ++++++++++++++++++++------------
 net/batman-adv/translation-table.h     |    4 +-
 net/batman-adv/types.h                 |   29 ++++++------
 net/batman-adv/unicast.c               |   10 ++--
 net/batman-adv/unicast.h               |    4 +-
 net/batman-adv/vis.c                   |   39 ++++++++++------
 net/batman-adv/vis.h                   |    8 ++--
 40 files changed, 349 insertions(+), 388 deletions(-)

diff --git a/net/batman-adv/bat_algo.h b/net/batman-adv/bat_algo.h
index a14336a..a0ba3bf 100644
--- a/net/batman-adv/bat_algo.h
+++ b/net/batman-adv/bat_algo.h
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2011-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2011-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
@@ -16,7 +15,6 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
 #ifndef _NET_BATMAN_ADV_BAT_ALGO_H_
diff --git a/net/batman-adv/bat_debugfs.c b/net/batman-adv/bat_debugfs.c
index 3900624..4001c57 100644
--- a/net/batman-adv/bat_debugfs.c
+++ b/net/batman-adv/bat_debugfs.c
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2010-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2010-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
@@ -16,7 +15,6 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
 #include "main.h"
diff --git a/net/batman-adv/bat_debugfs.h b/net/batman-adv/bat_debugfs.h
index 3b206c8..eb0d576 100644
--- a/net/batman-adv/bat_debugfs.h
+++ b/net/batman-adv/bat_debugfs.h
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2010-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2010-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
@@ -16,10 +15,8 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
-
 #ifndef _NET_BATMAN_ADV_DEBUGFS_H_
 #define _NET_BATMAN_ADV_DEBUGFS_H_
 
diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 0430063..94859d4 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
@@ -16,7 +15,6 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
 #include "main.h"
@@ -170,7 +168,8 @@ static void bat_iv_ogm_send_to_if(struct forw_packet *forw_packet,
 				      batman_ogm_packet->tt_num_changes)) {
 
 		/* we might have aggregated direct link packets with an
-		 * ordinary base packet */
+		 * ordinary base packet
+		 */
 		if ((forw_packet->direct_link_flags & (1 << packet_num)) &&
 		    (forw_packet->if_incoming == hard_iface))
 			batman_ogm_packet->flags |= DIRECTLINK;
@@ -237,8 +236,9 @@ static void bat_iv_ogm_emit(struct forw_packet *forw_packet)
 	if (!primary_if)
 		goto out;
 
-	/* multihomed peer assumed */
-	/* non-primary OGMs are only broadcasted on their interface */
+	/* multihomed peer assumed
+	 * non-primary OGMs are only broadcasted on their interface
+	 */
 	if ((directlink && (batman_ogm_packet->header.ttl == 1)) ||
 	    (forw_packet->own && (forw_packet->if_incoming != primary_if))) {
 
@@ -292,41 +292,39 @@ static bool bat_iv_ogm_can_aggregate(const struct batman_ogm_packet
 
 	batman_ogm_packet = (struct batman_ogm_packet *)forw_packet->skb->data;
 
-	/**
-	 * we can aggregate the current packet to this aggregated packet
+	/* we can aggregate the current packet to this aggregated packet
 	 * if:
 	 *
 	 * - the send time is within our MAX_AGGREGATION_MS time
 	 * - the resulting packet wont be bigger than
 	 *   MAX_AGGREGATION_BYTES
 	 */
-
 	if (time_before(send_time, forw_packet->send_time) &&
 	    time_after_eq(send_time + msecs_to_jiffies(MAX_AGGREGATION_MS),
 					forw_packet->send_time) &&
 	    (aggregated_bytes <= MAX_AGGREGATION_BYTES)) {
 
-		/**
-		 * check aggregation compatibility
+		/* check aggregation compatibility
 		 * -> direct link packets are broadcasted on
 		 *    their interface only
 		 * -> aggregate packet if the current packet is
 		 *    a "global" packet as well as the base
 		 *    packet
 		 */
-
 		primary_if = primary_if_get_selected(bat_priv);
 		if (!primary_if)
 			goto out;
 
 		/* packets without direct link flag and high TTL
-		 * are flooded through the net  */
+		 * are flooded through the net
+		 */
 		if ((!directlink) &&
 		    (!(batman_ogm_packet->flags & DIRECTLINK)) &&
 		    (batman_ogm_packet->header.ttl != 1) &&
 
 		    /* own packets originating non-primary
-		     * interfaces leave only that interface */
+		     * interfaces leave only that interface
+		     */
 		    ((!forw_packet->own) ||
 		     (forw_packet->if_incoming == primary_if))) {
 			res = true;
@@ -334,14 +332,16 @@ static bool bat_iv_ogm_can_aggregate(const struct batman_ogm_packet
 		}
 
 		/* if the incoming packet is sent via this one
-		 * interface only - we still can aggregate */
+		 * interface only - we still can aggregate
+		 */
 		if ((directlink) &&
 		    (new_batman_ogm_packet->header.ttl == 1) &&
 		    (forw_packet->if_incoming == if_incoming) &&
 
 		    /* packets from direct neighbors or
 		     * own secondary interface packets
-		     * (= secondary interface packets in general) */
+		     * (= secondary interface packets in general)
+		     */
 		    (batman_ogm_packet->flags & DIRECTLINK ||
 		     (forw_packet->own &&
 		      forw_packet->if_incoming != primary_if))) {
@@ -457,8 +457,7 @@ static void bat_iv_ogm_queue_add(struct bat_priv *bat_priv,
 				 int packet_len, struct hard_iface *if_incoming,
 				 int own_packet, unsigned long send_time)
 {
-	/**
-	 * _aggr -> pointer to the packet we want to aggregate with
+	/* _aggr -> pointer to the packet we want to aggregate with
 	 * _pos -> pointer to the position in the queue
 	 */
 	struct forw_packet *forw_packet_aggr = NULL, *forw_packet_pos = NULL;
@@ -487,13 +486,13 @@ static void bat_iv_ogm_queue_add(struct bat_priv *bat_priv,
 	}
 
 	/* nothing to aggregate with - either aggregation disabled or no
-	 * suitable aggregation packet found */
+	 * suitable aggregation packet found
+	 */
 	if (!forw_packet_aggr) {
 		/* the following section can run without the lock */
 		spin_unlock_bh(&bat_priv->forw_bat_list_lock);
 
-		/**
-		 * if we could not aggregate this packet with one of the others
+		/* if we could not aggregate this packet with one of the others
 		 * we hold it back for a while, so that it might be aggregated
 		 * later on
 		 */
@@ -691,7 +690,8 @@ static void bat_iv_ogm_orig_update(struct bat_priv *bat_priv,
 	batadv_bonding_candidate_add(orig_node, neigh_node);
 
 	/* if this neighbor already is our next hop there is nothing
-	 * to change */
+	 * to change
+	 */
 	router = batadv_orig_node_get_router(orig_node);
 	if (router == neigh_node)
 		goto update_tt;
@@ -701,7 +701,8 @@ static void bat_iv_ogm_orig_update(struct bat_priv *bat_priv,
 		goto update_tt;
 
 	/* if the TQ is the same and the link not more symmetric we
-	 * won't consider it either */
+	 * won't consider it either
+	 */
 	if (router && (neigh_node->tq_avg == router->tq_avg)) {
 		orig_node_tmp = router->orig_node;
 		spin_lock_bh(&orig_node_tmp->ogm_cnt_lock);
@@ -723,7 +724,8 @@ static void bat_iv_ogm_orig_update(struct bat_priv *bat_priv,
 
 update_tt:
 	/* I have to check for transtable changes only if the OGM has been
-	 * sent through a primary interface */
+	 * sent through a primary interface
+	 */
 	if (((batman_ogm_packet->orig != ethhdr->h_source) &&
 	     (batman_ogm_packet->header.ttl > 2)) ||
 	    (batman_ogm_packet->flags & PRIMARIES_FIRST_HOP))
@@ -812,15 +814,17 @@ static int bat_iv_ogm_calc_tq(struct orig_node *orig_node,
 	total_count = (orig_eq_count > neigh_rq_count ?
 		       neigh_rq_count : orig_eq_count);
 
-	/* if we have too few packets (too less data) we set tq_own to zero */
-	/* if we receive too few packets it is not considered bidirectional */
+	/* if we have too few packets (too less data) we set tq_own to zero
+	 * if we receive too few packets it is not considered bidirectional
+	 */
 	if ((total_count < TQ_LOCAL_BIDRECT_SEND_MINIMUM) ||
 	    (neigh_rq_count < TQ_LOCAL_BIDRECT_RECV_MINIMUM))
 		tq_own = 0;
 	else
 		/* neigh_node->real_packet_count is never zero as we
 		 * only purge old information when getting new
-		 * information */
+		 * information
+		 */
 		tq_own = (TQ_MAX_VALUE * total_count) /	neigh_rq_count;
 
 	/* 1 - ((1-x) ** 3), normalized to TQ_MAX_VALUE this does
@@ -846,7 +850,8 @@ static int bat_iv_ogm_calc_tq(struct orig_node *orig_node,
 		neigh_rq_count, tq_own,	tq_asym_penalty, batman_ogm_packet->tq);
 
 	/* if link has the minimum required transmission quality
-	 * consider it bidirectional */
+	 * consider it bidirectional
+	 */
 	if (batman_ogm_packet->tq >= TQ_TOTAL_BIDRECT_LIMIT)
 		ret = 1;
 
@@ -1039,8 +1044,9 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 			return;
 
 		/* neighbor has to indicate direct link and it has to
-		 * come via the corresponding interface */
-		/* save packet seqno for bidirectional check */
+		 * come via the corresponding interface
+		 * save packet seqno for bidirectional check
+		 */
 		if (has_directlink_flag &&
 		    compare_eth(if_incoming->net_dev->dev_addr,
 				batman_ogm_packet->orig)) {
@@ -1117,7 +1123,8 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 	}
 
 	/* if sender is a direct neighbor the sender mac equals
-	 * originator mac */
+	 * originator mac
+	 */
 	orig_neigh_node = (is_single_hop_neigh ?
 			   orig_node :
 			   batadv_get_orig_node(bat_priv, ethhdr->h_source));
@@ -1127,7 +1134,8 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 	orig_neigh_router = batadv_orig_node_get_router(orig_neigh_node);
 
 	/* drop packet if sender is not a direct neighbor and if we
-	 * don't route towards it */
+	 * don't route towards it
+	 */
 	if (!is_single_hop_neigh && (!orig_neigh_router)) {
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"Drop packet: OGM via unknown neighbor!\n");
@@ -1141,7 +1149,8 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 				    batman_ogm_packet);
 
 	/* update ranking if it is not a duplicate or has the same
-	 * seqno and similar ttl as the non-duplicate */
+	 * seqno and similar ttl as the non-duplicate
+	 */
 	if (is_bidirectional &&
 	    (!is_duplicate ||
 	     ((orig_node->last_real_seqno == ntohl(batman_ogm_packet->seqno)) &&
diff --git a/net/batman-adv/bat_sysfs.c b/net/batman-adv/bat_sysfs.c
index 5a7b042..8196fa6 100644
--- a/net/batman-adv/bat_sysfs.c
+++ b/net/batman-adv/bat_sysfs.c
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2010-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2010-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
@@ -16,7 +15,6 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
 #include "main.h"
@@ -84,7 +82,8 @@ ssize_t show_##_name(struct kobject *kobj,				\
 }									\
 
 /* Use this, if you are going to turn a [name] in the soft-interface
- * (bat_priv) on or off */
+ * (bat_priv) on or off
+ */
 #define BAT_ATTR_SIF_BOOL(_name, _mode, _post_func)			\
 	static BAT_ATTR_SIF_STORE_BOOL(_name, _post_func)		\
 	static BAT_ATTR_SIF_SHOW_BOOL(_name)				\
@@ -110,7 +109,8 @@ ssize_t show_##_name(struct kobject *kobj,				\
 }									\
 
 /* Use this, if you are going to set [name] in the soft-interface
- * (bat_priv) to an unsigned integer value */
+ * (bat_priv) to an unsigned integer value
+ */
 #define BAT_ATTR_SIF_UINT(_name, _mode, _min, _max, _post_func)		\
 	static BAT_ATTR_SIF_STORE_UINT(_name, _min, _max, _post_func)	\
 	static BAT_ATTR_SIF_SHOW_UINT(_name)				\
@@ -155,7 +155,8 @@ ssize_t show_##_name(struct kobject *kobj,				\
 }
 
 /* Use this, if you are going to set [name] in hard_iface to an
- * unsigned integer value*/
+ * unsigned integer value
+ */
 #define BAT_ATTR_HIF_UINT(_name, _mode, _min, _max, _post_func)		\
 	static BAT_ATTR_HIF_STORE_UINT(_name, _min, _max, _post_func)	\
 	static BAT_ATTR_HIF_SHOW_UINT(_name)				\
diff --git a/net/batman-adv/bat_sysfs.h b/net/batman-adv/bat_sysfs.h
index f01aea8..3672277 100644
--- a/net/batman-adv/bat_sysfs.h
+++ b/net/batman-adv/bat_sysfs.h
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2010-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2010-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
@@ -16,10 +15,8 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
-
 #ifndef _NET_BATMAN_ADV_SYSFS_H_
 #define _NET_BATMAN_ADV_SYSFS_H_
 
diff --git a/net/batman-adv/bitarray.c b/net/batman-adv/bitarray.c
index 99ed991..838abbc 100644
--- a/net/batman-adv/bitarray.c
+++ b/net/batman-adv/bitarray.c
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2006-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2006-2012 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich, Marek Lindner
  *
@@ -16,7 +15,6 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
 #include "main.h"
@@ -46,8 +44,8 @@ int batadv_bit_get_packet(void *priv, unsigned long *seq_bits,
 	struct bat_priv *bat_priv = priv;
 
 	/* sequence number is slightly older. We already got a sequence number
-	 * higher than this one, so we just mark it. */
-
+	 * higher than this one, so we just mark it.
+	 */
 	if ((seq_num_diff <= 0) && (seq_num_diff > -TQ_LOCAL_WINDOW_SIZE)) {
 		if (set_mark)
 			bat_set_bit(seq_bits, -seq_num_diff);
@@ -55,8 +53,8 @@ int batadv_bit_get_packet(void *priv, unsigned long *seq_bits,
 	}
 
 	/* sequence number is slightly newer, so we shift the window and
-	 * set the mark if required */
-
+	 * set the mark if required
+	 */
 	if ((seq_num_diff > 0) && (seq_num_diff < TQ_LOCAL_WINDOW_SIZE)) {
 		batadv_bitmap_shift_left(seq_bits, seq_num_diff);
 
@@ -66,7 +64,6 @@ int batadv_bit_get_packet(void *priv, unsigned long *seq_bits,
 	}
 
 	/* sequence number is much newer, probably missed a lot of packets */
-
 	if ((seq_num_diff >= TQ_LOCAL_WINDOW_SIZE) &&
 	    (seq_num_diff < EXPECTED_SEQNO_RANGE)) {
 		bat_dbg(DBG_BATMAN, bat_priv,
@@ -81,8 +78,8 @@ int batadv_bit_get_packet(void *priv, unsigned long *seq_bits,
 	/* received a much older packet. The other host either restarted
 	 * or the old packet got delayed somewhere in the network. The
 	 * packet should be dropped without calling this function if the
-	 * seqno window is protected. */
-
+	 * seqno window is protected.
+	 */
 	if ((seq_num_diff <= -TQ_LOCAL_WINDOW_SIZE) ||
 	    (seq_num_diff >= EXPECTED_SEQNO_RANGE)) {
 
diff --git a/net/batman-adv/bitarray.h b/net/batman-adv/bitarray.h
index e855ddd3..8ab5426 100644
--- a/net/batman-adv/bitarray.h
+++ b/net/batman-adv/bitarray.h
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2006-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2006-2012 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich, Marek Lindner
  *
@@ -16,14 +15,14 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
 #ifndef _NET_BATMAN_ADV_BITARRAY_H_
 #define _NET_BATMAN_ADV_BITARRAY_H_
 
 /* returns true if the corresponding bit in the given seq_bits indicates true
- * and curr_seqno is within range of last_seqno */
+ * and curr_seqno is within range of last_seqno
+ */
 static inline int bat_test_bit(const unsigned long *seq_bits,
 			       uint32_t last_seqno, uint32_t curr_seqno)
 {
@@ -47,7 +46,8 @@ static inline void bat_set_bit(unsigned long *seq_bits, int32_t n)
 }
 
 /* receive and process one packet, returns 1 if received seq_num is considered
- * new, 0 if old  */
+ * new, 0 if old
+ */
 int batadv_bit_get_packet(void *priv, unsigned long *seq_bits,
 			  int32_t seq_num_diff, int set_mark);
 
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 27f451a..52c0d63 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2011-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2011-2012 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich
  *
@@ -16,7 +15,6 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
 #include "main.h"
@@ -123,8 +121,7 @@ static void claim_free_ref(struct claim *claim)
 		call_rcu(&claim->rcu, claim_free_rcu);
 }
 
-/**
- * @bat_priv: the bat priv with all the soft interface information
+/* @bat_priv: the bat priv with all the soft interface information
  * @data: search data (may be local/static data)
  *
  * looks for a claim in the hash, and returns it if found
@@ -162,8 +159,7 @@ static struct claim *claim_hash_find(struct bat_priv *bat_priv,
 	return claim_tmp;
 }
 
-/**
- * @bat_priv: the bat priv with all the soft interface information
+/* @bat_priv: the bat priv with all the soft interface information
  * @addr: the address of the originator
  * @vid: the VLAN ID
  *
@@ -241,8 +237,7 @@ static void bla_del_backbone_claims(struct backbone_gw *backbone_gw)
 	backbone_gw->crc = BLA_CRC_INIT;
 }
 
-/**
- * @bat_priv: the bat priv with all the soft interface information
+/* @bat_priv: the bat priv with all the soft interface information
  * @orig: the mac address to be announced within the claim
  * @vid: the VLAN ID
  * @claimtype: the type of the claim (CLAIM, UNCLAIM, ANNOUNCE, ...)
@@ -347,8 +342,7 @@ out:
 		hardif_free_ref(primary_if);
 }
 
-/**
- * @bat_priv: the bat priv with all the soft interface information
+/* @bat_priv: the bat priv with all the soft interface information
  * @orig: the mac address of the originator
  * @vid: the VLAN ID
  *
@@ -422,8 +416,7 @@ static void bla_update_own_backbone_gw(struct bat_priv *bat_priv,
 	backbone_gw_free_ref(backbone_gw);
 }
 
-/**
- * @bat_priv: the bat priv with all the soft interface information
+/* @bat_priv: the bat priv with all the soft interface information
  * @vid: the vid where the request came on
  *
  * Repeat all of our own claims, and finally send an ANNOUNCE frame
@@ -468,8 +461,7 @@ static void bla_answer_request(struct bat_priv *bat_priv,
 	backbone_gw_free_ref(backbone_gw);
 }
 
-/**
- * @backbone_gw: the backbone gateway from whom we are out of sync
+/* @backbone_gw: the backbone gateway from whom we are out of sync
  *
  * When the crc is wrong, ask the backbone gateway for a full table update.
  * After the request, it will repeat all of his own claims and finally
@@ -495,8 +487,7 @@ static void bla_send_request(struct backbone_gw *backbone_gw)
 	}
 }
 
-/**
- * @bat_priv: the bat priv with all the soft interface information
+/* @bat_priv: the bat priv with all the soft interface information
  * @backbone_gw: our backbone gateway which should be announced
  *
  * This function sends an announcement. It is called from multiple
@@ -516,8 +507,7 @@ static void bla_send_announce(struct bat_priv *bat_priv,
 
 }
 
-/**
- * @bat_priv: the bat priv with all the soft interface information
+/* @bat_priv: the bat priv with all the soft interface information
  * @mac: the mac address of the claim
  * @vid: the VLAN ID of the frame
  * @backbone_gw: the backbone gateway which claims it
@@ -731,8 +721,7 @@ static int handle_claim(struct bat_priv *bat_priv,
 	return 1;
 }
 
-/**
- * @bat_priv: the bat priv with all the soft interface information
+/* @bat_priv: the bat priv with all the soft interface information
  * @hw_src: the Hardware source in the ARP Header
  * @hw_dst: the Hardware destination in the ARP Header
  * @ethhdr: pointer to the Ethernet header of the claim frame
@@ -810,8 +799,7 @@ static int check_claim_group(struct bat_priv *bat_priv,
 }
 
 
-/**
- * @bat_priv: the bat priv with all the soft interface information
+/* @bat_priv: the bat priv with all the soft interface information
  * @skb: the frame to be checked
  *
  * Check if this is a claim frame, and process it accordingly.
@@ -860,7 +848,6 @@ static int bla_process_claim(struct bat_priv *bat_priv,
 	/* Check whether the ARP frame carries a valid
 	 * IP information
 	 */
-
 	if (arphdr->ar_hrd != htons(ARPHRD_ETHER))
 		return 0;
 	if (arphdr->ar_pro != htons(ETH_P_IP))
@@ -963,8 +950,7 @@ purge_now:
 	}
 }
 
-/**
- * @bat_priv: the bat priv with all the soft interface information
+/* @bat_priv: the bat priv with all the soft interface information
  * @primary_if: the selected primary interface, may be NULL if now is set
  * @now: whether the whole hash shall be wiped now
  *
@@ -1011,13 +997,11 @@ purge_now:
 	}
 }
 
-/**
- * @bat_priv: the bat priv with all the soft interface information
+/* @bat_priv: the bat priv with all the soft interface information
  * @primary_if: the new selected primary_if
  * @oldif: the old primary interface, may be NULL
  *
  * Update the backbone gateways when the own orig address changes.
- *
  */
 void batadv_bla_update_orig_address(struct bat_priv *bat_priv,
 				    struct hard_iface *primary_if,
@@ -1183,8 +1167,7 @@ int batadv_bla_init(struct bat_priv *bat_priv)
 	return 0;
 }
 
-/**
- * @bat_priv: the bat priv with all the soft interface information
+/* @bat_priv: the bat priv with all the soft interface information
  * @bcast_packet: originator mac address
  * @hdr_size: maximum length of the frame
  *
@@ -1196,9 +1179,7 @@ int batadv_bla_init(struct bat_priv *bat_priv)
  * with a good chance that it is the same packet. If it is furthermore
  * sent by another host, drop it. We allow equal packets from
  * the same host however as this might be intended.
- *
- **/
-
+ */
 int batadv_bla_check_bcast_duplist(struct bat_priv *bat_priv,
 				   struct bcast_packet *bcast_packet,
 				   int hdr_size)
@@ -1250,16 +1231,13 @@ int batadv_bla_check_bcast_duplist(struct bat_priv *bat_priv,
 
 
 
-/**
- * @bat_priv: the bat priv with all the soft interface information
+/* @bat_priv: the bat priv with all the soft interface information
  * @orig: originator mac address
  *
  * check if the originator is a gateway for any VLAN ID.
  *
  * returns 1 if it is found, 0 otherwise
- *
  */
-
 int batadv_bla_is_backbone_gw_orig(struct bat_priv *bat_priv, uint8_t *orig)
 {
 	struct hashtable_t *hash = bat_priv->backbone_hash;
@@ -1291,15 +1269,13 @@ int batadv_bla_is_backbone_gw_orig(struct bat_priv *bat_priv, uint8_t *orig)
 }
 
 
-/**
- * @skb: the frame to be checked
+/* @skb: the frame to be checked
  * @orig_node: the orig_node of the frame
  * @hdr_size: maximum length of the frame
  *
  * bla_is_backbone_gw inspects the skb for the VLAN ID and returns 1
  * if the orig_node is also a gateway on the soft interface, otherwise it
  * returns 0.
- *
  */
 int batadv_bla_is_backbone_gw(struct sk_buff *skb,
 			      struct orig_node *orig_node, int hdr_size)
@@ -1328,7 +1304,6 @@ int batadv_bla_is_backbone_gw(struct sk_buff *skb,
 	}
 
 	/* see if this originator is a backbone gw for this VLAN */
-
 	backbone_gw = backbone_hash_find(orig_node->bat_priv,
 					 orig_node->orig, vid);
 	if (!backbone_gw)
@@ -1360,8 +1335,7 @@ void batadv_bla_free(struct bat_priv *bat_priv)
 		hardif_free_ref(primary_if);
 }
 
-/**
- * @bat_priv: the bat priv with all the soft interface information
+/* @bat_priv: the bat priv with all the soft interface information
  * @skb: the frame to be checked
  * @vid: the VLAN ID of the frame
  *
@@ -1372,7 +1346,6 @@ void batadv_bla_free(struct bat_priv *bat_priv)
  * in these cases, the skb is further handled by this function and
  * returns 1, otherwise it returns 0 and the caller shall further
  * process the skb.
- *
  */
 int batadv_bla_rx(struct bat_priv *bat_priv, struct sk_buff *skb, short vid)
 {
@@ -1449,8 +1422,7 @@ out:
 	return ret;
 }
 
-/**
- * @bat_priv: the bat priv with all the soft interface information
+/* @bat_priv: the bat priv with all the soft interface information
  * @skb: the frame to be checked
  * @vid: the VLAN ID of the frame
  *
@@ -1461,7 +1433,6 @@ out:
  * in these cases, the skb is further handled by this function and
  * returns 1, otherwise it returns 0 and the caller shall further
  * process the skb.
- *
  */
 int batadv_bla_tx(struct bat_priv *bat_priv, struct sk_buff *skb, short vid)
 {
diff --git a/net/batman-adv/bridge_loop_avoidance.h b/net/batman-adv/bridge_loop_avoidance.h
index 546cd64..9818b1e 100644
--- a/net/batman-adv/bridge_loop_avoidance.h
+++ b/net/batman-adv/bridge_loop_avoidance.h
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2011-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2011-2012 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich
  *
@@ -16,7 +15,6 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
 #ifndef _NET_BATMAN_ADV_BLA_H_
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index e396029..0d90fff 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2009-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2009-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
@@ -16,7 +15,6 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
 #include "main.h"
@@ -33,7 +31,8 @@
 #include <linux/if_vlan.h>
 
 /* This is the offset of the options field in a dhcp packet starting at
- * the beginning of the dhcp header */
+ * the beginning of the dhcp header
+ */
 #define DHCP_OPTIONS_OFFSET 240
 #define DHCP_REQUEST 3
 
@@ -151,14 +150,13 @@ static struct gw_node *gw_get_best_gw_node(struct bat_priv *bat_priv)
 			}
 			break;
 
-		default: /**
-			  * 2:  stable connection (use best statistic)
+		default: /* 2:  stable connection (use best statistic)
 			  * 3:  fast-switch (use best statistic but change as
 			  *     soon as a better gateway appears)
 			  * XX: late-switch (use best statistic but change as
 			  *     soon as a better gateway appears which has
 			  *     $routing_class more tq points)
-			  **/
+			  */
 			if (router->tq_avg > max_tq) {
 				if (curr_gw)
 					gw_node_free_ref(curr_gw);
@@ -190,12 +188,11 @@ void batadv_gw_election(struct bat_priv *bat_priv)
 	struct neigh_node *router = NULL;
 	char gw_addr[18] = { '\0' };
 
-	/**
-	 * The batman daemon checks here if we already passed a full originator
+	/* The batman daemon checks here if we already passed a full originator
 	 * cycle in order to make sure we don't choose the first gateway we
 	 * hear about. This check is based on the daemon's uptime which we
 	 * don't have.
-	 **/
+	 */
 	if (atomic_read(&bat_priv->gw_mode) != GW_MODE_CLIENT)
 		goto out;
 
@@ -278,10 +275,9 @@ void batadv_gw_check_election(struct bat_priv *bat_priv,
 	if (orig_tq_avg < gw_tq_avg)
 		goto out;
 
-	/**
-	 * if the routing class is greater than 3 the value tells us how much
+	/* if the routing class is greater than 3 the value tells us how much
 	 * greater the TQ value of the new gateway must be
-	 **/
+	 */
 	if ((atomic_read(&bat_priv->gw_sel_class) > 3) &&
 	    (orig_tq_avg - gw_tq_avg < atomic_read(&bat_priv->gw_sel_class)))
 		goto out;
@@ -337,8 +333,7 @@ void batadv_gw_node_update(struct bat_priv *bat_priv,
 	struct hlist_node *node;
 	struct gw_node *gw_node, *curr_gw;
 
-	/**
-	 * Note: We don't need a NULL check here, since curr_gw never gets
+	/* Note: We don't need a NULL check here, since curr_gw never gets
 	 * dereferenced. If curr_gw is NULL we also should not exit as we may
 	 * have this gateway in our list (duplication check!) even though we
 	 * have no currently selected gateway.
@@ -426,9 +421,7 @@ void batadv_gw_node_purge(struct bat_priv *bat_priv)
 		gw_node_free_ref(curr_gw);
 }
 
-/**
- * fails if orig_node has no router
- */
+/* fails if orig_node has no router */
 static int _write_buffer_text(struct bat_priv *bat_priv, struct seq_file *seq,
 			      const struct gw_node *gw_node)
 {
@@ -534,12 +527,14 @@ static bool is_type_dhcprequest(struct sk_buff *skb, int header_len)
 	/* Access the dhcp option lists. Each entry is made up by:
 	 * - octet 1: option type
 	 * - octet 2: option data len (only if type != 255 and 0)
-	 * - octet 3: option data */
+	 * - octet 3: option data
+	 */
 	while (*p != 255 && !ret) {
 		/* p now points to the first octet: option type */
 		if (*p == 53) {
 			/* type 53 is the message type option.
-			 * Jump the len octet and go to the data octet */
+			 * Jump the len octet and go to the data octet
+			 */
 			if (pkt_len < 2)
 				goto out;
 			p += 2;
@@ -667,7 +662,8 @@ bool batadv_gw_out_of_range(struct bat_priv *bat_priv,
 	switch (atomic_read(&bat_priv->gw_mode)) {
 	case GW_MODE_SERVER:
 		/* If we are a GW then we are our best GW. We can artificially
-		 * set the tq towards ourself as the maximum value */
+		 * set the tq towards ourself as the maximum value
+		 */
 		curr_tq_avg = TQ_MAX_VALUE;
 		break;
 	case GW_MODE_CLIENT:
@@ -681,7 +677,8 @@ bool batadv_gw_out_of_range(struct bat_priv *bat_priv,
 
 		/* If the dhcp packet has been sent to a different gw,
 		 * we have to evaluate whether the old gw is still
-		 * reliable enough */
+		 * reliable enough
+		 */
 		neigh_curr = batadv_find_router(bat_priv, curr_gw->orig_node,
 						NULL);
 		if (!neigh_curr)
diff --git a/net/batman-adv/gateway_client.h b/net/batman-adv/gateway_client.h
index 2c2446f..4529d42 100644
--- a/net/batman-adv/gateway_client.h
+++ b/net/batman-adv/gateway_client.h
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2009-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2009-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
@@ -16,7 +15,6 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
 #ifndef _NET_BATMAN_ADV_GATEWAY_CLIENT_H_
diff --git a/net/batman-adv/gateway_common.c b/net/batman-adv/gateway_common.c
index 722c932..3700562c 100644
--- a/net/batman-adv/gateway_common.c
+++ b/net/batman-adv/gateway_common.c
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2009-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2009-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
@@ -16,7 +15,6 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
 #include "main.h"
@@ -156,11 +154,10 @@ ssize_t batadv_gw_bandwidth_set(struct net_device *net_dev, char *buff,
 
 	kbit_to_gw_bandwidth(down, up, &gw_bandwidth_tmp);
 
-	/**
-	 * the gw bandwidth we guessed above might not match the given
+	/* the gw bandwidth we guessed above might not match the given
 	 * speeds, hence we need to calculate it back to show the number
 	 * that is going to be propagated
-	 **/
+	 */
 	batadv_gw_bandwidth_to_kbit((uint8_t)gw_bandwidth_tmp, &down, &up);
 
 	if (atomic_read(&bat_priv->gw_bandwidth) == gw_bandwidth_tmp)
diff --git a/net/batman-adv/gateway_common.h b/net/batman-adv/gateway_common.h
index e256040..6f8a4d0 100644
--- a/net/batman-adv/gateway_common.h
+++ b/net/batman-adv/gateway_common.h
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2009-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2009-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
@@ -16,7 +15,6 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
 #ifndef _NET_BATMAN_ADV_GATEWAY_COMMON_H_
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index ab2fcfa..2a4d394 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
@@ -16,7 +15,6 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
 #include "main.h"
@@ -74,10 +72,6 @@ static int is_valid_iface(const struct net_device *net_dev)
 	if (batadv_softif_is_valid(net_dev))
 		return 0;
 
-	/* Device is being bridged */
-	/* if (net_dev->priv_flags & IFF_BRIDGE_PORT)
-		return 0; */
-
 	return 1;
 }
 
@@ -185,7 +179,8 @@ int batadv_hardif_min_mtu(struct net_device *soft_iface)
 	const struct bat_priv *bat_priv = netdev_priv(soft_iface);
 	const struct hard_iface *hard_iface;
 	/* allow big frames if all devices are capable to do so
-	 * (have MTU > 1500 + BAT_HEADER_LEN) */
+	 * (have MTU > 1500 + BAT_HEADER_LEN)
+	 */
 	int min_mtu = ETH_DATA_LEN;
 
 	if (atomic_read(&bat_priv->fragmentation))
@@ -231,8 +226,7 @@ static void hardif_activate_interface(struct hard_iface *hard_iface)
 	bat_priv->bat_algo_ops->bat_iface_update_mac(hard_iface);
 	hard_iface->if_status = IF_TO_BE_ACTIVATED;
 
-	/**
-	 * the first active interface becomes our primary interface or
+	/* the first active interface becomes our primary interface or
 	 * the next active interface after the old primary interface was removed
 	 */
 	primary_if = primary_if_get_selected(bat_priv);
@@ -438,8 +432,7 @@ static struct hard_iface *hardif_add_interface(struct net_device *net_dev)
 	check_known_mac_addr(hard_iface->net_dev);
 	list_add_tail_rcu(&hard_iface->list, &batadv_hardif_list);
 
-	/**
-	 * This can't be called via a bat_priv callback because
+	/* This can't be called via a bat_priv callback because
 	 * we have no bat_priv yet.
 	 */
 	atomic_set(&hard_iface->seqno, 1);
@@ -544,7 +537,8 @@ out:
 }
 
 /* This function returns true if the interface represented by ifindex is a
- * 802.11 wireless device */
+ * 802.11 wireless device
+ */
 bool batadv_is_wifi_iface(int ifindex)
 {
 	struct net_device *net_device = NULL;
@@ -559,7 +553,8 @@ bool batadv_is_wifi_iface(int ifindex)
 
 #ifdef CONFIG_WIRELESS_EXT
 	/* pre-cfg80211 drivers have to implement WEXT, so it is possible to
-	 * check for wireless_handlers != NULL */
+	 * check for wireless_handlers != NULL
+	 */
 	if (net_device->wireless_handlers)
 		ret = true;
 	else
diff --git a/net/batman-adv/hard-interface.h b/net/batman-adv/hard-interface.h
index 20e09db..6bc12c0 100644
--- a/net/batman-adv/hard-interface.h
+++ b/net/batman-adv/hard-interface.h
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
@@ -16,7 +15,6 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
 #ifndef _NET_BATMAN_ADV_HARD_INTERFACE_H_
diff --git a/net/batman-adv/hash.c b/net/batman-adv/hash.c
index 65bbd15..e39f8f4 100644
--- a/net/batman-adv/hash.c
+++ b/net/batman-adv/hash.c
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2006-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2006-2012 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich, Marek Lindner
  *
@@ -16,7 +15,6 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
 #include "main.h"
diff --git a/net/batman-adv/hash.h b/net/batman-adv/hash.h
index e75df6b..eba8f2a 100644
--- a/net/batman-adv/hash.h
+++ b/net/batman-adv/hash.h
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2006-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2006-2012 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich, Marek Lindner
  *
@@ -16,7 +15,6 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
 #ifndef _NET_BATMAN_ADV_HASH_H_
@@ -24,15 +22,15 @@
 
 #include <linux/list.h>
 
-/* callback to a compare function.  should
- * compare 2 element datas for their keys,
- * return 0 if same and not 0 if not
- * same */
+/* callback to a compare function.  should compare 2 element datas for their
+ * keys, return 0 if same and not 0 if not same
+ */
 typedef int (*hashdata_compare_cb)(const struct hlist_node *, const void *);
 
 /* the hashfunction, should return an index
  * based on the key in the data of the first
- * argument and the size the second */
+ * argument and the size the second
+ */
 typedef uint32_t (*hashdata_choose_cb)(const void *, uint32_t);
 typedef void (*hashdata_free_cb)(struct hlist_node *, void *);
 
@@ -54,7 +52,8 @@ void batadv_hash_destroy(struct hashtable_t *hash);
 
 /* remove the hash structure. if hashdata_free_cb != NULL, this function will be
  * called to remove the elements inside of the hash.  if you don't remove the
- * elements, memory might be leaked. */
+ * elements, memory might be leaked.
+ */
 static inline void hash_delete(struct hashtable_t *hash,
 			       hashdata_free_cb free_cb, void *arg)
 {
@@ -80,8 +79,7 @@ static inline void hash_delete(struct hashtable_t *hash,
 	batadv_hash_destroy(hash);
 }
 
-/**
- *	hash_add - adds data to the hashtable
+/*	hash_add - adds data to the hashtable
  *	@hash: storage hash table
  *	@compare: callback to determine if 2 hash elements are identical
  *	@choose: callback calculating the hash index
@@ -91,7 +89,6 @@ static inline void hash_delete(struct hashtable_t *hash,
  *	Returns 0 on success, 1 if the element already is in the hash
  *	and -1 on error.
  */
-
 static inline int hash_add(struct hashtable_t *hash,
 			   hashdata_compare_cb compare,
 			   hashdata_choose_cb choose,
@@ -134,7 +131,8 @@ out:
 /* removes data from hash, if found. returns pointer do data on success, so you
  * can remove the used structure yourself, or NULL on error .  data could be the
  * structure you use with just the key filled, we just need the key for
- * comparing. */
+ * comparing.
+ */
 static inline void *hash_remove(struct hashtable_t *hash,
 				hashdata_compare_cb compare,
 				hashdata_choose_cb choose, void *data)
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index 2300561..40c5e18 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
@@ -16,7 +15,6 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
 #include "main.h"
@@ -312,7 +310,8 @@ static void bat_socket_add_packet(struct socket_client *socket_client,
 	spin_lock_bh(&socket_client->lock);
 
 	/* while waiting for the lock the socket_client could have been
-	 * deleted */
+	 * deleted
+	 */
 	if (!socket_client_hash[icmp_packet->uid]) {
 		spin_unlock_bh(&socket_client->lock);
 		kfree(socket_packet);
diff --git a/net/batman-adv/icmp_socket.h b/net/batman-adv/icmp_socket.h
index 7b88636..a62ab80 100644
--- a/net/batman-adv/icmp_socket.h
+++ b/net/batman-adv/icmp_socket.h
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
@@ -16,7 +15,6 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
 #ifndef _NET_BATMAN_ADV_ICMP_SOCKET_H_
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 5e1d906..d56d6b2 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
@@ -16,7 +15,6 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
 #include "main.h"
@@ -37,7 +35,8 @@
 
 
 /* List manipulations on hardif_list have to be rtnl_lock()'ed,
- * list traversals just rcu-locked */
+ * list traversals just rcu-locked
+ */
 struct list_head batadv_hardif_list;
 static int (*recv_packet_handler[256])(struct sk_buff *, struct hard_iface *);
 char batadv_routing_algo[20] = "BATMAN_IV";
@@ -59,7 +58,8 @@ static int __init batman_init(void)
 	batadv_iv_init();
 
 	/* the name should not be longer than 10 chars - see
-	 * http://lwn.net/Articles/23634/ */
+	 * http://lwn.net/Articles/23634/
+	 */
 	batadv_event_workqueue = create_singlethread_workqueue("bat_events");
 
 	if (!batadv_event_workqueue)
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 1238642..4b06b76 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
@@ -16,7 +15,6 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
 #ifndef _NET_BATMAN_ADV_MAIN_H_
@@ -36,19 +34,21 @@
 #define TQ_MAX_VALUE 255
 #define JITTER 20
 
- /* Time To Live of broadcast messages */
+/* Time To Live of broadcast messages */
 #define TTL 50
 
 /* purge originators after time in seconds if no valid packet comes in
- * -> TODO: check influence on TQ_LOCAL_WINDOW_SIZE */
+ * -> TODO: check influence on TQ_LOCAL_WINDOW_SIZE
+ */
 #define PURGE_TIMEOUT 200000 /* 200 seconds */
 #define TT_LOCAL_TIMEOUT 3600000 /* in miliseconds */
 #define TT_CLIENT_ROAM_TIMEOUT 600000 /* in miliseconds */
 /* sliding packet range of received originator messages in sequence numbers
- * (should be a multiple of our word size) */
+ * (should be a multiple of our word size)
+ */
 #define TQ_LOCAL_WINDOW_SIZE 64
-#define TT_REQUEST_TIMEOUT 3000 /* miliseconds we have to keep
-				 * pending tt_req */
+/* miliseconds we have to keep pending tt_req */
+#define TT_REQUEST_TIMEOUT 3000
 
 #define TQ_GLOBAL_WINDOW_SIZE 5
 #define TQ_LOCAL_BIDRECT_SEND_MINIMUM 1
@@ -57,8 +57,10 @@
 
 #define TT_OGM_APPEND_MAX 3 /* number of OGMs sent with the last tt diff */
 
-#define ROAMING_MAX_TIME 20000 /* Time in which a client can roam at most
-				* ROAMING_MAX_COUNT times in miliseconds*/
+/* Time in which a client can roam at most ROAMING_MAX_COUNT times in
+ * miliseconds
+ */
+#define ROAMING_MAX_TIME 20000
 #define ROAMING_MAX_COUNT 5
 
 #define NO_FLAGS 0
@@ -72,11 +74,13 @@
 #define VIS_INTERVAL 5000	/* 5 seconds */
 
 /* how much worse secondary interfaces may be to be considered as bonding
- * candidates */
+ * candidates
+ */
 #define BONDING_TQ_THRESHOLD	50
 
 /* should not be bigger than 512 bytes or change the size of
- * forw_packet->direct_link_flags */
+ * forw_packet->direct_link_flags
+ */
 #define MAX_AGGREGATION_BYTES 512
 #define MAX_AGGREGATION_MS 100
 
@@ -201,19 +205,16 @@ static inline void bat_dbg(int type __always_unused,
 		pr_err("%s: " fmt, _netdev->name, ## arg);		\
 	} while (0)
 
-/**
- * returns 1 if they are the same ethernet addr
+/* returns 1 if they are the same ethernet addr
  *
  * note: can't use compare_ether_addr() as it requires aligned memory
  */
-
 static inline int compare_eth(const void *data1, const void *data2)
 {
 	return (memcmp(data1, data2, ETH_ALEN) == 0 ? 1 : 0);
 }
 
-/**
- * has_timed_out - compares current time (jiffies) and timestamp + timeout
+/* has_timed_out - compares current time (jiffies) and timestamp + timeout
  * @timestamp:		base value to compare with (in jiffies)
  * @timeout:		added to base value before comparing (in milliseconds)
  *
@@ -237,7 +238,8 @@ static inline bool has_timed_out(unsigned long timestamp, unsigned int timeout)
  *  - when adding nothing - it is neither a predecessor nor a successor
  *  - before adding more than 127 to the starting value - it is a predecessor,
  *  - when adding 128 - it is neither a predecessor nor a successor,
- *  - after adding more than 127 to the starting value - it is a successor */
+ *  - after adding more than 127 to the starting value - it is a successor
+ */
 #define seq_before(x, y) ({typeof(x) _d1 = (x); \
 			  typeof(y) _d2 = (y); \
 			  typeof(x) _dummy = (_d1 - _d2); \
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 3e90204..86e7e08 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2009-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2009-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
@@ -16,7 +15,6 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
 #include "main.h"
@@ -188,7 +186,8 @@ void batadv_originator_free(struct bat_priv *bat_priv)
 }
 
 /* this function finds or creates an originator entry for the given
- * address if it does not exits */
+ * address if it does not exits
+ */
 struct orig_node *batadv_get_orig_node(struct bat_priv *bat_priv,
 				       const uint8_t *addr)
 {
@@ -521,7 +520,8 @@ int batadv_orig_hash_add_if(struct hard_iface *hard_iface, int max_if_num)
 	int ret;
 
 	/* resize all orig nodes because orig_node->bcast_own(_sum) depend on
-	 * if_num */
+	 * if_num
+	 */
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
 
@@ -604,7 +604,8 @@ int batadv_orig_hash_del_if(struct hard_iface *hard_iface, int max_if_num)
 	int ret;
 
 	/* resize all orig nodes because orig_node->bcast_own(_sum) depend on
-	 * if_num */
+	 * if_num
+	 */
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
 
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index 97deeba..a721719 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
@@ -16,7 +15,6 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
 #ifndef _NET_BATMAN_ADV_ORIGINATOR_H_
@@ -40,8 +38,9 @@ int batadv_orig_hash_add_if(struct hard_iface *hard_iface, int max_if_num);
 int batadv_orig_hash_del_if(struct hard_iface *hard_iface, int max_if_num);
 
 
-/* hashfunction to choose an entry in a hash table of given size */
-/* hash algorithm from http://en.wikipedia.org/wiki/Hash_table */
+/* hashfunction to choose an entry in a hash table of given size
+ * hash algorithm from http://en.wikipedia.org/wiki/Hash_table
+ */
 static inline uint32_t choose_orig(const void *data, uint32_t size)
 {
 	const unsigned char *key = data;
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 033d994..c90219c 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
@@ -16,7 +15,6 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
 #ifndef _NET_BATMAN_ADV_PACKET_H_
@@ -81,7 +79,8 @@ enum tt_query_flags {
 
 /* TT_CLIENT flags.
  * Flags from 1 to 1 << 7 are sent on the wire, while flags from 1 << 8 to
- * 1 << 15 are used for local computation only */
+ * 1 << 15 are used for local computation only
+ */
 enum tt_client_flags {
 	TT_CLIENT_DEL     = 1 << 0,
 	TT_CLIENT_ROAM    = 1 << 1,
@@ -142,7 +141,8 @@ struct icmp_packet {
 #define BAT_RR_LEN 16
 
 /* icmp_packet_rr must start with all fields from imcp_packet
- * as this is assumed by code that handles ICMP packets */
+ * as this is assumed by code that handles ICMP packets
+ */
 struct icmp_packet_rr {
 	struct batman_header header;
 	uint8_t  msg_type; /* see ICMP message types above */
@@ -192,7 +192,8 @@ struct tt_query_packet {
 	struct batman_header header;
 	/* the flag field is a combination of:
 	 * - TT_REQUEST or TT_RESPONSE
-	 * - TT_FULL_TABLE */
+	 * - TT_FULL_TABLE
+	 */
 	uint8_t  flags;
 	uint8_t  dst[ETH_ALEN];
 	uint8_t  src[ETH_ALEN];
@@ -200,13 +201,15 @@ struct tt_query_packet {
 	 * if TT_REQUEST: ttvn that triggered the
 	 *		  request
 	 * if TT_RESPONSE: new ttvn for the src
-	 *		   orig_node */
+	 *		   orig_node
+	 */
 	uint8_t  ttvn;
 	/* tt_data field is:
 	 * if TT_REQUEST: crc associated with the
 	 *		  ttvn
-	 * if TT_RESPONSE: table_size */
-	__be16   tt_data;
+	 * if TT_RESPONSE: table_size
+	 */
+	__be16 tt_data;
 } __packed;
 
 struct roam_adv_packet {
diff --git a/net/batman-adv/ring_buffer.c b/net/batman-adv/ring_buffer.c
index db8f5ef..aff1ca2 100644
--- a/net/batman-adv/ring_buffer.c
+++ b/net/batman-adv/ring_buffer.c
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
@@ -16,7 +15,6 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
 #include "main.h"
diff --git a/net/batman-adv/ring_buffer.h b/net/batman-adv/ring_buffer.h
index fbaf9d2..fda8c17 100644
--- a/net/batman-adv/ring_buffer.h
+++ b/net/batman-adv/ring_buffer.h
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
@@ -16,7 +15,6 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
 #ifndef _NET_BATMAN_ADV_RING_BUFFER_H_
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 1b1dd41..79f63cf 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
@@ -16,7 +15,6 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
 #include "main.h"
@@ -165,8 +163,7 @@ void batadv_bonding_candidate_add(struct orig_node *orig_node,
 	if (neigh_node->tq_avg < router->tq_avg - BONDING_TQ_THRESHOLD)
 		goto candidate_del;
 
-	/**
-	 * check if we have another candidate with the same mac address or
+	/* check if we have another candidate with the same mac address or
 	 * interface. If we do, we won't select this candidate because of
 	 * possible interference.
 	 */
@@ -177,7 +174,8 @@ void batadv_bonding_candidate_add(struct orig_node *orig_node,
 			continue;
 
 		/* we only care if the other candidate is even
-		* considered as candidate. */
+		 * considered as candidate.
+		 */
 		if (list_empty(&tmp_neigh_node->bonding_list))
 			continue;
 
@@ -398,9 +396,7 @@ int batadv_recv_icmp_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 	int hdr_size = sizeof(struct icmp_packet);
 	int ret = NET_RX_DROP;
 
-	/**
-	 * we truncate all incoming icmp packets if they don't match our size
-	 */
+	/* we truncate all incoming icmp packets if they don't match our size */
 	if (skb->len >= sizeof(struct icmp_packet_rr))
 		hdr_size = sizeof(struct icmp_packet_rr);
 
@@ -474,7 +470,8 @@ out:
  * robin fashion over the remaining interfaces.
  *
  * This method rotates the bonding list and increases the
- * returned router's refcount. */
+ * returned router's refcount.
+ */
 static struct neigh_node *find_bond_router(struct orig_node *primary_orig,
 					   const struct hard_iface *recv_if)
 {
@@ -507,10 +504,12 @@ static struct neigh_node *find_bond_router(struct orig_node *primary_orig,
 		goto out;
 
 	/* selected should point to the next element
-	 * after the current router */
+	 * after the current router
+	 */
 	spin_lock_bh(&primary_orig->neigh_list_lock);
 	/* this is a list_move(), which unfortunately
-	 * does not exist as rcu version */
+	 * does not exist as rcu version
+	 */
 	list_del_rcu(&primary_orig->bond_list);
 	list_add_rcu(&primary_orig->bond_list,
 		     &router->bonding_list);
@@ -525,7 +524,8 @@ out:
  * remaining candidates which are not using
  * this interface.
  *
- * Increases the returned router's refcount */
+ * Increases the returned router's refcount
+ */
 static struct neigh_node *find_ifalter_router(struct orig_node *primary_orig,
 					      const struct hard_iface *recv_if)
 {
@@ -546,11 +546,13 @@ static struct neigh_node *find_ifalter_router(struct orig_node *primary_orig,
 			continue;
 
 		/* if we don't have a router yet
-		 * or this one is better, choose it. */
+		 * or this one is better, choose it.
+		 */
 		if ((!router) ||
 		    (tmp_neigh_node->tq_avg > router->tq_avg)) {
 			/* decrement refcount of
-			 * previously selected router */
+			 * previously selected router
+			 */
 			if (router)
 				batadv_neigh_node_free_ref(router);
 
@@ -602,7 +604,8 @@ int batadv_recv_tt_query(struct sk_buff *skb, struct hard_iface *recv_if)
 		batadv_inc_counter(bat_priv, BAT_CNT_TT_REQUEST_RX);
 
 		/* If we cannot provide an answer the tt_request is
-		 * forwarded */
+		 * forwarded
+		 */
 		if (!batadv_send_tt_response(bat_priv, tt_query)) {
 			bat_dbg(DBG_TT, bat_priv,
 				"Routing TT_REQUEST to %pM [%c]\n",
@@ -616,7 +619,8 @@ int batadv_recv_tt_query(struct sk_buff *skb, struct hard_iface *recv_if)
 
 		if (batadv_is_my_mac(tt_query->dst)) {
 			/* packet needs to be linearized to access the TT
-			 * changes */
+			 * changes
+			 */
 			if (skb_linearize(skb) < 0)
 				goto out;
 			/* skb_linearize() possibly changed skb->data */
@@ -694,7 +698,8 @@ int batadv_recv_roam_adv(struct sk_buff *skb, struct hard_iface *recv_if)
 
 	/* Roaming phase starts: I have new information but the ttvn has not
 	 * been incremented yet. This flag will make me check all the incoming
-	 * packets for the correct destination. */
+	 * packets for the correct destination.
+	 */
 	bat_priv->tt_poss_change = true;
 
 	batadv_orig_node_free_ref(orig_node);
@@ -705,7 +710,8 @@ out:
 
 /* find a suitable router for this originator, and use
  * bonding if possible. increases the found neighbors
- * refcount.*/
+ * refcount.
+ */
 struct neigh_node *batadv_find_router(struct bat_priv *bat_priv,
 				      struct orig_node *orig_node,
 				      const struct hard_iface *recv_if)
@@ -724,7 +730,8 @@ struct neigh_node *batadv_find_router(struct bat_priv *bat_priv,
 		goto err;
 
 	/* without bonding, the first node should
-	 * always choose the default router. */
+	 * always choose the default router.
+	 */
 	bonding_enabled = atomic_read(&bat_priv->bonding);
 
 	rcu_read_lock();
@@ -737,13 +744,14 @@ struct neigh_node *batadv_find_router(struct bat_priv *bat_priv,
 		goto return_router;
 
 	/* if we have something in the primary_addr, we can search
-	 * for a potential bonding candidate. */
+	 * for a potential bonding candidate.
+	 */
 	if (compare_eth(router_orig->primary_addr, zero_mac))
 		goto return_router;
 
 	/* find the orig_node which has the primary interface. might
-	 * even be the same as our router_orig in many cases */
-
+	 * even be the same as our router_orig in many cases
+	 */
 	if (compare_eth(router_orig->primary_addr, router_orig->orig)) {
 		primary_orig_node = router_orig;
 	} else {
@@ -756,14 +764,15 @@ struct neigh_node *batadv_find_router(struct bat_priv *bat_priv,
 	}
 
 	/* with less than 2 candidates, we can't do any
-	 * bonding and prefer the original router. */
+	 * bonding and prefer the original router.
+	 */
 	if (atomic_read(&primary_orig_node->bond_candidates) < 2)
 		goto return_router;
 
 	/* all nodes between should choose a candidate which
 	 * is is not on the interface where the packet came
-	 * in. */
-
+	 * in.
+	 */
 	batadv_neigh_node_free_ref(router);
 
 	if (bonding_enabled)
@@ -1089,7 +1098,8 @@ int batadv_recv_bcast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 		goto spin_unlock;
 
 	/* mark broadcast in flood history, update window position
-	 * if required. */
+	 * if required.
+	 */
 	if (batadv_bit_get_packet(bat_priv, orig_node->bcast_bits, seq_diff, 1))
 		orig_node->last_bcast_seqno = ntohl(bcast_packet->seqno);
 
@@ -1165,6 +1175,7 @@ int batadv_recv_vis_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 	}
 
 	/* We take a copy of the data in the packet, so we should
-	   always free the skbuf. */
+	 * always free the skbuf.
+	 */
 	return NET_RX_DROP;
 }
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index 4652f0c..c3fd219 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
@@ -16,7 +15,6 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
 #ifndef _NET_BATMAN_ADV_ROUTING_H_
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 1a0f7c3..2c92a32 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
@@ -16,7 +15,6 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
 #include "main.h"
@@ -32,7 +30,8 @@
 static void send_outstanding_bcast_packet(struct work_struct *work);
 
 /* send out an already prepared packet to the given address via the
- * specified batman interface */
+ * specified batman interface
+ */
 int batadv_send_skb_packet(struct sk_buff *skb, struct hard_iface *hard_iface,
 			   const uint8_t *dst_addr)
 {
@@ -69,8 +68,8 @@ int batadv_send_skb_packet(struct sk_buff *skb, struct hard_iface *hard_iface,
 
 	/* dev_queue_xmit() returns a negative result on error.	 However on
 	 * congestion and traffic shaping, it drops and returns NET_XMIT_DROP
-	 * (which is > 0). This will not be treated as an error. */
-
+	 * (which is > 0). This will not be treated as an error.
+	 */
 	return dev_queue_xmit(skb);
 send_skb_err:
 	kfree_skb(skb);
@@ -85,8 +84,7 @@ void batadv_schedule_bat_ogm(struct hard_iface *hard_iface)
 	    (hard_iface->if_status == IF_TO_BE_REMOVED))
 		return;
 
-	/**
-	 * the interface gets activated here to avoid race conditions between
+	/* the interface gets activated here to avoid race conditions between
 	 * the moment of activating the interface in
 	 * hardif_activate_interface() where the originator mac is set and
 	 * outdated packets (especially uninitialized mac addresses) in the
@@ -132,7 +130,8 @@ static void _add_bcast_packet_to_list(struct bat_priv *bat_priv,
  * errors.
  *
  * The skb is not consumed, so the caller should make sure that the
- * skb is freed. */
+ * skb is freed.
+ */
 int batadv_add_bcast_packet_to_list(struct bat_priv *bat_priv,
 				    const struct sk_buff *skb,
 				    unsigned long delay)
@@ -249,8 +248,7 @@ void batadv_send_outstanding_bat_ogm_packet(struct work_struct *work)
 
 	bat_priv->bat_algo_ops->bat_ogm_emit(forw_packet);
 
-	/**
-	 * we have to have at least one packet in the queue
+	/* we have to have at least one packet in the queue
 	 * to determine the queues wake up time unless we are
 	 * shutting down
 	 */
@@ -285,8 +283,7 @@ void batadv_purge_outstanding_packets(struct bat_priv *bat_priv,
 	hlist_for_each_entry_safe(forw_packet, tmp_node, safe_tmp_node,
 				  &bat_priv->forw_bcast_list, list) {
 
-		/**
-		 * if purge_outstanding_packets() was called with an argument
+		/* if purge_outstanding_packets() was called with an argument
 		 * we delete only packets belonging to the given interface
 		 */
 		if ((hard_iface) &&
@@ -295,8 +292,7 @@ void batadv_purge_outstanding_packets(struct bat_priv *bat_priv,
 
 		spin_unlock_bh(&bat_priv->forw_bcast_list_lock);
 
-		/**
-		 * send_outstanding_bcast_packet() will lock the list to
+		/* send_outstanding_bcast_packet() will lock the list to
 		 * delete the item from the list
 		 */
 		pending = cancel_delayed_work_sync(&forw_packet->delayed_work);
@@ -314,8 +310,7 @@ void batadv_purge_outstanding_packets(struct bat_priv *bat_priv,
 	hlist_for_each_entry_safe(forw_packet, tmp_node, safe_tmp_node,
 				  &bat_priv->forw_bat_list, list) {
 
-		/**
-		 * if purge_outstanding_packets() was called with an argument
+		/* if purge_outstanding_packets() was called with an argument
 		 * we delete only packets belonging to the given interface
 		 */
 		if ((hard_iface) &&
@@ -324,8 +319,7 @@ void batadv_purge_outstanding_packets(struct bat_priv *bat_priv,
 
 		spin_unlock_bh(&bat_priv->forw_bat_list_lock);
 
-		/**
-		 * send_outstanding_bat_packet() will lock the list to
+		/* send_outstanding_bat_packet() will lock the list to
 		 * delete the item from the list
 		 */
 		pending = cancel_delayed_work_sync(&forw_packet->delayed_work);
diff --git a/net/batman-adv/send.h b/net/batman-adv/send.h
index 452e8df..e3ac75b 100644
--- a/net/batman-adv/send.h
+++ b/net/batman-adv/send.h
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
@@ -16,7 +15,6 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
 #ifndef _NET_BATMAN_ADV_SEND_H_
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 994b2b8..0658781 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
@@ -16,7 +15,6 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
 #include "main.h"
@@ -65,8 +63,7 @@ int batadv_skb_head_push(struct sk_buff *skb, unsigned int len)
 {
 	int result;
 
-	/**
-	 * TODO: We must check if we can release all references to non-payload
+	/* TODO: We must check if we can release all references to non-payload
 	 * data using skb_header_release in our skbs to allow skb_cow_header to
 	 * work optimally. This means that those skbs are not allowed to read
 	 * or write any data which is before the current position of skb->data
@@ -180,14 +177,16 @@ static int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
 		switch (atomic_read(&bat_priv->gw_mode)) {
 		case GW_MODE_SERVER:
 			/* gateway servers should not send dhcp
-			 * requests into the mesh */
+			 * requests into the mesh
+			 */
 			ret = batadv_gw_is_dhcp_target(skb, &header_len);
 			if (ret)
 				goto dropped;
 			break;
 		case GW_MODE_CLIENT:
 			/* gateway clients should send dhcp requests
-			 * via unicast to their gateway */
+			 * via unicast to their gateway
+			 */
 			ret = batadv_gw_is_dhcp_target(skb, &header_len);
 			if (ret)
 				do_bcast = false;
@@ -215,7 +214,8 @@ static int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
 		bcast_packet->header.packet_type = BAT_BCAST;
 
 		/* hw address of first interface is the orig mac because only
-		 * this mac is known throughout the mesh */
+		 * this mac is known throughout the mesh
+		 */
 		memcpy(bcast_packet->orig,
 		       primary_if->net_dev->dev_addr, ETH_ALEN);
 
@@ -226,7 +226,8 @@ static int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
 		batadv_add_bcast_packet_to_list(bat_priv, skb, 1);
 
 		/* a copy is stored in the bcast list, therefore removing
-		 * the original skb. */
+		 * the original skb.
+		 */
 		kfree_skb(skb);
 
 	/* unicast packet */
@@ -294,9 +295,10 @@ void batadv_interface_rx(struct net_device *soft_iface,
 
 	/* should not be necessary anymore as we use skb_pull_rcsum()
 	 * TODO: please verify this and remove this TODO
-	 * -- Dec 21st 2009, Simon Wunderlich */
+	 * -- Dec 21st 2009, Simon Wunderlich
+	 */
 
-/*	skb->ip_summed = CHECKSUM_UNNECESSARY;*/
+	/* skb->ip_summed = CHECKSUM_UNNECESSARY; */
 
 	bat_priv->stats.rx_packets++;
 	bat_priv->stats.rx_bytes += skb->len + ETH_HLEN;
@@ -341,8 +343,7 @@ static void interface_setup(struct net_device *dev)
 	dev->destructor = free_netdev;
 	dev->tx_queue_len = 0;
 
-	/**
-	 * can't call min_mtu, because the needed variables
+	/* can't call min_mtu, because the needed variables
 	 * have not been initialized yet
 	 */
 	dev->mtu = ETH_DATA_LEN;
diff --git a/net/batman-adv/soft-interface.h b/net/batman-adv/soft-interface.h
index 7e2bfaf..2711ba5 100644
--- a/net/batman-adv/soft-interface.h
+++ b/net/batman-adv/soft-interface.h
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner
  *
@@ -16,7 +15,6 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
 #ifndef _NET_BATMAN_ADV_SOFT_INTERFACE_H_
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 66e11b5..5180d50 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich, Antonio Quartulli
  *
@@ -16,7 +15,6 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
 #include "main.h"
@@ -232,7 +230,8 @@ void batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 
 	/* The local entry has to be marked as NEW to avoid to send it in
 	 * a full table response going out before the next ttvn increment
-	 * (consistency check) */
+	 * (consistency check)
+	 */
 	tt_local_entry->common.flags |= TT_CLIENT_NEW;
 
 	hash_added = hash_add(bat_priv->tt_local_hash, compare_tt, choose_orig,
@@ -437,7 +436,8 @@ static void tt_local_set_pending(struct bat_priv *bat_priv,
 
 	/* The local client has to be marked as "pending to be removed" but has
 	 * to be kept in the table in order to send it in a full table
-	 * response issued before the net ttvn increment (consistency check) */
+	 * response issued before the net ttvn increment (consistency check)
+	 */
 	tt_local_entry->common.flags |= TT_CLIENT_PENDING;
 
 	bat_dbg(DBG_TT, bat_priv,
@@ -898,8 +898,8 @@ static void tt_global_del(struct bat_priv *bat_priv,
 	 *    If there are other originators left, we directly delete
 	 *    the originator.
 	 * 2) the client roamed to us => we can directly delete
-	 *    the global entry, since it is useless now. */
-
+	 *    the global entry, since it is useless now.
+	 */
 	tt_local_entry = tt_local_hash_find(bat_priv,
 					    tt_global_entry->common.addr);
 	if (tt_local_entry) {
@@ -1072,7 +1072,8 @@ struct orig_node *batadv_transtable_search(struct bat_priv *bat_priv,
 		goto out;
 
 	/* check whether the clients should not communicate due to AP
-	 * isolation */
+	 * isolation
+	 */
 	if (tt_local_entry && _is_ap_isolated(tt_local_entry, tt_global_entry))
 		goto out;
 
@@ -1171,7 +1172,8 @@ static uint16_t batadv_tt_local_crc(struct bat_priv *bat_priv)
 		hlist_for_each_entry_rcu(tt_common_entry, node,
 					 head, hash_entry) {
 			/* not yet committed clients have not to be taken into
-			 * account while computing the CRC */
+			 * account while computing the CRC
+			 */
 			if (tt_common_entry->flags & TT_CLIENT_NEW)
 				continue;
 			total_one = 0;
@@ -1208,7 +1210,8 @@ static void tt_save_orig_buffer(struct bat_priv *bat_priv,
 	uint16_t tt_buff_len = batadv_tt_len(tt_num_changes);
 
 	/* Replace the old buffer only if I received something in the
-	 * last OGM (the OGM could carry no changes) */
+	 * last OGM (the OGM could carry no changes)
+	 */
 	spin_lock_bh(&orig_node->tt_buff_lock);
 	if (tt_buff_len > 0) {
 		kfree(orig_node->tt_buff);
@@ -1237,7 +1240,8 @@ static void tt_req_purge(struct bat_priv *bat_priv)
 }
 
 /* returns the pointer to the new tt_req_node struct if no request
- * has already been issued for this orig_node, NULL otherwise */
+ * has already been issued for this orig_node, NULL otherwise
+ */
 static struct tt_req_node *new_tt_req_node(struct bat_priv *bat_priv,
 					  struct orig_node *orig_node)
 {
@@ -1347,7 +1351,8 @@ static struct sk_buff *tt_response_fill_table(uint16_t tt_len, uint8_t ttvn,
 	rcu_read_unlock();
 
 	/* store in the message the number of entries we have successfully
-	 * copied */
+	 * copied
+	 */
 	tt_response->tt_data = htons(tt_count);
 
 out:
@@ -1370,7 +1375,8 @@ static int send_tt_request(struct bat_priv *bat_priv,
 		goto out;
 
 	/* The new tt_req will be issued only if I'm not waiting for a
-	 * reply from the same orig_node yet */
+	 * reply from the same orig_node yet
+	 */
 	tt_req_node = new_tt_req_node(bat_priv, dst_orig_node);
 	if (!tt_req_node)
 		goto out;
@@ -1478,7 +1484,8 @@ static bool send_other_tt_response(struct bat_priv *bat_priv,
 		full_table = false;
 
 	/* In this version, fragmentation is not implemented, then
-	 * I'll send only one packet with as much TT entries as I can */
+	 * I'll send only one packet with as much TT entries as I can
+	 */
 	if (!full_table) {
 		spin_lock_bh(&req_dst_orig_node->tt_buff_lock);
 		tt_len = req_dst_orig_node->tt_buff_len;
@@ -1590,7 +1597,8 @@ static bool send_my_tt_response(struct bat_priv *bat_priv,
 		goto out;
 
 	/* If the full table has been explicitly requested or the gap
-	 * is too big send the whole local translation table */
+	 * is too big send the whole local translation table
+	 */
 	if (tt_request->flags & TT_FULL_TABLE || my_ttvn != req_ttvn ||
 	    !bat_priv->tt_buff)
 		full_table = true;
@@ -1598,7 +1606,8 @@ static bool send_my_tt_response(struct bat_priv *bat_priv,
 		full_table = false;
 
 	/* In this version, fragmentation is not implemented, then
-	 * I'll send only one packet with as much TT entries as I can */
+	 * I'll send only one packet with as much TT entries as I can
+	 */
 	if (!full_table) {
 		spin_lock_bh(&bat_priv->tt_buff_lock);
 		tt_len = bat_priv->tt_buff_len;
@@ -1766,7 +1775,8 @@ bool batadv_is_my_client(struct bat_priv *bat_priv, const uint8_t *addr)
 	if (!tt_local_entry)
 		goto out;
 	/* Check if the client has been logically deleted (but is kept for
-	 * consistency purpose) */
+	 * consistency purpose)
+	 */
 	if (tt_local_entry->common.flags & TT_CLIENT_PENDING)
 		goto out;
 	ret = true;
@@ -1817,7 +1827,8 @@ void batadv_handle_tt_response(struct bat_priv *bat_priv,
 	/* Recalculate the CRC for this orig_node and store it */
 	orig_node->tt_crc = tt_global_crc(bat_priv, orig_node);
 	/* Roaming phase is over: tables are in sync again. I can
-	 * unset the flag */
+	 * unset the flag
+	 */
 	orig_node->tt_poss_change = false;
 out:
 	if (orig_node)
@@ -1874,7 +1885,8 @@ static void tt_roam_purge(struct bat_priv *bat_priv)
  * maximum number of possible roaming phases. In this case the ROAMING_ADV
  * will not be sent.
  *
- * returns true if the ROAMING_ADV can be sent, false otherwise */
+ * returns true if the ROAMING_ADV can be sent, false otherwise
+ */
 static bool tt_check_roam_count(struct bat_priv *bat_priv,
 				uint8_t *client)
 {
@@ -1883,7 +1895,8 @@ static bool tt_check_roam_count(struct bat_priv *bat_priv,
 
 	spin_lock_bh(&bat_priv->tt_roam_list_lock);
 	/* The new tt_req will be issued only if I'm not waiting for a
-	 * reply from the same orig_node yet */
+	 * reply from the same orig_node yet
+	 */
 	list_for_each_entry(tt_roam_node, &bat_priv->tt_roam_list, list) {
 		if (!compare_eth(tt_roam_node->addr, client))
 			continue;
@@ -1926,7 +1939,8 @@ static void send_roam_adv(struct bat_priv *bat_priv, uint8_t *client,
 	struct hard_iface *primary_if;
 
 	/* before going on we have to check whether the client has
-	 * already roamed to us too many times */
+	 * already roamed to us too many times
+	 */
 	if (!tt_check_roam_count(bat_priv, client))
 		goto out;
 
@@ -2000,7 +2014,8 @@ void batadv_tt_free(struct bat_priv *bat_priv)
 }
 
 /* This function will enable or disable the specified flags for all the entries
- * in the given hash table and returns the number of modified entries */
+ * in the given hash table and returns the number of modified entries
+ */
 static uint16_t tt_set_flags(struct hashtable_t *hash, uint16_t flags,
 			     bool enable)
 {
@@ -2172,12 +2187,14 @@ void batadv_tt_update_orig(struct bat_priv *bat_priv,
 		return;
 
 	/* orig table not initialised AND first diff is in the OGM OR the ttvn
-	 * increased by one -> we can apply the attached changes */
+	 * increased by one -> we can apply the attached changes
+	 */
 	if ((!orig_node->tt_initialised && ttvn == 1) ||
 	    ttvn - orig_ttvn == 1) {
 		/* the OGM could not contain the changes due to their size or
 		 * because they have already been sent TT_OGM_APPEND_MAX times.
-		 * In this case send a tt request */
+		 * In this case send a tt request
+		 */
 		if (!tt_num_changes) {
 			full_table = false;
 			goto request_table;
@@ -2188,7 +2205,8 @@ void batadv_tt_update_orig(struct bat_priv *bat_priv,
 
 		/* Even if we received the precomputed crc with the OGM, we
 		 * prefer to recompute it to spot any possible inconsistency
-		 * in the global table */
+		 * in the global table
+		 */
 		orig_node->tt_crc = tt_global_crc(bat_priv, orig_node);
 
 		/* The ttvn alone is not enough to guarantee consistency
@@ -2198,17 +2216,19 @@ void batadv_tt_update_orig(struct bat_priv *bat_priv,
 		 * consistent or not. E.g. a node could disconnect while its
 		 * ttvn is X and reconnect on ttvn = X + TTVN_MAX: in this case
 		 * checking the CRC value is mandatory to detect the
-		 * inconsistency */
+		 * inconsistency
+		 */
 		if (orig_node->tt_crc != tt_crc)
 			goto request_table;
 
 		/* Roaming phase is over: tables are in sync again. I can
-		 * unset the flag */
+		 * unset the flag
+		 */
 		orig_node->tt_poss_change = false;
 	} else {
 		/* if we missed more than one change or our tables are not
-		 * in sync anymore -> request fresh tt data */
-
+		 * in sync anymore -> request fresh tt data
+		 */
 		if (!orig_node->tt_initialised || ttvn != orig_ttvn ||
 		    orig_node->tt_crc != tt_crc) {
 request_table:
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
index fe1281a..7edc9df 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich, Antonio Quartulli
  *
@@ -16,7 +15,6 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
 #ifndef _NET_BATMAN_ADV_TRANSLATION_TABLE_H_
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index bf71d52..053c5d4 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2007-2012 B.A.T.M.A.N. contributors:
  *
  * Marek Lindner, Simon Wunderlich
  *
@@ -16,11 +15,8 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
-
-
 #ifndef _NET_BATMAN_ADV_TYPES_H_
 #define _NET_BATMAN_ADV_TYPES_H_
 
@@ -49,8 +45,7 @@ struct hard_iface {
 	struct rcu_head rcu;
 };
 
-/**
- *	orig_node - structure for orig_list maintaining nodes of mesh
+/*	orig_node - structure for orig_list maintaining nodes of mesh
  *	@primary_addr: hosts primary interface address
  *	@last_seen: when last packet from this node was received
  *	@bcast_seqno_reset: time when the broadcast seqno window was reset
@@ -86,7 +81,8 @@ struct orig_node {
 	 * If true, then I sent a Roaming_adv to this orig_node and I have to
 	 * inspect every packet directed to it to check whether it is still
 	 * the true destination or not. This flag will be reset to false as
-	 * soon as I receive a new TTVN from this orig_node */
+	 * soon as I receive a new TTVN from this orig_node
+	 */
 	bool tt_poss_change;
 	uint32_t last_real_seqno;
 	uint8_t last_ttl;
@@ -101,7 +97,8 @@ struct orig_node {
 	struct bat_priv *bat_priv;
 	unsigned long last_frag_packet;
 	/* ogm_cnt_lock protects: bcast_own, bcast_own_sum,
-	 * neigh_node->real_bits, neigh_node->real_packet_count */
+	 * neigh_node->real_bits, neigh_node->real_packet_count
+	 */
 	spinlock_t ogm_cnt_lock;
 	/* bcast_seqno_lock protects bcast_bits, last_bcast_seqno */
 	spinlock_t bcast_seqno_lock;
@@ -118,8 +115,7 @@ struct gw_node {
 	struct rcu_head rcu;
 };
 
-/**
- *	neigh_node
+/*	neigh_node
  *	@last_seen: when last packet via this neighbor was received
  */
 struct neigh_node {
@@ -191,7 +187,8 @@ struct bat_priv {
 	 * If true, then I received a Roaming_adv and I have to inspect every
 	 * packet directed to me to check whether I am still the true
 	 * destination or not. This flag will be reset to false as soon as I
-	 * increase my TTVN */
+	 * increase my TTVN
+	 */
 	bool tt_poss_change;
 	char num_ifaces;
 	struct debug_log *debug_log;
@@ -326,8 +323,7 @@ struct tt_roam_node {
 	struct list_head list;
 };
 
-/**
- *	forw_packet - structure for forw_list maintaining packets to be
+/*	forw_packet - structure for forw_list maintaining packets to be
  *	              send/forwarded
  */
 struct forw_packet {
@@ -369,7 +365,8 @@ struct frag_packet_list_entry {
 struct vis_info {
 	unsigned long first_seen;
 	/* list of server-neighbors we received a vis-packet
-	 * from.  we should not reply to them. */
+	 * from.  we should not reply to them.
+	 */
 	struct list_head recv_list;
 	struct list_head send_list;
 	struct kref refcount;
@@ -377,7 +374,7 @@ struct vis_info {
 	struct bat_priv *bat_priv;
 	/* this packet might be part of the vis send queue. */
 	struct sk_buff *skb_packet;
-	/* vis_info may follow here*/
+	/* vis_info may follow here */
 } __packed;
 
 struct vis_info_entry {
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index e9d3bdd..b2b76df 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2010-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2010-2012 B.A.T.M.A.N. contributors:
  *
  * Andreas Langer
  *
@@ -16,7 +15,6 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
 #include "main.h"
@@ -300,12 +298,12 @@ int batadv_unicast_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv)
 	}
 
 	/* check for tt host - increases orig_node refcount.
-	 * returns NULL in case of AP isolation */
+	 * returns NULL in case of AP isolation
+	 */
 	orig_node = batadv_transtable_search(bat_priv, ethhdr->h_source,
 					     ethhdr->h_dest);
 find_router:
-	/**
-	 * find_router():
+	/* find_router():
 	 *  - if orig_node is NULL it returns NULL
 	 *  - increases neigh_nodes refcount if found.
 	 */
diff --git a/net/batman-adv/unicast.h b/net/batman-adv/unicast.h
index 657fe73..87f8f89 100644
--- a/net/batman-adv/unicast.h
+++ b/net/batman-adv/unicast.h
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2010-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2010-2012 B.A.T.M.A.N. contributors:
  *
  * Andreas Langer
  *
@@ -16,7 +15,6 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
 #ifndef _NET_BATMAN_ADV_UNICAST_H_
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index 83c931f..20eef04 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2008-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2008-2012 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich
  *
@@ -16,7 +15,6 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
 #include "main.h"
@@ -64,8 +62,9 @@ static int vis_info_cmp(const struct hlist_node *node, const void *data2)
 	return compare_eth(p1->vis_orig, p2->vis_orig);
 }
 
-/* hash function to choose an entry in a hash table of given size */
-/* hash algorithm from http://en.wikipedia.org/wiki/Hash_table */
+/* hash function to choose an entry in a hash table of given size
+ * hash algorithm from http://en.wikipedia.org/wiki/Hash_table
+ */
 static uint32_t vis_info_choose(const void *data, uint32_t size)
 {
 	const struct vis_info *vis_info = data;
@@ -118,7 +117,8 @@ static struct vis_info *vis_hash_find(struct bat_priv *bat_priv,
 }
 
 /* insert interface to the list of interfaces of one originator, if it
- * does not already exist in the list */
+ * does not already exist in the list
+ */
 static void vis_data_insert_interface(const uint8_t *interface,
 				      struct hlist_head *if_list,
 				      bool primary)
@@ -334,7 +334,8 @@ out:
 }
 
 /* add the info packet to the send list, if it was not
- * already linked in. */
+ * already linked in.
+ */
 static void send_list_add(struct bat_priv *bat_priv, struct vis_info *info)
 {
 	if (list_empty(&info->send_list)) {
@@ -344,7 +345,8 @@ static void send_list_add(struct bat_priv *bat_priv, struct vis_info *info)
 }
 
 /* delete the info packet from the send list, if it was
- * linked in. */
+ * linked in.
+ */
 static void send_list_del(struct vis_info *info)
 {
 	if (!list_empty(&info->send_list)) {
@@ -388,7 +390,8 @@ static int recv_list_is_in(struct bat_priv *bat_priv,
 
 /* try to add the packet to the vis_hash. return NULL if invalid (e.g. too old,
  * broken.. ).	vis hash must be locked outside.  is_new is set when the packet
- * is newer than old entries in the hash. */
+ * is newer than old entries in the hash.
+ */
 static struct vis_info *add_packet(struct bat_priv *bat_priv,
 				   struct vis_packet *vis_packet,
 				   int vis_info_len, int *is_new,
@@ -500,7 +503,8 @@ void batadv_receive_server_sync_packet(struct bat_priv *bat_priv,
 		goto end;
 
 	/* only if we are server ourselves and packet is newer than the one in
-	 * hash.*/
+	 * hash.
+	 */
 	if (vis_server == VIS_TYPE_SERVER_SYNC && is_new)
 		send_list_add(bat_priv, info);
 end:
@@ -554,7 +558,8 @@ end:
 /* Walk the originators and find the VIS server with the best tq. Set the packet
  * address to its address and return the best_tq.
  *
- * Must be called with the originator hash locked */
+ * Must be called with the originator hash locked
+ */
 static int find_best_vis_server(struct bat_priv *bat_priv,
 				struct vis_info *info)
 {
@@ -605,7 +610,8 @@ static bool vis_packet_full(const struct vis_info *info)
 }
 
 /* generates a packet of own vis data,
- * returns 0 on success, -1 if no packet could be generated */
+ * returns 0 on success, -1 if no packet could be generated
+ */
 static int generate_vis_packet(struct bat_priv *bat_priv)
 {
 	struct hashtable_t *hash = bat_priv->orig_hash;
@@ -703,7 +709,8 @@ unlock:
 }
 
 /* free old vis packets. Must be called with this vis_hash_lock
- * held */
+ * held
+ */
 static void purge_vis_packets(struct bat_priv *bat_priv)
 {
 	uint32_t i;
@@ -762,7 +769,8 @@ static void broadcast_vis_packet(struct bat_priv *bat_priv,
 				continue;
 
 			/* don't send it if we already received the packet from
-			 * this node. */
+			 * this node.
+			 */
 			if (recv_list_is_in(bat_priv, &info->recv_list,
 					    orig_node->orig)) {
 				batadv_neigh_node_free_ref(router);
@@ -879,7 +887,8 @@ static void send_vis_packets(struct work_struct *work)
 }
 
 /* init the vis server. this may only be called when if_list is already
- * initialized (e.g. bat0 is initialized, interfaces have been added) */
+ * initialized (e.g. bat0 is initialized, interfaces have been added)
+ */
 int batadv_vis_init(struct bat_priv *bat_priv)
 {
 	struct vis_packet *packet;
diff --git a/net/batman-adv/vis.h b/net/batman-adv/vis.h
index 932514e..dad5958 100644
--- a/net/batman-adv/vis.h
+++ b/net/batman-adv/vis.h
@@ -1,5 +1,4 @@
-/*
- * Copyright (C) 2008-2012 B.A.T.M.A.N. contributors:
+/* Copyright (C) 2008-2012 B.A.T.M.A.N. contributors:
  *
  * Simon Wunderlich, Marek Lindner
  *
@@ -16,14 +15,13 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
- *
  */
 
 #ifndef _NET_BATMAN_ADV_VIS_H_
 #define _NET_BATMAN_ADV_VIS_H_
 
-#define VIS_TIMEOUT		200000	/* timeout of vis packets
-					 * in miliseconds */
+/* timeout of vis packets in miliseconds */
+#define VIS_TIMEOUT		200000
 
 int batadv_vis_seq_print_text(struct seq_file *seq, void *offset);
 void batadv_receive_server_sync_packet(struct bat_priv *bat_priv,
-- 
1.7.9.4
