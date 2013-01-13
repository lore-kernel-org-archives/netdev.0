From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 09/15] batman-adv: remove useless blank lines before and after brackets
Date: Mon, 14 Jan 2013 09:41:14 +1000
Message-ID: <1358120480-25960-10-git-send-email-ordex@autistici.org>
References: <1358120480-25960-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from diserzione.investici.org ([82.221.99.153]:49744 "EHLO
	diserzione.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755732Ab3AMXnE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2013 18:43:04 -0500
In-Reply-To: <1358120480-25960-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/bat_iv_ogm.c            | 6 ------
 net/batman-adv/bridge_loop_avoidance.c | 4 ----
 net/batman-adv/debugfs.c               | 1 -
 net/batman-adv/originator.c            | 3 ---
 net/batman-adv/routing.c               | 4 ----
 net/batman-adv/send.c                  | 2 --
 net/batman-adv/translation-table.c     | 7 -------
 net/batman-adv/unicast.c               | 2 --
 8 files changed, 29 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index f2a3649..d90e925 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -183,7 +183,6 @@ static void batadv_iv_ogm_send_to_if(struct batadv_forw_packet *forw_packet,
 	/* adjust all flags and log packets */
 	while (batadv_iv_ogm_aggr_packet(buff_pos, forw_packet->packet_len,
 					 batadv_ogm_packet->tt_num_changes)) {
-
 		/* we might have aggregated direct link packets with an
 		 * ordinary base packet
 		 */
@@ -261,7 +260,6 @@ static void batadv_iv_ogm_emit(struct batadv_forw_packet *forw_packet)
 	 */
 	if ((directlink && (batadv_ogm_packet->header.ttl == 1)) ||
 	    (forw_packet->own && (forw_packet->if_incoming != primary_if))) {
-
 		/* FIXME: what about aggregated packets ? */
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "%s packet (originator %pM, seqno %u, TTL %d) on interface %s [%pM]\n",
@@ -325,7 +323,6 @@ batadv_iv_ogm_can_aggregate(const struct batadv_ogm_packet *new_bat_ogm_packet,
 	if (time_before(send_time, forw_packet->send_time) &&
 	    time_after_eq(aggregation_end_time, forw_packet->send_time) &&
 	    (aggregated_bytes <= BATADV_MAX_AGGREGATION_BYTES)) {
-
 		/* check aggregation compatibility
 		 * -> direct link packets are broadcasted on
 		 *    their interface only
@@ -815,7 +812,6 @@ static int batadv_iv_ogm_calc_tq(struct batadv_orig_node *orig_node,
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(tmp_neigh_node, node,
 				 &orig_neigh_node->neigh_list, list) {
-
 		if (!batadv_compare_eth(tmp_neigh_node->addr,
 					orig_neigh_node->orig))
 			continue;
@@ -949,7 +945,6 @@ batadv_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(tmp_neigh_node, node,
 				 &orig_node->neigh_list, list) {
-
 		is_duplicate |= batadv_test_bit(tmp_neigh_node->real_bits,
 						orig_node->last_real_seqno,
 						seqno);
@@ -1223,7 +1218,6 @@ static void batadv_iv_ogm_process(const struct ethhdr *ethhdr,
 
 	/* is single hop (direct) neighbor */
 	if (is_single_hop_neigh) {
-
 		/* mark direct link on incoming interface */
 		batadv_iv_ogm_forward(orig_node, ethhdr, batadv_ogm_packet,
 				      is_single_hop_neigh,
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index ec12c79..724adf0 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -235,7 +235,6 @@ batadv_bla_del_backbone_claims(struct batadv_backbone_gw *backbone_gw)
 		spin_lock_bh(list_lock);
 		hlist_for_each_entry_safe(claim, node, node_tmp,
 					  head, hash_entry) {
-
 			if (claim->backbone_gw != backbone_gw)
 				continue;
 
@@ -338,7 +337,6 @@ static void batadv_bla_send_claim(struct batadv_priv *bat_priv, uint8_t *mac,
 			   "bla_send_claim(): REQUEST of %pM to %pMon vid %d\n",
 			   ethhdr->h_source, ethhdr->h_dest, vid);
 		break;
-
 	}
 
 	if (vid != -1)
@@ -539,7 +537,6 @@ static void batadv_bla_send_announce(struct batadv_priv *bat_priv,
 
 	batadv_bla_send_claim(bat_priv, mac, backbone_gw->vid,
 			      BATADV_CLAIM_TYPE_ANNOUNCE);
-
 }
 
 /**
@@ -598,7 +595,6 @@ static void batadv_bla_add_claim(struct batadv_priv *bat_priv,
 
 		claim->backbone_gw->crc ^= crc16(0, claim->addr, ETH_ALEN);
 		batadv_backbone_gw_free_ref(claim->backbone_gw);
-
 	}
 	/* set (new) backbone gw */
 	atomic_inc(&backbone_gw->refcount);
diff --git a/net/batman-adv/debugfs.c b/net/batman-adv/debugfs.c
index 6f58ddd..0049837 100644
--- a/net/batman-adv/debugfs.c
+++ b/net/batman-adv/debugfs.c
@@ -164,7 +164,6 @@ static ssize_t batadv_log_read(struct file *file, char __user *buf,
 
 		buf++;
 		i++;
-
 	}
 
 	spin_unlock_bh(&debug_log->lock);
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 109081c4..fa88b2b 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -184,7 +184,6 @@ void batadv_originator_free(struct batadv_priv *bat_priv)
 		spin_lock_bh(list_lock);
 		hlist_for_each_entry_safe(orig_node, node, node_tmp,
 					  head, hash_entry) {
-
 			hlist_del_rcu(node);
 			batadv_orig_node_free_ref(orig_node);
 		}
@@ -291,7 +290,6 @@ batadv_purge_orig_neighbors(struct batadv_priv *bat_priv,
 	/* for all neighbors towards this originator ... */
 	hlist_for_each_entry_safe(neigh_node, node, node_tmp,
 				  &orig_node->neigh_list, list) {
-
 		last_seen = neigh_node->last_seen;
 		if_incoming = neigh_node->if_incoming;
 
@@ -299,7 +297,6 @@ batadv_purge_orig_neighbors(struct batadv_priv *bat_priv,
 		    (if_incoming->if_status == BATADV_IF_INACTIVE) ||
 		    (if_incoming->if_status == BATADV_IF_NOT_IN_USE) ||
 		    (if_incoming->if_status == BATADV_IF_TO_BE_REMOVED)) {
-
 			if ((if_incoming->if_status == BATADV_IF_INACTIVE) ||
 			    (if_incoming->if_status == BATADV_IF_NOT_IN_USE) ||
 			    (if_incoming->if_status == BATADV_IF_TO_BE_REMOVED))
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 1aa1722..db89238 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -80,7 +80,6 @@ static void _batadv_update_route(struct batadv_priv *bat_priv,
 
 	/* route added */
 	} else if ((!curr_router) && (neigh_node)) {
-
 		batadv_dbg(BATADV_DBG_ROUTES, bat_priv,
 			   "Adding route towards: %pM (via %pM)\n",
 			   orig_node->orig, neigh_node->addr);
@@ -172,7 +171,6 @@ void batadv_bonding_candidate_add(struct batadv_orig_node *orig_node,
 	 */
 	hlist_for_each_entry_rcu(tmp_neigh_node, node,
 				 &orig_node->neigh_list, list) {
-
 		if (tmp_neigh_node == neigh_node)
 			continue;
 
@@ -836,7 +834,6 @@ static int batadv_route_unicast_packet(struct sk_buff *skb,
 	if (unicast_packet->header.packet_type == BATADV_UNICAST_FRAG &&
 	    batadv_frag_can_reassemble(skb,
 				       neigh_node->if_incoming->net_dev->mtu)) {
-
 		ret = batadv_frag_reassemble_skb(skb, bat_priv, &new_skb);
 
 		if (ret == NET_RX_DROP)
@@ -1103,7 +1100,6 @@ int batadv_recv_ucast_frag_packet(struct sk_buff *skb,
 
 	/* packet for me */
 	if (batadv_is_my_mac(unicast_packet->dest)) {
-
 		ret = batadv_frag_reassemble_skb(skb, bat_priv, &new_skb);
 
 		if (ret == NET_RX_DROP)
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 4425af9..89810ce 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -330,7 +330,6 @@ batadv_purge_outstanding_packets(struct batadv_priv *bat_priv,
 	spin_lock_bh(&bat_priv->forw_bcast_list_lock);
 	hlist_for_each_entry_safe(forw_packet, tmp_node, safe_tmp_node,
 				  &bat_priv->forw_bcast_list, list) {
-
 		/* if purge_outstanding_packets() was called with an argument
 		 * we delete only packets belonging to the given interface
 		 */
@@ -357,7 +356,6 @@ batadv_purge_outstanding_packets(struct batadv_priv *bat_priv,
 	spin_lock_bh(&bat_priv->forw_bat_list_lock);
 	hlist_for_each_entry_safe(forw_packet, tmp_node, safe_tmp_node,
 				  &bat_priv->forw_bat_list, list) {
-
 		/* if purge_outstanding_packets() was called with an argument
 		 * we delete only packets belonging to the given interface
 		 */
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index c6fd0b7..d4b27b6 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -116,7 +116,6 @@ batadv_tt_global_hash_find(struct batadv_priv *bat_priv, const void *data)
 					       struct batadv_tt_global_entry,
 					       common);
 	return tt_global_entry;
-
 }
 
 static void
@@ -256,7 +255,6 @@ static void batadv_tt_global_free(struct batadv_priv *bat_priv,
 	batadv_hash_remove(bat_priv->tt.global_hash, batadv_compare_tt,
 			   batadv_choose_orig, tt_global->common.addr);
 	batadv_tt_global_entry_free_ref(tt_global);
-
 }
 
 void batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
@@ -652,7 +650,6 @@ static void batadv_tt_local_purge(struct batadv_priv *bat_priv)
 		batadv_tt_local_purge_list(bat_priv, head);
 		spin_unlock_bh(list_lock);
 	}
-
 }
 
 static void batadv_tt_local_table_free(struct batadv_priv *bat_priv)
@@ -1079,7 +1076,6 @@ batadv_tt_global_del_orig_list(struct batadv_tt_global_entry *tt_global_entry)
 		batadv_tt_orig_list_entry_free_ref(orig_entry);
 	}
 	spin_unlock_bh(&tt_global_entry->list_lock);
-
 }
 
 static void
@@ -1855,7 +1851,6 @@ out:
 	if (!ret)
 		kfree_skb(skb);
 	return ret;
-
 }
 
 static bool
@@ -2382,7 +2377,6 @@ static void batadv_tt_local_purge_pending_clients(struct batadv_priv *bat_priv)
 		}
 		spin_unlock_bh(list_lock);
 	}
-
 }
 
 static int batadv_tt_commit_changes(struct batadv_priv *bat_priv,
@@ -2579,7 +2573,6 @@ bool batadv_tt_local_client_is_roaming(struct batadv_priv *bat_priv,
 	batadv_tt_local_entry_free_ref(tt_local_entry);
 out:
 	return ret;
-
 }
 
 bool batadv_tt_add_temporary_global_entry(struct batadv_priv *bat_priv,
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index 10aff49..f56bccf 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -133,7 +133,6 @@ batadv_frag_search_packet(struct list_head *head,
 	is_head = !!(up->flags & BATADV_UNI_FRAG_HEAD);
 
 	list_for_each_entry(tfp, head, list) {
-
 		if (!tfp->skb)
 			continue;
 
@@ -162,7 +161,6 @@ void batadv_frag_list_free(struct list_head *head)
 	struct batadv_frag_packet_list_entry *pf, *tmp_pf;
 
 	if (!list_empty(head)) {
-
 		list_for_each_entry_safe(pf, tmp_pf, head, list) {
 			kfree_skb(pf->skb);
 			list_del(&pf->list);
-- 
1.8.0.2
