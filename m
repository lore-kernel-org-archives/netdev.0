From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 03/15] batman-adv: Remove multiple assignment per line
Date: Tue, 25 Aug 2015 13:02:27 +0200
Message-ID: <1440500559-28368-4-git-send-email-antonio__43379.9414233819$1440500689$gmane$org@meshcoding.com>
References: <1440500559-28368-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:19965 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755060AbbHYLDy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2015 07:03:54 -0400
In-Reply-To: <1440500559-28368-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The Linux CodingStyle disallows multiple assignments in a single line.
(see chapter 1)

Reported-by: Markus Pargmann <mpa@pengutronix.de>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/bat_iv_ogm.c            |  6 ++++--
 net/batman-adv/bridge_loop_avoidance.c |  6 ++++--
 net/batman-adv/distributed-arp-table.c |  3 ++-
 net/batman-adv/gateway_client.c        | 15 ++++++++++-----
 net/batman-adv/gateway_common.c        |  5 ++++-
 net/batman-adv/network-coding.c        |  3 ++-
 net/batman-adv/translation-table.c     | 18 +++++++++++++-----
 7 files changed, 39 insertions(+), 17 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index f550a6a..df54118 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -1004,7 +1004,8 @@ batadv_iv_ogm_orig_update(struct batadv_priv *bat_priv,
 {
 	struct batadv_neigh_ifinfo *neigh_ifinfo = NULL;
 	struct batadv_neigh_ifinfo *router_ifinfo = NULL;
-	struct batadv_neigh_node *neigh_node = NULL, *tmp_neigh_node = NULL;
+	struct batadv_neigh_node *neigh_node = NULL;
+	struct batadv_neigh_node *tmp_neigh_node = NULL;
 	struct batadv_neigh_node *router = NULL;
 	struct batadv_orig_node *orig_node_tmp;
 	int if_num;
@@ -1404,7 +1405,8 @@ batadv_iv_ogm_process_per_outif(const struct sk_buff *skb, int ogm_offset,
 				struct batadv_hard_iface *if_outgoing)
 {
 	struct batadv_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
-	struct batadv_neigh_node *router = NULL, *router_router = NULL;
+	struct batadv_neigh_node *router = NULL;
+	struct batadv_neigh_node *router_router = NULL;
 	struct batadv_orig_node *orig_neigh_node;
 	struct batadv_orig_ifinfo *orig_ifinfo;
 	struct batadv_neigh_node *orig_neigh_router = NULL;
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 8f9059f..191a702 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -88,7 +88,8 @@ static int batadv_compare_backbone_gw(const struct hlist_node *node,
 {
 	const void *data1 = container_of(node, struct batadv_bla_backbone_gw,
 					 hash_entry);
-	const struct batadv_bla_backbone_gw *gw1 = data1, *gw2 = data2;
+	const struct batadv_bla_backbone_gw *gw1 = data1;
+	const struct batadv_bla_backbone_gw *gw2 = data2;
 
 	if (!batadv_compare_eth(gw1->orig, gw2->orig))
 		return 0;
@@ -105,7 +106,8 @@ static int batadv_compare_claim(const struct hlist_node *node,
 {
 	const void *data1 = container_of(node, struct batadv_bla_claim,
 					 hash_entry);
-	const struct batadv_bla_claim *cl1 = data1, *cl2 = data2;
+	const struct batadv_bla_claim *cl1 = data1;
+	const struct batadv_bla_claim *cl2 = data2;
 
 	if (!batadv_compare_eth(cl1->addr, cl2->addr))
 		return 0;
diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index a63ea27..83bc1aa 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -497,7 +497,8 @@ static void batadv_choose_next_candidate(struct batadv_priv *bat_priv,
 					 int select, batadv_dat_addr_t ip_key,
 					 batadv_dat_addr_t *last_max)
 {
-	batadv_dat_addr_t max = 0, tmp_max = 0;
+	batadv_dat_addr_t max = 0;
+	batadv_dat_addr_t tmp_max = 0;
 	struct batadv_orig_node *orig_node, *max_orig_node = NULL;
 	struct batadv_hashtable *hash = bat_priv->orig_hash;
 	struct hlist_head *head;
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 6269c75..d7ca214 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -153,7 +153,8 @@ batadv_gw_get_best_gw_node(struct batadv_priv *bat_priv)
 	struct batadv_neigh_node *router;
 	struct batadv_neigh_ifinfo *router_ifinfo;
 	struct batadv_gw_node *gw_node, *curr_gw = NULL;
-	u64 max_gw_factor = 0, tmp_gw_factor = 0;
+	u64 max_gw_factor = 0;
+	u64 tmp_gw_factor = 0;
 	u8 max_tq = 0;
 	u8 tq_avg;
 	struct batadv_orig_node *orig_node;
@@ -263,7 +264,8 @@ void batadv_gw_check_client_stop(struct batadv_priv *bat_priv)
 
 void batadv_gw_election(struct batadv_priv *bat_priv)
 {
-	struct batadv_gw_node *curr_gw = NULL, *next_gw = NULL;
+	struct batadv_gw_node *curr_gw = NULL;
+	struct batadv_gw_node *next_gw = NULL;
 	struct batadv_neigh_node *router = NULL;
 	struct batadv_neigh_ifinfo *router_ifinfo = NULL;
 	char gw_addr[18] = { '\0' };
@@ -347,7 +349,8 @@ void batadv_gw_check_election(struct batadv_priv *bat_priv,
 	struct batadv_neigh_ifinfo *router_orig_tq = NULL;
 	struct batadv_neigh_ifinfo *router_gw_tq = NULL;
 	struct batadv_orig_node *curr_gw_orig;
-	struct batadv_neigh_node *router_gw = NULL, *router_orig = NULL;
+	struct batadv_neigh_node *router_gw = NULL;
+	struct batadv_neigh_node *router_orig = NULL;
 	u8 gw_tq_avg, orig_tq_avg;
 
 	curr_gw_orig = batadv_gw_get_selected_orig(bat_priv);
@@ -808,9 +811,11 @@ batadv_gw_dhcp_recipient_get(struct sk_buff *skb, unsigned int *header_len,
 bool batadv_gw_out_of_range(struct batadv_priv *bat_priv,
 			    struct sk_buff *skb)
 {
-	struct batadv_neigh_node *neigh_curr = NULL, *neigh_old = NULL;
+	struct batadv_neigh_node *neigh_curr = NULL;
+	struct batadv_neigh_node *neigh_old = NULL;
 	struct batadv_orig_node *orig_dst_node = NULL;
-	struct batadv_gw_node *gw_node = NULL, *curr_gw = NULL;
+	struct batadv_gw_node *gw_node = NULL;
+	struct batadv_gw_node *curr_gw = NULL;
 	struct batadv_neigh_ifinfo *curr_ifinfo, *old_ifinfo;
 	struct ethhdr *ethhdr = (struct ethhdr *)skb->data;
 	bool out_of_range = false;
diff --git a/net/batman-adv/gateway_common.c b/net/batman-adv/gateway_common.c
index 9e32c8e..c50931c 100644
--- a/net/batman-adv/gateway_common.c
+++ b/net/batman-adv/gateway_common.c
@@ -149,7 +149,10 @@ ssize_t batadv_gw_bandwidth_set(struct net_device *net_dev, char *buff,
 				size_t count)
 {
 	struct batadv_priv *bat_priv = netdev_priv(net_dev);
-	u32 down_curr, up_curr, down_new = 0, up_new = 0;
+	u32 down_curr;
+	u32 up_curr;
+	u32 down_new = 0;
+	u32 up_new = 0;
 	bool ret;
 
 	down_curr = (unsigned int)atomic_read(&bat_priv->gw.bandwidth_down);
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index 5cab144..ccfe5d8 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -887,7 +887,8 @@ void batadv_nc_update_nc_node(struct batadv_priv *bat_priv,
 			      struct batadv_ogm_packet *ogm_packet,
 			      int is_single_hop_neigh)
 {
-	struct batadv_nc_node *in_nc_node = NULL, *out_nc_node = NULL;
+	struct batadv_nc_node *in_nc_node = NULL;
+	struct batadv_nc_node *out_nc_node = NULL;
 
 	/* Check if network coding is enabled */
 	if (!atomic_read(&bat_priv->network_coding))
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index f908988..7e34901 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -462,7 +462,8 @@ static u16 batadv_tt_entries(u16 tt_len)
  */
 static int batadv_tt_local_table_transmit_size(struct batadv_priv *bat_priv)
 {
-	u16 num_vlan = 0, tt_local_entries = 0;
+	u16 num_vlan = 0;
+	u16 tt_local_entries = 0;
 	struct batadv_softif_vlan *vlan;
 	int hdr_size;
 
@@ -536,7 +537,8 @@ bool batadv_tt_local_add(struct net_device *soft_iface, const u8 *addr,
 	struct hlist_head *head;
 	struct batadv_tt_orig_list_entry *orig_entry;
 	int hash_added, table_size, packet_size_max;
-	bool ret = false, roamed_back = false;
+	bool ret = false;
+	bool roamed_back = false;
 	u8 remote_flags;
 	u32 match_mark;
 
@@ -730,7 +732,10 @@ batadv_tt_prepare_tvlv_global_data(struct batadv_orig_node *orig_node,
 				   struct batadv_tvlv_tt_change **tt_change,
 				   s32 *tt_len)
 {
-	u16 num_vlan = 0, num_entries = 0, change_offset, tvlv_len;
+	u16 num_vlan = 0;
+	u16 num_entries = 0;
+	u16 change_offset;
+	u16 tvlv_len;
 	struct batadv_tvlv_tt_vlan_data *tt_vlan;
 	struct batadv_orig_node_vlan *vlan;
 	u8 *tt_change_ptr;
@@ -803,7 +808,9 @@ batadv_tt_prepare_tvlv_local_data(struct batadv_priv *bat_priv,
 {
 	struct batadv_tvlv_tt_vlan_data *tt_vlan;
 	struct batadv_softif_vlan *vlan;
-	u16 num_vlan = 0, num_entries = 0, tvlv_len;
+	u16 num_vlan = 0;
+	u16 num_entries = 0;
+	u16 tvlv_len;
 	u8 *tt_change_ptr;
 	int change_offset;
 
@@ -860,7 +867,8 @@ static void batadv_tt_tvlv_container_update(struct batadv_priv *bat_priv)
 	struct batadv_tvlv_tt_data *tt_data;
 	struct batadv_tvlv_tt_change *tt_change;
 	int tt_diff_len, tt_change_len = 0;
-	int tt_diff_entries_num = 0, tt_diff_entries_count = 0;
+	int tt_diff_entries_num = 0;
+	int tt_diff_entries_count = 0;
 	u16 tvlv_len;
 
 	tt_diff_entries_num = atomic_read(&bat_priv->tt.local_changes);
-- 
2.5.0
