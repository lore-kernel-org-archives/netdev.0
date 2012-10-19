From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net-next 02/21] net: Convert is_<foo>_ether_addr
	uses to eth_addr_<foo>
Date: Thu, 18 Oct 2012 20:55:33 -0700
Message-ID: <668bf67af20de0e315e7ce2472d07e883cae18d6.1350618009.git.joe@perches.com>
References: <cover.1350618006.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, bridge-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>, Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>,
	Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>,
	Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>,
	Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>, James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>, Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <cover.1350618006.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Convert the old ether_addr tests to eth_addr_<foo>.
Adds api consistency.

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 net/802/stp.c                          |    4 +-
 net/8021q/vlan_dev.c                   |    6 ++--
 net/8021q/vlan_netlink.c               |    2 +-
 net/batman-adv/bat_iv_ogm.c            |    2 +-
 net/batman-adv/bridge_loop_avoidance.c |    8 ++--
 net/batman-adv/routing.c               |   20 ++++++------
 net/batman-adv/soft-interface.c        |    4 +-
 net/batman-adv/unicast.c               |    2 +-
 net/batman-adv/vis.c                   |    4 +-
 net/bridge/br_device.c                 |    6 ++--
 net/bridge/br_fdb.c                    |    2 +-
 net/bridge/br_if.c                     |    2 +-
 net/bridge/br_input.c                  |    8 ++--
 net/bridge/br_netlink.c                |    2 +-
 net/core/pktgen.c                      |    4 +-
 net/core/rtnetlink.c                   |    2 +-
 net/dsa/slave.c                        |    2 +-
 net/ethernet/eth.c                     |    6 ++--
 net/ipv4/ip_gre.c                      |    2 +-
 net/ipv6/ip6_gre.c                     |    2 +-
 net/mac80211/cfg.c                     |    2 +-
 net/mac80211/ibss.c                    |    8 ++--
 net/mac80211/ieee80211_i.h             |    2 +-
 net/mac80211/iface.c                   |   12 ++++----
 net/mac80211/mesh.c                    |    2 +-
 net/mac80211/mesh_hwmp.c               |    4 +-
 net/mac80211/mesh_pathtbl.c            |    4 +-
 net/mac80211/mesh_plink.c              |    2 +-
 net/mac80211/mlme.c                    |    4 +-
 net/mac80211/rx.c                      |   50 ++++++++++++++++----------------
 net/mac80211/sta_info.c                |    2 +-
 net/mac80211/status.c                  |    6 ++--
 net/mac80211/tx.c                      |   22 +++++++-------
 net/mac80211/wme.c                     |    4 +-
 net/openvswitch/flow.c                 |    4 +-
 net/openvswitch/vport-internal_dev.c   |    2 +-
 net/wireless/core.c                    |    2 +-
 net/wireless/ibss.c                    |    2 +-
 net/wireless/nl80211.c                 |    4 +-
 net/wireless/util.c                    |    4 +-
 net/wireless/wext-compat.c             |    2 +-
 net/wireless/wext-sme.c                |    2 +-
 42 files changed, 118 insertions(+), 118 deletions(-)

diff --git a/net/802/stp.c b/net/802/stp.c
index 2c40ba0..80a253c 100644
--- a/net/802/stp.c
+++ b/net/802/stp.c
@@ -74,7 +74,7 @@ int stp_proto_register(const struct stp_proto *proto)
 			goto out;
 		}
 	}
-	if (is_zero_ether_addr(proto->group_address))
+	if (eth_addr_zero(proto->group_address))
 		rcu_assign_pointer(stp_proto, proto);
 	else
 		rcu_assign_pointer(garp_protos[proto->group_address[5] -
@@ -88,7 +88,7 @@ EXPORT_SYMBOL_GPL(stp_proto_register);
 void stp_proto_unregister(const struct stp_proto *proto)
 {
 	mutex_lock(&stp_proto_mutex);
-	if (is_zero_ether_addr(proto->group_address))
+	if (eth_addr_zero(proto->group_address))
 		RCU_INIT_POINTER(stp_proto, NULL);
 	else
 		RCU_INIT_POINTER(garp_protos[proto->group_address[5] -
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 4024424..5c330c9 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -352,7 +352,7 @@ static int vlan_dev_set_mac_address(struct net_device *dev, void *p)
 	struct sockaddr *addr = p;
 	int err;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	if (!(dev->flags & IFF_UP))
@@ -559,9 +559,9 @@ static int vlan_dev_init(struct net_device *dev)
 	/* ipv6 shared card related stuff */
 	dev->dev_id = real_dev->dev_id;
 
-	if (is_zero_ether_addr(dev->dev_addr))
+	if (eth_addr_zero(dev->dev_addr))
 		memcpy(dev->dev_addr, real_dev->dev_addr, dev->addr_len);
-	if (is_zero_ether_addr(dev->broadcast))
+	if (eth_addr_zero(dev->broadcast))
 		memcpy(dev->broadcast, real_dev->broadcast, dev->addr_len);
 
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
index 708c80e..c79bba9 100644
--- a/net/8021q/vlan_netlink.c
+++ b/net/8021q/vlan_netlink.c
@@ -46,7 +46,7 @@ static int vlan_validate(struct nlattr *tb[], struct nlattr *data[])
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
 			return -EINVAL;
-		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
+		if (!eth_addr_valid(nla_data(tb[IFLA_ADDRESS])))
 			return -EADDRNOTAVAIL;
 	}
 
diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index b02b75d..5e07dbc 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -1056,7 +1056,7 @@ static void batadv_iv_ogm_process(const struct ethhdr *ethhdr,
 				       hard_iface->net_dev->dev_addr))
 			is_my_oldorig = 1;
 
-		if (is_broadcast_ether_addr(ethhdr->h_source))
+		if (eth_addr_broadcast(ethhdr->h_source))
 			is_broadcast = 1;
 	}
 	rcu_read_unlock();
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index fd8d5af..719faa6 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -1425,7 +1425,7 @@ int batadv_bla_rx(struct batadv_priv *bat_priv, struct sk_buff *skb, short vid,
 
 	if (unlikely(atomic_read(&bat_priv->bla.num_requests)))
 		/* don't allow broadcasts while requests are in flight */
-		if (is_multicast_ether_addr(ethhdr->h_dest) && is_bcast)
+		if (eth_addr_multicast(ethhdr->h_dest) && is_bcast)
 			goto handled;
 
 	memcpy(search_claim.addr, ethhdr->h_source, ETH_ALEN);
@@ -1451,7 +1451,7 @@ int batadv_bla_rx(struct batadv_priv *bat_priv, struct sk_buff *skb, short vid,
 	}
 
 	/* if it is a broadcast ... */
-	if (is_multicast_ether_addr(ethhdr->h_dest) && is_bcast) {
+	if (eth_addr_multicast(ethhdr->h_dest) && is_bcast) {
 		/* ... drop it. the responsible gateway is in charge.
 		 *
 		 * We need to check is_bcast because with the gateway
@@ -1524,7 +1524,7 @@ int batadv_bla_tx(struct batadv_priv *bat_priv, struct sk_buff *skb, short vid)
 
 	if (unlikely(atomic_read(&bat_priv->bla.num_requests)))
 		/* don't allow broadcasts while requests are in flight */
-		if (is_multicast_ether_addr(ethhdr->h_dest))
+		if (eth_addr_multicast(ethhdr->h_dest))
 			goto handled;
 
 	memcpy(search_claim.addr, ethhdr->h_source, ETH_ALEN);
@@ -1549,7 +1549,7 @@ int batadv_bla_tx(struct batadv_priv *bat_priv, struct sk_buff *skb, short vid)
 	}
 
 	/* check if it is a multicast/broadcast frame */
-	if (is_multicast_ether_addr(ethhdr->h_dest)) {
+	if (eth_addr_multicast(ethhdr->h_dest)) {
 		/* drop it. the responsible gateway has forwarded it into
 		 * the backbone network.
 		 */
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 376b4cc..69357da 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -261,11 +261,11 @@ bool batadv_check_management_packet(struct sk_buff *skb,
 	ethhdr = (struct ethhdr *)skb_mac_header(skb);
 
 	/* packet with broadcast indication but unicast recipient */
-	if (!is_broadcast_ether_addr(ethhdr->h_dest))
+	if (!eth_addr_broadcast(ethhdr->h_dest))
 		return false;
 
 	/* packet with broadcast sender address */
-	if (is_broadcast_ether_addr(ethhdr->h_source))
+	if (eth_addr_broadcast(ethhdr->h_source))
 		return false;
 
 	/* create a copy of the skb, if needed, to modify it. */
@@ -412,11 +412,11 @@ int batadv_recv_icmp_packet(struct sk_buff *skb,
 	ethhdr = (struct ethhdr *)skb_mac_header(skb);
 
 	/* packet with unicast indication but broadcast recipient */
-	if (is_broadcast_ether_addr(ethhdr->h_dest))
+	if (eth_addr_broadcast(ethhdr->h_dest))
 		goto out;
 
 	/* packet with broadcast sender address */
-	if (is_broadcast_ether_addr(ethhdr->h_source))
+	if (eth_addr_broadcast(ethhdr->h_source))
 		goto out;
 
 	/* not for me */
@@ -590,11 +590,11 @@ static int batadv_check_unicast_packet(struct sk_buff *skb, int hdr_size)
 	ethhdr = (struct ethhdr *)skb_mac_header(skb);
 
 	/* packet with unicast indication but broadcast recipient */
-	if (is_broadcast_ether_addr(ethhdr->h_dest))
+	if (eth_addr_broadcast(ethhdr->h_dest))
 		return -1;
 
 	/* packet with broadcast sender address */
-	if (is_broadcast_ether_addr(ethhdr->h_source))
+	if (eth_addr_broadcast(ethhdr->h_source))
 		return -1;
 
 	/* not for me */
@@ -697,11 +697,11 @@ int batadv_recv_roam_adv(struct sk_buff *skb, struct batadv_hard_iface *recv_if)
 	ethhdr = (struct ethhdr *)skb_mac_header(skb);
 
 	/* packet with unicast indication but broadcast recipient */
-	if (is_broadcast_ether_addr(ethhdr->h_dest))
+	if (eth_addr_broadcast(ethhdr->h_dest))
 		goto out;
 
 	/* packet with broadcast sender address */
-	if (is_broadcast_ether_addr(ethhdr->h_source))
+	if (eth_addr_broadcast(ethhdr->h_source))
 		goto out;
 
 	batadv_inc_counter(bat_priv, BATADV_CNT_TT_ROAM_ADV_RX);
@@ -1077,11 +1077,11 @@ int batadv_recv_bcast_packet(struct sk_buff *skb,
 	ethhdr = (struct ethhdr *)skb_mac_header(skb);
 
 	/* packet with broadcast indication but unicast recipient */
-	if (!is_broadcast_ether_addr(ethhdr->h_dest))
+	if (!eth_addr_broadcast(ethhdr->h_dest))
 		goto out;
 
 	/* packet with broadcast sender address */
-	if (is_broadcast_ether_addr(ethhdr->h_source))
+	if (eth_addr_broadcast(ethhdr->h_source))
 		goto out;
 
 	/* ignore broadcasts sent by myself */
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index b9a28d2..a08fe2f 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -109,7 +109,7 @@ static int batadv_interface_set_mac_addr(struct net_device *dev, void *p)
 	struct sockaddr *addr = p;
 	uint8_t old_addr[ETH_ALEN];
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memcpy(old_addr, dev->dev_addr, ETH_ALEN);
@@ -184,7 +184,7 @@ static int batadv_interface_tx(struct sk_buff *skb,
 	if (batadv_compare_eth(ethhdr->h_dest, stp_addr))
 		goto dropped;
 
-	if (is_multicast_ether_addr(ethhdr->h_dest)) {
+	if (eth_addr_multicast(ethhdr->h_dest)) {
 		do_bcast = true;
 
 		switch (atomic_read(&bat_priv->gw_mode)) {
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index f397232..e0538e2 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -302,7 +302,7 @@ int batadv_unicast_send_skb(struct sk_buff *skb, struct batadv_priv *bat_priv)
 	unsigned int dev_mtu;
 
 	/* get routing information */
-	if (is_multicast_ether_addr(ethhdr->h_dest)) {
+	if (eth_addr_multicast(ethhdr->h_dest)) {
 		orig_node = batadv_gw_get_selected_orig(bat_priv);
 		if (orig_node)
 			goto find_router;
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index 5abd145..55c1025 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -476,7 +476,7 @@ void batadv_receive_client_update_packet(struct batadv_priv *bat_priv,
 	int are_target = 0;
 
 	/* clients shall not broadcast. */
-	if (is_broadcast_ether_addr(vis_packet->target_orig))
+	if (eth_addr_broadcast(vis_packet->target_orig))
 		return;
 
 	/* Are we the target for this VIS packet? */
@@ -800,7 +800,7 @@ static void batadv_send_vis_packet(struct batadv_priv *bat_priv,
 	memcpy(packet->sender_orig, primary_if->net_dev->dev_addr, ETH_ALEN);
 	packet->header.ttl--;
 
-	if (is_broadcast_ether_addr(packet->target_orig))
+	if (eth_addr_broadcast(packet->target_orig))
 		batadv_broadcast_vis_packet(bat_priv, info);
 	else
 		batadv_unicast_vis_packet(bat_priv, info);
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 070e8a6..9963b31 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -50,9 +50,9 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	skb_reset_mac_header(skb);
 	skb_pull(skb, ETH_HLEN);
 
-	if (is_broadcast_ether_addr(dest))
+	if (eth_addr_broadcast(dest))
 		br_flood_deliver(br, skb);
-	else if (is_multicast_ether_addr(dest)) {
+	else if (eth_addr_multicast(dest)) {
 		if (unlikely(netpoll_tx_running(dev))) {
 			br_flood_deliver(br, skb);
 			goto out;
@@ -167,7 +167,7 @@ static int br_set_mac_address(struct net_device *dev, void *p)
 	struct net_bridge *br = netdev_priv(dev);
 	struct sockaddr *addr = p;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	spin_lock_bh(&br->lock);
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index d9576e6..5519242 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -374,7 +374,7 @@ static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 	struct hlist_head *head = &br->hash[br_mac_hash(addr)];
 	struct net_bridge_fdb_entry *fdb;
 
-	if (!is_valid_ether_addr(addr))
+	if (!eth_addr_valid(addr))
 		return -EINVAL;
 
 	fdb = fdb_find(head, addr);
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 1c8fdc3..b21cfc3 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -327,7 +327,7 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	/* Don't allow bridging non-ethernet like devices */
 	if ((dev->flags & IFF_LOOPBACK) ||
 	    dev->type != ARPHRD_ETHER || dev->addr_len != ETH_ALEN ||
-	    !is_valid_ether_addr(dev->dev_addr))
+	    !eth_addr_valid(dev->dev_addr))
 		return -EINVAL;
 
 	/* No bridging of bridges */
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 76f15fd..c084fed 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -61,7 +61,7 @@ int br_handle_frame_finish(struct sk_buff *skb)
 	br = p->br;
 	br_fdb_update(br, p, eth_hdr(skb)->h_source);
 
-	if (!is_broadcast_ether_addr(dest) && is_multicast_ether_addr(dest) &&
+	if (!eth_addr_broadcast(dest) && eth_addr_multicast(dest) &&
 	    br_multicast_rcv(br, p, skb))
 		goto drop;
 
@@ -78,9 +78,9 @@ int br_handle_frame_finish(struct sk_buff *skb)
 
 	dst = NULL;
 
-	if (is_broadcast_ether_addr(dest))
+	if (eth_addr_broadcast(dest))
 		skb2 = skb;
-	else if (is_multicast_ether_addr(dest)) {
+	else if (eth_addr_multicast(dest)) {
 		mdst = br_mdb_get(br, skb);
 		if (mdst || BR_INPUT_SKB_CB_MROUTERS_ONLY(skb)) {
 			if ((mdst && mdst->mglist) ||
@@ -153,7 +153,7 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
 	if (unlikely(skb->pkt_type == PACKET_LOOPBACK))
 		return RX_HANDLER_PASS;
 
-	if (!is_valid_ether_addr(eth_hdr(skb)->h_source))
+	if (!eth_addr_valid(eth_hdr(skb)->h_source))
 		goto drop;
 
 	skb = skb_share_check(skb, GFP_ATOMIC);
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 093f527..e6b7916 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -201,7 +201,7 @@ static int br_validate(struct nlattr *tb[], struct nlattr *data[])
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
 			return -EINVAL;
-		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
+		if (!eth_addr_valid(nla_data(tb[IFLA_ADDRESS])))
 			return -EADDRNOTAVAIL;
 	}
 
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index d1dc14c..3422af7 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -573,7 +573,7 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
 	seq_puts(seq, "     src_mac: ");
 
 	seq_printf(seq, "%pM ",
-		   is_zero_ether_addr(pkt_dev->src_mac) ?
+		   eth_addr_zero(pkt_dev->src_mac) ?
 			     pkt_dev->odev->dev_addr : pkt_dev->src_mac);
 
 	seq_printf(seq, "dst_mac: ");
@@ -2028,7 +2028,7 @@ static void pktgen_setup_inject(struct pktgen_dev *pkt_dev)
 
 	/* Default to the interface's mac if not explicitly set. */
 
-	if (is_zero_ether_addr(pkt_dev->src_mac))
+	if (eth_addr_zero(pkt_dev->src_mac))
 		memcpy(&(pkt_dev->hh[6]), pkt_dev->odev->dev_addr, ETH_ALEN);
 
 	/* Set up Dest MAC */
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 76d4c2c..5f2632f 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2079,7 +2079,7 @@ static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	}
 
 	addr = nla_data(tb[NDA_LLADDR]);
-	if (!is_valid_ether_addr(addr)) {
+	if (!eth_addr_valid(addr)) {
 		pr_info("PF_BRIDGE: RTM_NEWNEIGH with invalid ether address\n");
 		return -EINVAL;
 	}
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index e32083d..c2eaa8e 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -140,7 +140,7 @@ static int dsa_slave_set_mac_address(struct net_device *dev, void *a)
 	struct sockaddr *addr = a;
 	int err;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	if (!(dev->flags & IFF_UP))
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 4efad53..5ebd114 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -163,7 +163,7 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
 	skb_pull_inline(skb, ETH_HLEN);
 	eth = eth_hdr(skb);
 
-	if (unlikely(is_multicast_ether_addr(eth->h_dest))) {
+	if (unlikely(eth_addr_multicast(eth->h_dest))) {
 		if (ether_addr_equal_64bits(eth->h_dest, dev->broadcast))
 			skb->pkt_type = PACKET_BROADCAST;
 		else
@@ -287,7 +287,7 @@ int eth_mac_addr(struct net_device *dev, void *p)
 
 	if (!(dev->priv_flags & IFF_LIVE_ADDR_CHANGE) && netif_running(dev))
 		return -EBUSY;
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
 	/* if device marked as NET_ADDR_RANDOM, reset it */
@@ -315,7 +315,7 @@ EXPORT_SYMBOL(eth_change_mtu);
 
 int eth_validate_addr(struct net_device *dev)
 {
-	if (!is_valid_ether_addr(dev->dev_addr))
+	if (!eth_addr_valid(dev->dev_addr))
 		return -EADDRNOTAVAIL;
 
 	return 0;
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 7240f8e..dd94879 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1502,7 +1502,7 @@ static int ipgre_tap_validate(struct nlattr *tb[], struct nlattr *data[])
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
 			return -EINVAL;
-		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
+		if (!eth_addr_valid(nla_data(tb[IFLA_ADDRESS])))
 			return -EADDRNOTAVAIL;
 	}
 
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 0185679..7f1810d 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1453,7 +1453,7 @@ static int ip6gre_tap_validate(struct nlattr *tb[], struct nlattr *data[])
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
 			return -EINVAL;
-		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
+		if (!eth_addr_valid(nla_data(tb[IFLA_ADDRESS])))
 			return -EADDRNOTAVAIL;
 	}
 
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index 05f3a31..28cc1b0 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -1193,7 +1193,7 @@ static int ieee80211_add_station(struct wiphy *wiphy, struct net_device *dev,
 	if (ether_addr_equal(mac, sdata->vif.addr))
 		return -EINVAL;
 
-	if (is_multicast_ether_addr(mac))
+	if (eth_addr_multicast(mac))
 		return -EINVAL;
 
 	sta = sta_info_alloc(sdata, mac, GFP_KERNEL);
diff --git a/net/mac80211/ibss.c b/net/mac80211/ibss.c
index 5f3620f..cd6c03a 100644
--- a/net/mac80211/ibss.c
+++ b/net/mac80211/ibss.c
@@ -747,7 +747,7 @@ static void ieee80211_sta_find_ibss(struct ieee80211_sub_if_data *sdata)
 		bssid = ifibss->bssid;
 	if (ifibss->fixed_channel)
 		chan = ifibss->channel;
-	if (!is_zero_ether_addr(ifibss->bssid))
+	if (!eth_addr_zero(ifibss->bssid))
 		bssid = ifibss->bssid;
 	cbss = cfg80211_get_bss(local->hw.wiphy, chan, bssid,
 				ifibss->ssid, ifibss->ssid_len,
@@ -829,11 +829,11 @@ static void ieee80211_rx_mgmt_probe_req(struct ieee80211_sub_if_data *sdata,
 		 "RX ProbeReq SA=%pM DA=%pM BSSID=%pM (tx_last_beacon=%d)\n",
 		 mgmt->sa, mgmt->da, mgmt->bssid, tx_last_beacon);
 
-	if (!tx_last_beacon && is_multicast_ether_addr(mgmt->da))
+	if (!tx_last_beacon && eth_addr_multicast(mgmt->da))
 		return;
 
 	if (!ether_addr_equal(mgmt->bssid, ifibss->bssid) &&
-	    !is_broadcast_ether_addr(mgmt->bssid))
+	    !eth_addr_broadcast(mgmt->bssid))
 		return;
 
 	end = ((u8 *) mgmt) + len;
@@ -1157,7 +1157,7 @@ int ieee80211_ibss_leave(struct ieee80211_sub_if_data *sdata)
 
 	active_ibss = ieee80211_sta_active_ibss(sdata);
 
-	if (!active_ibss && !is_zero_ether_addr(ifibss->bssid)) {
+	if (!active_ibss && !eth_addr_zero(ifibss->bssid)) {
 		capability = WLAN_CAPABILITY_IBSS;
 
 		if (ifibss->privacy)
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 8c80455..c218341 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -1185,7 +1185,7 @@ static inline struct ieee80211_local *hw_to_local(
 static inline int ieee80211_bssid_match(const u8 *raddr, const u8 *addr)
 {
 	return ether_addr_equal(raddr, addr) ||
-	       is_broadcast_ether_addr(raddr);
+	       eth_addr_broadcast(raddr);
 }
 
 
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index 6f8a73c..6292fa4 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -427,7 +427,7 @@ int ieee80211_do_open(struct wireless_dev *wdev, bool coming_up)
 
 	switch (sdata->vif.type) {
 	case NL80211_IFTYPE_WDS:
-		if (!is_valid_ether_addr(sdata->u.wds.remote_addr))
+		if (!eth_addr_valid(sdata->u.wds.remote_addr))
 			return -ENOLINK;
 		break;
 	case NL80211_IFTYPE_AP_VLAN: {
@@ -482,13 +482,13 @@ int ieee80211_do_open(struct wireless_dev *wdev, bool coming_up)
 	 * Copy the hopefully now-present MAC address to
 	 * this interface, if it has the special null one.
 	 */
-	if (dev && is_zero_ether_addr(dev->dev_addr)) {
+	if (dev && eth_addr_zero(dev->dev_addr)) {
 		memcpy(dev->dev_addr,
 		       local->hw.wiphy->perm_addr,
 		       ETH_ALEN);
 		memcpy(dev->perm_addr, dev->dev_addr, ETH_ALEN);
 
-		if (!is_valid_ether_addr(dev->dev_addr)) {
+		if (!eth_addr_valid(dev->dev_addr)) {
 			res = -EADDRNOTAVAIL;
 			goto err_stop;
 		}
@@ -647,7 +647,7 @@ static int ieee80211_open(struct net_device *dev)
 	int err;
 
 	/* fail early if user set an invalid address */
-	if (!is_valid_ether_addr(dev->dev_addr))
+	if (!eth_addr_valid(dev->dev_addr))
 		return -EADDRNOTAVAIL;
 
 	err = ieee80211_check_concurrent_iface(sdata, sdata->vif.type);
@@ -1320,7 +1320,7 @@ static void ieee80211_assign_perm_addr(struct ieee80211_local *local,
 	/* default ... something at least */
 	memcpy(perm_addr, local->hw.wiphy->perm_addr, ETH_ALEN);
 
-	if (is_zero_ether_addr(local->hw.wiphy->addr_mask) &&
+	if (eth_addr_zero(local->hw.wiphy->addr_mask) &&
 	    local->hw.wiphy->n_addresses <= 1)
 		return;
 
@@ -1376,7 +1376,7 @@ static void ieee80211_assign_perm_addr(struct ieee80211_local *local,
 		}
 
 		/* try mask if available */
-		if (is_zero_ether_addr(local->hw.wiphy->addr_mask))
+		if (eth_addr_zero(local->hw.wiphy->addr_mask))
 			break;
 
 		m = local->hw.wiphy->addr_mask;
diff --git a/net/mac80211/mesh.c b/net/mac80211/mesh.c
index ff0296c..60bdef7 100644
--- a/net/mac80211/mesh.c
+++ b/net/mac80211/mesh.c
@@ -473,7 +473,7 @@ void ieee80211_mesh_root_setup(struct ieee80211_if_mesh *ifmsh)
 int ieee80211_fill_mesh_addresses(struct ieee80211_hdr *hdr, __le16 *fc,
 				  const u8 *meshda, const u8 *meshsa)
 {
-	if (is_multicast_ether_addr(meshda)) {
+	if (eth_addr_multicast(meshda)) {
 		*fc |= cpu_to_le16(IEEE80211_FCTL_FROMDS);
 		/* DA TA SA */
 		memcpy(hdr->addr1, meshda, ETH_ALEN);
diff --git a/net/mac80211/mesh_hwmp.c b/net/mac80211/mesh_hwmp.c
index 47aeee2..46c162b 100644
--- a/net/mac80211/mesh_hwmp.c
+++ b/net/mac80211/mesh_hwmp.c
@@ -539,7 +539,7 @@ static void hwmp_preq_frame_process(struct ieee80211_sub_if_data *sdata,
 			target_sn = ++ifmsh->sn;
 			ifmsh->last_sn_update = jiffies;
 		}
-	} else if (is_broadcast_ether_addr(target_addr) &&
+	} else if (eth_addr_broadcast(target_addr) &&
 		   (target_flags & IEEE80211_PREQ_TO_FLAG)) {
 		rcu_read_lock();
 		mpath = mesh_path_lookup(orig_addr, sdata);
@@ -621,7 +621,7 @@ static void hwmp_preq_frame_process(struct ieee80211_sub_if_data *sdata,
 				hopcount, ttl, cpu_to_le32(lifetime),
 				cpu_to_le32(metric), cpu_to_le32(preq_id),
 				sdata);
-		if (!is_multicast_ether_addr(da))
+		if (!eth_addr_multicast(da))
 			ifmsh->mshstats.fwded_unicast++;
 		else
 			ifmsh->mshstats.fwded_mcast++;
diff --git a/net/mac80211/mesh_pathtbl.c b/net/mac80211/mesh_pathtbl.c
index aa74981..e86a6e4 100644
--- a/net/mac80211/mesh_pathtbl.c
+++ b/net/mac80211/mesh_pathtbl.c
@@ -510,7 +510,7 @@ int mesh_path_add(u8 *dst, struct ieee80211_sub_if_data *sdata)
 		/* never add ourselves as neighbours */
 		return -ENOTSUPP;
 
-	if (is_multicast_ether_addr(dst))
+	if (eth_addr_multicast(dst))
 		return -ENOTSUPP;
 
 	if (atomic_add_unless(&sdata->u.mesh.mpaths, 1, MESH_MAX_MPATHS) == 0)
@@ -645,7 +645,7 @@ int mpp_path_add(u8 *dst, u8 *mpp, struct ieee80211_sub_if_data *sdata)
 		/* never add ourselves as neighbours */
 		return -ENOTSUPP;
 
-	if (is_multicast_ether_addr(dst))
+	if (eth_addr_multicast(dst))
 		return -ENOTSUPP;
 
 	err = -ENOMEM;
diff --git a/net/mac80211/mesh_plink.c b/net/mac80211/mesh_plink.c
index 3ab34d8..3b327d6 100644
--- a/net/mac80211/mesh_plink.c
+++ b/net/mac80211/mesh_plink.c
@@ -594,7 +594,7 @@ void mesh_rx_plink_frame(struct ieee80211_sub_if_data *sdata, struct ieee80211_m
 	if (len < IEEE80211_MIN_ACTION_SIZE + 3)
 		return;
 
-	if (is_multicast_ether_addr(mgmt->da)) {
+	if (eth_addr_multicast(mgmt->da)) {
 		mpl_dbg(sdata,
 			"Mesh plink: ignore frame from multicast address\n");
 		return;
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index e714ed8..b0f2d64 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -423,7 +423,7 @@ static void ieee80211_send_assoc(struct ieee80211_sub_if_data *sdata)
 	memcpy(mgmt->sa, sdata->vif.addr, ETH_ALEN);
 	memcpy(mgmt->bssid, assoc_data->bss->bssid, ETH_ALEN);
 
-	if (!is_zero_ether_addr(assoc_data->prev_bssid)) {
+	if (!eth_addr_zero(assoc_data->prev_bssid)) {
 		skb_put(skb, 10);
 		mgmt->frame_control = cpu_to_le16(IEEE80211_FTYPE_MGMT |
 						  IEEE80211_STYPE_REASSOC_REQ);
@@ -1491,7 +1491,7 @@ void ieee80211_sta_rx_notify(struct ieee80211_sub_if_data *sdata,
 	 * data idle periods for sending the periodic probe request to the
 	 * AP we're connected to.
 	 */
-	if (is_multicast_ether_addr(hdr->addr1))
+	if (eth_addr_multicast(hdr->addr1))
 		return;
 
 	ieee80211_sta_reset_conn_monitor(sdata);
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 61c621e..8b79842 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -457,7 +457,7 @@ static int ieee80211_is_unicast_robust_mgmt_frame(struct sk_buff *skb)
 {
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
 
-	if (skb->len < 24 || is_multicast_ether_addr(hdr->addr1))
+	if (skb->len < 24 || eth_addr_multicast(hdr->addr1))
 		return 0;
 
 	return ieee80211_is_robust_mgmt_frame(hdr);
@@ -468,7 +468,7 @@ static int ieee80211_is_multicast_robust_mgmt_frame(struct sk_buff *skb)
 {
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
 
-	if (skb->len < 24 || !is_multicast_ether_addr(hdr->addr1))
+	if (skb->len < 24 || !eth_addr_multicast(hdr->addr1))
 		return 0;
 
 	return ieee80211_is_robust_mgmt_frame(hdr);
@@ -482,7 +482,7 @@ static int ieee80211_get_mmie_keyidx(struct sk_buff *skb)
 	struct ieee80211_mmie *mmie;
 
 	if (skb->len < 24 + sizeof(*mmie) ||
-	    !is_multicast_ether_addr(hdr->da))
+	    !eth_addr_multicast(hdr->da))
 		return -1;
 
 	if (!ieee80211_is_robust_mgmt_frame((struct ieee80211_hdr *) hdr))
@@ -505,7 +505,7 @@ ieee80211_rx_mesh_check(struct ieee80211_rx_data *rx)
 	char *dev_addr = rx->sdata->vif.addr;
 
 	if (ieee80211_is_data(hdr->frame_control)) {
-		if (is_multicast_ether_addr(hdr->addr1)) {
+		if (eth_addr_multicast(hdr->addr1)) {
 			if (ieee80211_has_tods(hdr->frame_control) ||
 				!ieee80211_has_fromds(hdr->frame_control))
 				return RX_DROP_MONITOR;
@@ -841,7 +841,7 @@ ieee80211_rx_h_check(struct ieee80211_rx_data *rx)
 	struct ieee80211_rx_status *status = IEEE80211_SKB_RXCB(rx->skb);
 
 	/* Drop duplicate 802.11 retransmissions (IEEE 802.11 Chap. 9.2.9) */
-	if (rx->sta && !is_multicast_ether_addr(hdr->addr1)) {
+	if (rx->sta && !eth_addr_multicast(hdr->addr1)) {
 		if (unlikely(ieee80211_has_retry(hdr->frame_control) &&
 			     rx->sta->last_seq_ctrl[rx->seqno_idx] ==
 			     hdr->seq_ctrl)) {
@@ -965,7 +965,7 @@ ieee80211_rx_h_decrypt(struct ieee80211_rx_data *rx)
 	if (!ieee80211_has_protected(fc))
 		mmie_keyidx = ieee80211_get_mmie_keyidx(rx->skb);
 
-	if (!is_multicast_ether_addr(hdr->addr1) && sta_ptk) {
+	if (!eth_addr_multicast(hdr->addr1) && sta_ptk) {
 		rx->key = sta_ptk;
 		if ((status->flag & RX_FLAG_DECRYPTED) &&
 		    (status->flag & RX_FLAG_IV_STRIPPED))
@@ -998,7 +998,7 @@ ieee80211_rx_h_decrypt(struct ieee80211_rx_data *rx)
 		int i;
 
 		if (ieee80211_is_mgmt(fc) &&
-		    is_multicast_ether_addr(hdr->addr1) &&
+		    eth_addr_multicast(hdr->addr1) &&
 		    (key = rcu_dereference(rx->sdata->default_mgmt_key)))
 			rx->key = key;
 		else {
@@ -1048,7 +1048,7 @@ ieee80211_rx_h_decrypt(struct ieee80211_rx_data *rx)
 		keyidx = keyid >> 6;
 
 		/* check per-station GTK first, if multicast packet */
-		if (is_multicast_ether_addr(hdr->addr1) && rx->sta)
+		if (eth_addr_multicast(hdr->addr1) && rx->sta)
 			rx->key = rcu_dereference(rx->sta->gtk[keyidx]);
 
 		/* if not found, try default key */
@@ -1063,7 +1063,7 @@ ieee80211_rx_h_decrypt(struct ieee80211_rx_data *rx)
 			if (rx->key &&
 			    rx->key->conf.cipher != WLAN_CIPHER_SUITE_WEP40 &&
 			    rx->key->conf.cipher != WLAN_CIPHER_SUITE_WEP104 &&
-			    !is_multicast_ether_addr(hdr->addr1))
+			    !eth_addr_multicast(hdr->addr1))
 				rx->key = NULL;
 		}
 	}
@@ -1290,7 +1290,7 @@ ieee80211_rx_h_sta_process(struct ieee80211_rx_data *rx)
 				sta->last_rx_rate_flag = status->flag;
 			}
 		}
-	} else if (!is_multicast_ether_addr(hdr->addr1)) {
+	} else if (!eth_addr_multicast(hdr->addr1)) {
 		/*
 		 * Mesh beacons will update last_rx when if they are found to
 		 * match the current local configuration when processed.
@@ -1467,7 +1467,7 @@ ieee80211_rx_h_defragment(struct ieee80211_rx_data *rx)
 
 	if (likely((!ieee80211_has_morefrags(fc) && frag == 0) ||
 		   (rx->skb)->len < 24 ||
-		   is_multicast_ether_addr(hdr->addr1))) {
+		   eth_addr_multicast(hdr->addr1))) {
 		/* not fragmented */
 		goto out;
 	}
@@ -1563,7 +1563,7 @@ ieee80211_rx_h_defragment(struct ieee80211_rx_data *rx)
  out:
 	if (rx->sta)
 		rx->sta->rx_packets++;
-	if (is_multicast_ether_addr(hdr->addr1))
+	if (eth_addr_multicast(hdr->addr1))
 		rx->local->dot11MulticastReceivedFrameCount++;
 	else
 		ieee80211_led_rx(rx->local);
@@ -1680,7 +1680,7 @@ __ieee80211_data_to_8023(struct ieee80211_rx_data *rx, bool *port_control)
 			check_port_control = true;
 	}
 
-	if (is_multicast_ether_addr(hdr->addr1) &&
+	if (eth_addr_multicast(hdr->addr1) &&
 	    sdata->vif.type == NL80211_IFTYPE_AP_VLAN && sdata->u.vlan.sta)
 		return -1;
 
@@ -1743,7 +1743,7 @@ ieee80211_deliver_skb(struct ieee80211_rx_data *rx)
 	    !(sdata->flags & IEEE80211_SDATA_DONT_BRIDGE_PACKETS) &&
 	    (status->rx_flags & IEEE80211_RX_RA_MATCH) &&
 	    (sdata->vif.type != NL80211_IFTYPE_AP_VLAN || !sdata->u.vlan.sta)) {
-		if (is_multicast_ether_addr(ehdr->h_dest)) {
+		if (eth_addr_multicast(ehdr->h_dest)) {
 			/*
 			 * send multicast frames both to higher layers in
 			 * local net stack and back to the wireless medium
@@ -1839,7 +1839,7 @@ ieee80211_rx_h_amsdu(struct ieee80211_rx_data *rx)
 	    !rx->sdata->u.vlan.sta)
 		return RX_DROP_UNUSABLE;
 
-	if (is_multicast_ether_addr(hdr->addr1) &&
+	if (eth_addr_multicast(hdr->addr1) &&
 	    ((rx->sdata->vif.type == NL80211_IFTYPE_AP_VLAN &&
 	      rx->sdata->u.vlan.sta) ||
 	     (rx->sdata->vif.type == NL80211_IFTYPE_STATION &&
@@ -1893,7 +1893,7 @@ ieee80211_rx_h_mesh_fwding(struct ieee80211_rx_data *rx)
 
 	/* frame is in RMC, don't forward */
 	if (ieee80211_is_data(hdr->frame_control) &&
-	    is_multicast_ether_addr(hdr->addr1) &&
+	    eth_addr_multicast(hdr->addr1) &&
 	    mesh_rmc_check(hdr->addr3, mesh_hdr, rx->sdata))
 		return RX_DROP_MONITOR;
 
@@ -1908,7 +1908,7 @@ ieee80211_rx_h_mesh_fwding(struct ieee80211_rx_data *rx)
 		char *proxied_addr;
 		char *mpp_addr;
 
-		if (is_multicast_ether_addr(hdr->addr1)) {
+		if (eth_addr_multicast(hdr->addr1)) {
 			mpp_addr = hdr->addr3;
 			proxied_addr = mesh_hdr->eaddr1;
 		} else {
@@ -1930,7 +1930,7 @@ ieee80211_rx_h_mesh_fwding(struct ieee80211_rx_data *rx)
 	}
 
 	/* Frame has reached destination.  Don't forward */
-	if (!is_multicast_ether_addr(hdr->addr1) &&
+	if (!eth_addr_multicast(hdr->addr1) &&
 	    ether_addr_equal(sdata->vif.addr, hdr->addr3))
 		return RX_CONTINUE;
 
@@ -1965,7 +1965,7 @@ ieee80211_rx_h_mesh_fwding(struct ieee80211_rx_data *rx)
 	info->flags |= IEEE80211_TX_INTFL_NEED_TXPROCESSING;
 	info->control.vif = &rx->sdata->vif;
 	info->control.jiffies = jiffies;
-	if (is_multicast_ether_addr(fwd_hdr->addr1)) {
+	if (eth_addr_multicast(fwd_hdr->addr1)) {
 		IEEE80211_IFSTA_MESH_CTR_INC(ifmsh, fwded_mcast);
 		memcpy(fwd_hdr->addr2, sdata->vif.addr, ETH_ALEN);
 	} else if (!mesh_nexthop_lookup(fwd_skb, sdata)) {
@@ -1982,7 +1982,7 @@ ieee80211_rx_h_mesh_fwding(struct ieee80211_rx_data *rx)
 	IEEE80211_IFSTA_MESH_CTR_INC(ifmsh, fwded_frames);
 	ieee80211_add_pending_skb(local, fwd_skb);
  out:
-	if (is_multicast_ether_addr(hdr->addr1) ||
+	if (eth_addr_multicast(hdr->addr1) ||
 	    sdata->dev->flags & IFF_PROMISC)
 		return RX_CONTINUE;
 	else
@@ -2041,7 +2041,7 @@ ieee80211_rx_h_data(struct ieee80211_rx_data *rx)
 	dev->stats.rx_bytes += rx->skb->len;
 
 	if (local->ps_sdata && local->hw.conf.dynamic_ps_timeout > 0 &&
-	    !is_multicast_ether_addr(
+	    !eth_addr_multicast(
 		    ((struct ethhdr *)rx->skb->data)->h_dest) &&
 	    (!local->scanning &&
 	     !test_bit(SDATA_STATE_OFFCHANNEL, &sdata->state))) {
@@ -2461,7 +2461,7 @@ ieee80211_rx_h_action_return(struct ieee80211_rx_data *rx)
 	     sdata->vif.type == NL80211_IFTYPE_AP_VLAN))
 		return RX_DROP_MONITOR;
 
-	if (is_multicast_ether_addr(mgmt->da))
+	if (eth_addr_multicast(mgmt->da))
 		return RX_DROP_MONITOR;
 
 	/* do not return rejected action frames */
@@ -2509,8 +2509,8 @@ ieee80211_rx_h_mgmt(struct ieee80211_rx_data *rx)
 	case cpu_to_le16(IEEE80211_STYPE_REASSOC_RESP):
 	case cpu_to_le16(IEEE80211_STYPE_DEAUTH):
 	case cpu_to_le16(IEEE80211_STYPE_DISASSOC):
-		if (is_multicast_ether_addr(mgmt->da) &&
-		    !is_broadcast_ether_addr(mgmt->da))
+		if (eth_addr_multicast(mgmt->da) &&
+		    !eth_addr_broadcast(mgmt->da))
 			return RX_DROP_MONITOR;
 
 		/* process only for station */
@@ -2762,7 +2762,7 @@ static int prepare_for_handlers(struct ieee80211_rx_data *rx,
 	struct sk_buff *skb = rx->skb;
 	struct ieee80211_rx_status *status = IEEE80211_SKB_RXCB(skb);
 	u8 *bssid = ieee80211_get_bssid(hdr, skb->len, sdata->vif.type);
-	int multicast = is_multicast_ether_addr(hdr->addr1);
+	int multicast = eth_addr_multicast(hdr->addr1);
 
 	switch (sdata->vif.type) {
 	case NL80211_IFTYPE_STATION:
diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index 797dd36..430db47 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -364,7 +364,7 @@ static int sta_info_insert_check(struct sta_info *sta)
 		return -ENETDOWN;
 
 	if (WARN_ON(ether_addr_equal(sta->sta.addr, sdata->vif.addr) ||
-		    is_multicast_ether_addr(sta->sta.addr)))
+		    eth_addr_multicast(sta->sta.addr)))
 		return -EINVAL;
 
 	return 0;
diff --git a/net/mac80211/status.c b/net/mac80211/status.c
index 3af0cc4..04ba926 100644
--- a/net/mac80211/status.c
+++ b/net/mac80211/status.c
@@ -288,7 +288,7 @@ static void ieee80211_add_tx_radiotap_header(struct ieee80211_supported_band
 	/* IEEE80211_RADIOTAP_TX_FLAGS */
 	txflags = 0;
 	if (!(info->flags & IEEE80211_TX_STAT_ACK) &&
-	    !is_multicast_ether_addr(hdr->addr1))
+	    !eth_addr_multicast(hdr->addr1))
 		txflags |= IEEE80211_RADIOTAP_F_TX_FAIL;
 
 	if ((info->status.rates[0].flags & IEEE80211_TX_RC_USE_RTS_CTS) ||
@@ -482,7 +482,7 @@ void ieee80211_tx_status(struct ieee80211_hw *hw, struct sk_buff *skb)
 	if (info->flags & IEEE80211_TX_STAT_ACK) {
 		if (ieee80211_is_first_frag(hdr->seq_ctrl)) {
 			local->dot11TransmittedFrameCount++;
-			if (is_multicast_ether_addr(hdr->addr1))
+			if (eth_addr_multicast(hdr->addr1))
 				local->dot11MulticastTransmittedFrameCount++;
 			if (retry_count > 0)
 				local->dot11RetryCount++;
@@ -494,7 +494,7 @@ void ieee80211_tx_status(struct ieee80211_hw *hw, struct sk_buff *skb)
 		 * with an individual address in the address 1 field or an MPDU
 		 * with a multicast address in the address 1 field of type Data
 		 * or Management. */
-		if (!is_multicast_ether_addr(hdr->addr1) ||
+		if (!eth_addr_multicast(hdr->addr1) ||
 		    ieee80211_is_data(fc) ||
 		    ieee80211_is_mgmt(fc))
 			local->dot11TransmittedFragmentCount++;
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index c9bf83f..c5e251d 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -532,14 +532,14 @@ ieee80211_tx_h_select_key(struct ieee80211_tx_data *tx)
 	else if (tx->sta && (key = rcu_dereference(tx->sta->ptk)))
 		tx->key = key;
 	else if (ieee80211_is_mgmt(hdr->frame_control) &&
-		 is_multicast_ether_addr(hdr->addr1) &&
+		 eth_addr_multicast(hdr->addr1) &&
 		 ieee80211_is_robust_mgmt_frame(hdr) &&
 		 (key = rcu_dereference(tx->sdata->default_mgmt_key)))
 		tx->key = key;
-	else if (is_multicast_ether_addr(hdr->addr1) &&
+	else if (eth_addr_multicast(hdr->addr1) &&
 		 (key = rcu_dereference(tx->sdata->default_multicast_key)))
 		tx->key = key;
-	else if (!is_multicast_ether_addr(hdr->addr1) &&
+	else if (!eth_addr_multicast(hdr->addr1) &&
 		 (key = rcu_dereference(tx->sdata->default_unicast_key)))
 		tx->key = key;
 	else if (info->flags & IEEE80211_TX_CTL_INJECTED)
@@ -693,7 +693,7 @@ ieee80211_tx_h_rate_ctrl(struct ieee80211_tx_data *tx)
 			 (info->flags & IEEE80211_TX_CTL_NO_ACK)))
 		info->control.rates[0].count = 1;
 
-	if (is_multicast_ether_addr(hdr->addr1)) {
+	if (eth_addr_multicast(hdr->addr1)) {
 		/*
 		 * XXX: verify the rate is in the basic rateset
 		 */
@@ -1036,7 +1036,7 @@ ieee80211_tx_h_calculate_duration(struct ieee80211_tx_data *tx)
 			next_len = next->len;
 		} else
 			next_len = 0;
-		group_addr = is_multicast_ether_addr(hdr->addr1);
+		group_addr = eth_addr_multicast(hdr->addr1);
 
 		hdr->duration_id =
 			ieee80211_duration(tx, skb, group_addr, next_len);
@@ -1174,7 +1174,7 @@ ieee80211_tx_prepare(struct ieee80211_sub_if_data *sdata,
 		}
 	}
 
-	if (is_multicast_ether_addr(hdr->addr1)) {
+	if (eth_addr_multicast(hdr->addr1)) {
 		tx->flags &= ~IEEE80211_TX_UNICAST;
 		info->flags |= IEEE80211_TX_CTL_NO_ACK;
 	} else
@@ -1475,7 +1475,7 @@ void ieee80211_xmit(struct ieee80211_sub_if_data *sdata, struct sk_buff *skb)
 
 	if (ieee80211_vif_is_mesh(&sdata->vif) &&
 	    ieee80211_is_data(hdr->frame_control) &&
-	    !is_multicast_ether_addr(hdr->addr1) &&
+	    !eth_addr_multicast(hdr->addr1) &&
 	    mesh_nexthop_resolve(skb, sdata)) {
 		/* skb queued: don't free */
 		rcu_read_unlock();
@@ -1787,7 +1787,7 @@ netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
 			goto fail;
 		}
 		rcu_read_lock();
-		if (!is_multicast_ether_addr(skb->data)) {
+		if (!eth_addr_multicast(skb->data)) {
 			mpath = mesh_path_lookup(skb->data, sdata);
 			if (!mpath)
 				mppath = mpp_path_lookup(skb->data, sdata);
@@ -1823,7 +1823,7 @@ netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
 
 			hdrlen = ieee80211_fill_mesh_addresses(&hdr, &fc,
 					mesh_da, sdata->vif.addr);
-			if (is_multicast_ether_addr(mesh_da))
+			if (eth_addr_multicast(mesh_da))
 				/* DA TA mSA AE:SA */
 				meshhdrlen =
 					ieee80211_new_mesh_header(&mesh_hdr,
@@ -1913,7 +1913,7 @@ netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
 	 * if it is a multicast address (which can only happen
 	 * in AP mode)
 	 */
-	multicast = is_multicast_ether_addr(hdr.addr1);
+	multicast = eth_addr_multicast(hdr.addr1);
 	if (!multicast) {
 		rcu_read_lock();
 		sta = sta_info_get(sdata, hdr.addr1);
@@ -1939,7 +1939,7 @@ netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
 	 * EAPOL frames from the local station.
 	 */
 	if (unlikely(!ieee80211_vif_is_mesh(&sdata->vif) &&
-		     !is_multicast_ether_addr(hdr.addr1) && !authorized &&
+		     !eth_addr_multicast(hdr.addr1) && !authorized &&
 		     (cpu_to_be16(ethertype) != sdata->control_port_protocol ||
 		      !ether_addr_equal(sdata->vif.addr, skb->data + ETH_ALEN)))) {
 #ifdef CONFIG_MAC80211_VERBOSE_DEBUG
diff --git a/net/mac80211/wme.c b/net/mac80211/wme.c
index cea06e9..f64d446 100644
--- a/net/mac80211/wme.c
+++ b/net/mac80211/wme.c
@@ -141,7 +141,7 @@ u16 ieee80211_select_queue(struct ieee80211_sub_if_data *sdata,
 		break;
 	}
 
-	if (!sta && ra && !is_multicast_ether_addr(ra)) {
+	if (!sta && ra && !eth_addr_multicast(ra)) {
 		sta = sta_info_get(sdata, ra);
 		if (sta)
 			qos = test_sta_flag(sta, WLAN_STA_WME);
@@ -176,7 +176,7 @@ void ieee80211_set_qos_hdr(struct ieee80211_sub_if_data *sdata,
 		/* preserve EOSP bit */
 		ack_policy = *p & IEEE80211_QOS_CTL_EOSP;
 
-		if (is_multicast_ether_addr(hdr->addr1) ||
+		if (eth_addr_multicast(hdr->addr1) ||
 		    sdata->noack_map & BIT(tid)) {
 			ack_policy |= IEEE80211_QOS_CTL_ACK_POLICY_NOACK;
 			info->flags |= IEEE80211_TX_CTL_NO_ACK;
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 98c7063..70addfe 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -540,13 +540,13 @@ static int parse_icmpv6(struct sk_buff *skb, struct sw_flow_key *key,
 			 */
 			if (nd_opt->nd_opt_type == ND_OPT_SOURCE_LL_ADDR
 			    && opt_len == 8) {
-				if (unlikely(!is_zero_ether_addr(key->ipv6.nd.sll)))
+				if (unlikely(!eth_addr_zero(key->ipv6.nd.sll)))
 					goto invalid;
 				memcpy(key->ipv6.nd.sll,
 				    &nd->opt[offset+sizeof(*nd_opt)], ETH_ALEN);
 			} else if (nd_opt->nd_opt_type == ND_OPT_TARGET_LL_ADDR
 				   && opt_len == 8) {
-				if (unlikely(!is_zero_ether_addr(key->ipv6.nd.tll)))
+				if (unlikely(!eth_addr_zero(key->ipv6.nd.tll)))
 					goto invalid;
 				memcpy(key->ipv6.nd.tll,
 				    &nd->opt[offset+sizeof(*nd_opt)], ETH_ALEN);
diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index 5d460c3..96a02c9 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -67,7 +67,7 @@ static int internal_dev_mac_addr(struct net_device *dev, void *p)
 {
 	struct sockaddr *addr = p;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 	dev->addr_assign_type &= ~NET_ADDR_RANDOM;
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
diff --git a/net/wireless/core.c b/net/wireless/core.c
index 443d4d7..8048685 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -468,7 +468,7 @@ int wiphy_register(struct wiphy *wiphy)
 		return -EINVAL;
 
 	if (WARN_ON(wiphy->addresses &&
-		    !is_zero_ether_addr(wiphy->perm_addr) &&
+		    !eth_addr_zero(wiphy->perm_addr) &&
 		    memcmp(wiphy->perm_addr, wiphy->addresses[0].addr,
 			   ETH_ALEN)))
 		return -EINVAL;
diff --git a/net/wireless/ibss.c b/net/wireless/ibss.c
index ca5672f..21a7dce 100644
--- a/net/wireless/ibss.c
+++ b/net/wireless/ibss.c
@@ -479,7 +479,7 @@ int cfg80211_ibss_wext_siwap(struct net_device *dev,
 		return -EINVAL;
 
 	/* automatic mode */
-	if (is_zero_ether_addr(bssid) || is_broadcast_ether_addr(bssid))
+	if (eth_addr_zero(bssid) || eth_addr_broadcast(bssid))
 		bssid = NULL;
 
 	/* both automatic */
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 0418a6d..fe94df8 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -4630,7 +4630,7 @@ static int nl80211_send_bss(struct sk_buff *msg, struct netlink_callback *cb,
 	bss = nla_nest_start(msg, NL80211_ATTR_BSS);
 	if (!bss)
 		goto nla_put_failure;
-	if ((!is_zero_ether_addr(res->bssid) &&
+	if ((!eth_addr_zero(res->bssid) &&
 	     nla_put(msg, NL80211_BSS_BSSID, ETH_ALEN, res->bssid)) ||
 	    (res->information_elements && res->len_information_elements &&
 	     nla_put(msg, NL80211_BSS_INFORMATION_ELEMENTS,
@@ -5275,7 +5275,7 @@ static int nl80211_join_ibss(struct sk_buff *skb, struct genl_info *info)
 	if (info->attrs[NL80211_ATTR_MAC]) {
 		ibss.bssid = nla_data(info->attrs[NL80211_ATTR_MAC]);
 
-		if (!is_valid_ether_addr(ibss.bssid))
+		if (!eth_addr_valid(ibss.bssid))
 			return -EINVAL;
 	}
 	ibss.ssid = nla_data(info->attrs[NL80211_ATTR_SSID]);
diff --git a/net/wireless/util.c b/net/wireless/util.c
index ef35f4e..b25f934 100644
--- a/net/wireless/util.c
+++ b/net/wireless/util.c
@@ -388,7 +388,7 @@ int ieee80211_data_to_8023(struct sk_buff *skb, const u8 *addr,
 		if ((iftype != NL80211_IFTYPE_STATION &&
 		     iftype != NL80211_IFTYPE_P2P_CLIENT &&
 		     iftype != NL80211_IFTYPE_MESH_POINT) ||
-		    (is_multicast_ether_addr(dst) &&
+		    (eth_addr_multicast(dst) &&
 		     ether_addr_equal(src, addr)))
 			return -1;
 		if (iftype == NL80211_IFTYPE_MESH_POINT) {
@@ -739,7 +739,7 @@ void cfg80211_process_wdev_events(struct wireless_dev *wdev)
 		wdev_lock(wdev);
 		switch (ev->type) {
 		case EVENT_CONNECT_RESULT:
-			if (!is_zero_ether_addr(ev->cr.bssid))
+			if (!eth_addr_zero(ev->cr.bssid))
 				bssid = ev->cr.bssid;
 			__cfg80211_connect_result(
 				wdev->netdev, bssid,
diff --git a/net/wireless/wext-compat.c b/net/wireless/wext-compat.c
index 494379e..dcc9501 100644
--- a/net/wireless/wext-compat.c
+++ b/net/wireless/wext-compat.c
@@ -724,7 +724,7 @@ static int cfg80211_wext_siwencodeext(struct net_device *dev,
 	}
 
 	addr = ext->addr.sa_data;
-	if (is_broadcast_ether_addr(addr))
+	if (eth_addr_broadcast(addr))
 		addr = NULL;
 
 	memset(&params, 0, sizeof(params));
diff --git a/net/wireless/wext-sme.c b/net/wireless/wext-sme.c
index 1f773f6..4f2f6d8 100644
--- a/net/wireless/wext-sme.c
+++ b/net/wireless/wext-sme.c
@@ -267,7 +267,7 @@ int cfg80211_mgd_wext_siwap(struct net_device *dev,
 		return -EINVAL;
 
 	/* automatic mode */
-	if (is_zero_ether_addr(bssid) || is_broadcast_ether_addr(bssid))
+	if (eth_addr_zero(bssid) || eth_addr_broadcast(bssid))
 		bssid = NULL;
 
 	cfg80211_lock_rdev(rdev);
-- 
1.7.8.111.gad25c.dirty
