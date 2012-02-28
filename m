From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Subject: [PATCH 8/8] batman-adv: Fix indentation of multiline
	statements
Date: Tue, 28 Feb 2012 19:39:35 +0800
Message-ID: <1330429175-23513-1-git-send-email-lindner_marek@yahoo.de>
References: <1330428748-23137-1-git-send-email-lindner_marek@yahoo.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1330428748-23137-1-git-send-email-lindner_marek-LWAfsSFWpa4@public.gmane.org>
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

Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
---
 net/batman-adv/bat_sysfs.c         |    4 ++--
 net/batman-adv/bitarray.c          |    8 ++++----
 net/batman-adv/gateway_client.c    |    2 +-
 net/batman-adv/gateway_common.c    |    4 ++--
 net/batman-adv/hard-interface.c    |   30 +++++++++++++++---------------
 net/batman-adv/originator.c        |    5 ++---
 net/batman-adv/routing.c           |    8 ++++----
 net/batman-adv/soft-interface.c    |    2 +-
 net/batman-adv/translation-table.c |   26 +++++++++++++-------------
 9 files changed, 44 insertions(+), 45 deletions(-)

diff --git a/net/batman-adv/bat_sysfs.c b/net/batman-adv/bat_sysfs.c
index 7317729..b00101d 100644
--- a/net/batman-adv/bat_sysfs.c
+++ b/net/batman-adv/bat_sysfs.c
@@ -321,11 +321,11 @@ static ssize_t store_gw_mode(struct kobject *kobj, struct attribute *attr,
 		gw_mode_tmp = GW_MODE_OFF;
 
 	if (strncmp(buff, GW_MODE_CLIENT_NAME,
-		   strlen(GW_MODE_CLIENT_NAME)) == 0)
+		    strlen(GW_MODE_CLIENT_NAME)) == 0)
 		gw_mode_tmp = GW_MODE_CLIENT;
 
 	if (strncmp(buff, GW_MODE_SERVER_NAME,
-		   strlen(GW_MODE_SERVER_NAME)) == 0)
+		    strlen(GW_MODE_SERVER_NAME)) == 0)
 		gw_mode_tmp = GW_MODE_SERVER;
 
 	if (gw_mode_tmp < 0) {
diff --git a/net/batman-adv/bitarray.c b/net/batman-adv/bitarray.c
index e63069d..6d0aa21 100644
--- a/net/batman-adv/bitarray.c
+++ b/net/batman-adv/bitarray.c
@@ -154,8 +154,8 @@ int bit_get_packet(void *priv, unsigned long *seq_bits,
 
 	/* sequence number is much newer, probably missed a lot of packets */
 
-	if ((seq_num_diff >= TQ_LOCAL_WINDOW_SIZE)
-		&& (seq_num_diff < EXPECTED_SEQNO_RANGE)) {
+	if ((seq_num_diff >= TQ_LOCAL_WINDOW_SIZE) &&
+	    (seq_num_diff < EXPECTED_SEQNO_RANGE)) {
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"We missed a lot of packets (%i) !\n",
 			seq_num_diff - 1);
@@ -170,8 +170,8 @@ int bit_get_packet(void *priv, unsigned long *seq_bits,
 	 * packet should be dropped without calling this function if the
 	 * seqno window is protected. */
 
-	if ((seq_num_diff <= -TQ_LOCAL_WINDOW_SIZE)
-		|| (seq_num_diff >= EXPECTED_SEQNO_RANGE)) {
+	if ((seq_num_diff <= -TQ_LOCAL_WINDOW_SIZE) ||
+	    (seq_num_diff >= EXPECTED_SEQNO_RANGE)) {
 
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"Other host probably restarted!\n");
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 65a77a1..0fa8e2d 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -629,7 +629,7 @@ bool gw_is_dhcp_target(struct sk_buff *skb, unsigned int *header_len)
 
 	/* check for bootp port */
 	if ((ntohs(ethhdr->h_proto) == ETH_P_IP) &&
-	     (ntohs(udphdr->dest) != 67))
+	    (ntohs(udphdr->dest) != 67))
 		return false;
 
 	if ((ntohs(ethhdr->h_proto) == ETH_P_IPV6) &&
diff --git a/net/batman-adv/gateway_common.c b/net/batman-adv/gateway_common.c
index 7f79e15..3ccb9c8 100644
--- a/net/batman-adv/gateway_common.c
+++ b/net/batman-adv/gateway_common.c
@@ -93,7 +93,7 @@ static bool parse_gw_bandwidth(struct net_device *net_dev, char *buff,
 			multi = 1024;
 
 		if ((strnicmp(tmp_ptr, "kbit", 4) == 0) ||
-			(multi > 1))
+		    (multi > 1))
 			*tmp_ptr = '\0';
 	}
 
@@ -118,7 +118,7 @@ static bool parse_gw_bandwidth(struct net_device *net_dev, char *buff,
 				multi = 1024;
 
 			if ((strnicmp(tmp_ptr, "kbit", 4) == 0) ||
-				(multi > 1))
+			    (multi > 1))
 				*tmp_ptr = '\0';
 		}
 
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 41826b9..409d027 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -341,23 +341,23 @@ int hardif_enable_interface(struct hard_iface *hard_iface,
 	if (atomic_read(&bat_priv->fragmentation) && hard_iface->net_dev->mtu <
 		ETH_DATA_LEN + BAT_HEADER_LEN)
 		bat_info(hard_iface->soft_iface,
-			"The MTU of interface %s is too small (%i) to handle "
-			"the transport of batman-adv packets. Packets going "
-			"over this interface will be fragmented on layer2 "
-			"which could impact the performance. Setting the MTU "
-			"to %zi would solve the problem.\n",
-			hard_iface->net_dev->name, hard_iface->net_dev->mtu,
-			ETH_DATA_LEN + BAT_HEADER_LEN);
+			 "The MTU of interface %s is too small (%i) to handle "
+			 "the transport of batman-adv packets. Packets going "
+			 "over this interface will be fragmented on layer2 "
+			 "which could impact the performance. Setting the MTU "
+			 "to %zi would solve the problem.\n",
+			 hard_iface->net_dev->name, hard_iface->net_dev->mtu,
+			 ETH_DATA_LEN + BAT_HEADER_LEN);
 
 	if (!atomic_read(&bat_priv->fragmentation) && hard_iface->net_dev->mtu <
 		ETH_DATA_LEN + BAT_HEADER_LEN)
 		bat_info(hard_iface->soft_iface,
-			"The MTU of interface %s is too small (%i) to handle "
-			"the transport of batman-adv packets. If you experience"
-			" problems getting traffic through try increasing the "
-			"MTU to %zi.\n",
-			hard_iface->net_dev->name, hard_iface->net_dev->mtu,
-			ETH_DATA_LEN + BAT_HEADER_LEN);
+			 "The MTU of interface %s is too small (%i) to handle "
+			 "the transport of batman-adv packets. If you "
+			 "experience problems getting traffic through try "
+			 "increasing the MTU to %zi.\n",
+			 hard_iface->net_dev->name, hard_iface->net_dev->mtu,
+			 ETH_DATA_LEN + BAT_HEADER_LEN);
 
 	if (hardif_is_iface_up(hard_iface))
 		hardif_activate_interface(hard_iface);
@@ -580,8 +580,8 @@ static int batman_skb_recv(struct sk_buff *skb, struct net_device *dev,
 		goto err_free;
 
 	/* expect a valid ethernet header here. */
-	if (unlikely(skb->mac_len != sizeof(struct ethhdr)
-				|| !skb_mac_header(skb)))
+	if (unlikely(skb->mac_len != sizeof(struct ethhdr) ||
+		     !skb_mac_header(skb)))
 		goto err_free;
 
 	if (!hard_iface->soft_iface)
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index c2e46b5..371cc93 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -143,7 +143,7 @@ static void orig_node_free_rcu(struct rcu_head *rcu)
 
 	frag_list_free(&orig_node->frag_list);
 	tt_global_del_orig(orig_node->bat_priv, orig_node,
-			    "originator timed out");
+			   "originator timed out");
 
 	kfree(orig_node->tt_buff);
 	kfree(orig_node->bcast_own);
@@ -333,9 +333,8 @@ static bool purge_orig_node(struct bat_priv *bat_priv,
 		return true;
 	} else {
 		if (purge_orig_neighbors(bat_priv, orig_node,
-							&best_neigh_node)) {
+					 &best_neigh_node))
 			update_route(bat_priv, orig_node, best_neigh_node);
-		}
 	}
 
 	return false;
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index cf9a2f6..f535155 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -72,7 +72,7 @@ static void _update_route(struct bat_priv *bat_priv,
 		bat_dbg(DBG_ROUTES, bat_priv, "Deleting route towards: %pM\n",
 			orig_node->orig);
 		tt_global_del_orig(bat_priv, orig_node,
-				    "Deleted route towards originator");
+				   "Deleted route towards originator");
 
 	/* route added */
 	} else if ((!curr_router) && (neigh_node)) {
@@ -229,8 +229,8 @@ void bonding_save_primary(const struct orig_node *orig_node,
 int window_protected(struct bat_priv *bat_priv, int32_t seq_num_diff,
 		     unsigned long *last_reset)
 {
-	if ((seq_num_diff <= -TQ_LOCAL_WINDOW_SIZE)
-		|| (seq_num_diff >= EXPECTED_SEQNO_RANGE)) {
+	if ((seq_num_diff <= -TQ_LOCAL_WINDOW_SIZE) ||
+	    (seq_num_diff >= EXPECTED_SEQNO_RANGE)) {
 		if (has_timed_out(*last_reset, RESET_PROTECTION_MS)) {
 
 			*last_reset = jiffies;
@@ -429,7 +429,7 @@ int recv_icmp_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 	if ((hdr_size == sizeof(struct icmp_packet_rr)) &&
 	    (icmp_packet->rr_cur < BAT_RR_LEN)) {
 		memcpy(&(icmp_packet->rr[icmp_packet->rr_cur]),
-			ethhdr->h_dest, ETH_ALEN);
+		       ethhdr->h_dest, ETH_ALEN);
 		icmp_packet->rr_cur++;
 	}
 
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 2ffdc74..c39c120 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -397,7 +397,7 @@ void softif_neigh_purge(struct bat_priv *bat_priv)
 					  &softif_neigh_vid->softif_neigh_list,
 					  list) {
 			if ((!has_timed_out(softif_neigh->last_seen,
-					   SOFTIF_NEIGH_TIMEOUT)) &&
+					    SOFTIF_NEIGH_TIMEOUT)) &&
 			    (atomic_read(&bat_priv->mesh_state) == MESH_ACTIVE))
 				continue;
 
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 9a6f315..c950705 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -261,7 +261,7 @@ int tt_changes_fill_buffer(struct bat_priv *bat_priv,
 	atomic_set(&bat_priv->tt_local_changes, 0);
 
 	list_for_each_entry_safe(entry, safe, &bat_priv->tt_changes_list,
-			list) {
+				 list) {
 		if (count < tot_changes) {
 			memcpy(buff + tt_len(count),
 			       &entry->change, sizeof(struct tt_change));
@@ -333,17 +333,17 @@ int tt_local_seq_print_text(struct seq_file *seq, void *offset)
 		hlist_for_each_entry_rcu(tt_common_entry, node,
 					 head, hash_entry) {
 			seq_printf(seq, " * %pM [%c%c%c%c%c]\n",
-					tt_common_entry->addr,
-					(tt_common_entry->flags &
-					 TT_CLIENT_ROAM ? 'R' : '.'),
-					(tt_common_entry->flags &
-					 TT_CLIENT_NOPURGE ? 'P' : '.'),
-					(tt_common_entry->flags &
-					 TT_CLIENT_NEW ? 'N' : '.'),
-					(tt_common_entry->flags &
-					 TT_CLIENT_PENDING ? 'X' : '.'),
-					(tt_common_entry->flags &
-					 TT_CLIENT_WIFI ? 'W' : '.'));
+				   tt_common_entry->addr,
+				   (tt_common_entry->flags &
+				    TT_CLIENT_ROAM ? 'R' : '.'),
+				   (tt_common_entry->flags &
+				    TT_CLIENT_NOPURGE ? 'P' : '.'),
+				   (tt_common_entry->flags &
+				    TT_CLIENT_NEW ? 'N' : '.'),
+				   (tt_common_entry->flags &
+				    TT_CLIENT_PENDING ? 'X' : '.'),
+				   (tt_common_entry->flags &
+				    TT_CLIENT_WIFI ? 'W' : '.'));
 		}
 		rcu_read_unlock();
 	}
@@ -704,7 +704,7 @@ void tt_global_del_orig(struct bat_priv *bat_priv,
 
 		spin_lock_bh(list_lock);
 		hlist_for_each_entry_safe(tt_common_entry, node, safe,
-					 head, hash_entry) {
+					  head, hash_entry) {
 			tt_global_entry = container_of(tt_common_entry,
 						       struct tt_global_entry,
 						       common);
-- 
1.7.9
