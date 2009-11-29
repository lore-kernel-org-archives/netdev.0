From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next-2.6 PATCH] net: Move && and || to end of previous
 line
Date: Sun, 29 Nov 2009 13:00:49 -0800
Message-ID: <1259528449.29779.194.camel@Joe-Laptop.home>
References: <1259000895.16503.77.camel@Joe-Laptop.home>
	 <20091123.103158.32535206.davem@davemloft.net>
	 <1259001504.16503.79.camel@Joe-Laptop.home>
	 <20091123.104130.117837098.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1187 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752381AbZK2VAo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Nov 2009 16:00:44 -0500
In-Reply-To: <20091123.104130.117837098.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not including net/atm/

Compiled tested x86 allyesconfig only
Added a > 80 column line or two, which I ignored.
Existing checkpatch plaints willfully, cheerfully ignored.

Signed-off-by: Joe Perches <joe@perches.com>
 net/9p/trans_fd.c                       |    4 ++--
 net/bluetooth/l2cap.c                   |   20 ++++++++++----------
 net/bridge/br_fdb.c                     |    4 ++--
 net/bridge/br_sysfs_br.c                |    6 +++---
 net/bridge/netfilter/ebt_stp.c          |    4 ++--
 net/can/af_can.c                        |    8 ++++----
 net/core/dev.c                          |    7 ++++---
 net/core/pktgen.c                       |    5 ++---
 net/dcb/dcbnl.c                         |    4 ++--
 net/decnet/dn_table.c                   |    5 +++--
 net/ipv4/igmp.c                         |    5 +++--
 net/ipv4/netfilter.c                    |    8 ++++----
 net/irda/irnet/irnet_irda.c             |    4 ++--
 net/mac80211/agg-rx.c                   |    6 +++---
 net/mac80211/main.c                     |    4 ++--
 net/mac80211/mesh.c                     |    4 ++--
 net/mac80211/mesh_hwmp.c                |   15 +++++++--------
 net/mac80211/rx.c                       |    4 ++--
 net/mac80211/tx.c                       |    9 +++++----
 net/netfilter/nf_conntrack_expect.c     |    6 +++---
 net/netfilter/nf_conntrack_ftp.c        |    8 ++++----
 net/packet/af_packet.c                  |    7 ++++---
 net/phonet/pep.c                        |    4 ++--
 net/phonet/socket.c                     |    4 ++--
 net/rds/af_rds.c                        |    8 ++++----
 net/rds/connection.c                    |    6 ++----
 net/rds/ib_cm.c                         |    4 ++--
 net/rds/ib_rdma.c                       |    4 ++--
 net/rds/ib_recv.c                       |   12 ++++++------
 net/rds/ib_send.c                       |    4 ++--
 net/rds/iw_rdma.c                       |    4 ++--
 net/rds/iw_recv.c                       |   12 ++++++------
 net/rds/iw_send.c                       |    7 +++----
 net/rds/message.c                       |    3 +--
 net/rds/rdma.c                          |   12 ++++++------
 net/rds/recv.c                          |   11 +++++------
 net/rds/send.c                          |   27 +++++++++++++--------------
 net/rds/threads.c                       |    4 ++--
 net/rose/rose_route.c                   |   10 ++++++----
 net/sched/cls_rsvp.h                    |   28 +++++++++++++++-------------
 net/sched/sch_htb.c                     |    4 ++--
 net/sched/sch_netem.c                   |   12 ++++++------
 net/sched/sch_teql.c                    |   11 +++++++----
 net/sctp/outqueue.c                     |    4 ++--
 net/sctp/socket.c                       |    4 ++--
 net/sunrpc/auth.c                       |    6 +++---
 net/sunrpc/auth_gss/gss_krb5_seqnum.c   |    4 ++--
 net/sunrpc/auth_gss/svcauth_gss.c       |    4 ++--
 net/sunrpc/cache.c                      |    5 ++---
 net/sunrpc/svc.c                        |    5 +++--
 net/sunrpc/svc_xprt.c                   |    8 ++++----
 net/sunrpc/svcauth.c                    |    4 ++--
 net/sunrpc/svcauth_unix.c               |    4 ++--
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |    7 +++----
 net/sunrpc/xprtrdma/verbs.c             |    4 ++--
 net/tipc/cluster.c                      |   16 ++++++++--------
 net/tipc/link.c                         |   12 ++++++------
 net/tipc/socket.c                       |   12 +++++-------
 net/tipc/subscr.c                       |    6 +++---
 net/unix/af_unix.c                      |    8 ++++----
 net/wimax/op-rfkill.c                   |    8 ++++----
 net/wireless/scan.c                     |    4 ++--
 net/wireless/wext-core.c                |    5 +++--
 63 files changed, 235 insertions(+), 233 deletions(-)

diff --git a/net/9p/trans_fd.c b/net/9p/trans_fd.c
index 8d934dd..4dd873e 100644
--- a/net/9p/trans_fd.c
+++ b/net/9p/trans_fd.c
@@ -633,8 +633,8 @@ static void p9_poll_mux(struct p9_conn *m)
 	if (n & POLLOUT) {
 		set_bit(Wpending, &m->wsched);
 		P9_DPRINTK(P9_DEBUG_TRANS, "mux %p can write\n", m);
-		if ((m->wsize || !list_empty(&m->unsent_req_list))
-		    && !test_and_set_bit(Wworksched, &m->wsched)) {
+		if ((m->wsize || !list_empty(&m->unsent_req_list)) &&
+		    !test_and_set_bit(Wworksched, &m->wsched)) {
 			P9_DPRINTK(P9_DEBUG_TRANS, "sched write work %p\n", m);
 			queue_work(p9_mux_wq, &m->wq);
 		}
diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 80d9298..54992f7 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -1362,8 +1362,8 @@ static int l2cap_ertm_send(struct sock *sk)
 	if (pi->conn_state & L2CAP_CONN_WAIT_F)
 		return 0;
 
-	while ((skb = sk->sk_send_head) && (!l2cap_tx_window_full(sk))
-			&& !(pi->conn_state & L2CAP_CONN_REMOTE_BUSY)) {
+	while ((skb = sk->sk_send_head) && (!l2cap_tx_window_full(sk)) &&
+	       !(pi->conn_state & L2CAP_CONN_REMOTE_BUSY)) {
 		tx_skb = skb_clone(skb, GFP_ATOMIC);
 
 		if (pi->remote_max_tx &&
@@ -1604,8 +1604,8 @@ static int l2cap_sock_sendmsg(struct kiocb *iocb, struct socket *sock, struct ms
 		return -EOPNOTSUPP;
 
 	/* Check outgoing MTU */
-	if (sk->sk_type == SOCK_SEQPACKET && pi->mode == L2CAP_MODE_BASIC
-			&& len > pi->omtu)
+	if (sk->sk_type == SOCK_SEQPACKET && pi->mode == L2CAP_MODE_BASIC &&
+	    len > pi->omtu)
 		return -EINVAL;
 
 	lock_sock(sk);
@@ -2756,8 +2756,8 @@ static inline int l2cap_config_req(struct l2cap_conn *conn, struct l2cap_cmd_hdr
 		goto unlock;
 
 	if (l2cap_pi(sk)->conf_state & L2CAP_CONF_INPUT_DONE) {
-		if (!(l2cap_pi(sk)->conf_state & L2CAP_CONF_NO_FCS_RECV)
-				|| l2cap_pi(sk)->fcs != L2CAP_FCS_NONE)
+		if (!(l2cap_pi(sk)->conf_state & L2CAP_CONF_NO_FCS_RECV) ||
+		    l2cap_pi(sk)->fcs != L2CAP_FCS_NONE)
 			l2cap_pi(sk)->fcs = L2CAP_FCS_CRC16;
 
 		sk->sk_state = BT_CONNECTED;
@@ -2845,8 +2845,8 @@ static inline int l2cap_config_rsp(struct l2cap_conn *conn, struct l2cap_cmd_hdr
 	l2cap_pi(sk)->conf_state |= L2CAP_CONF_INPUT_DONE;
 
 	if (l2cap_pi(sk)->conf_state & L2CAP_CONF_OUTPUT_DONE) {
-		if (!(l2cap_pi(sk)->conf_state & L2CAP_CONF_NO_FCS_RECV)
-				|| l2cap_pi(sk)->fcs != L2CAP_FCS_NONE)
+		if (!(l2cap_pi(sk)->conf_state & L2CAP_CONF_NO_FCS_RECV) ||
+		    l2cap_pi(sk)->fcs != L2CAP_FCS_NONE)
 			l2cap_pi(sk)->fcs = L2CAP_FCS_CRC16;
 
 		sk->sk_state = BT_CONNECTED;
@@ -3388,8 +3388,8 @@ static inline int l2cap_data_channel_sframe(struct sock *sk, u16 rx_control, str
 			pi->expected_ack_seq = tx_seq;
 			l2cap_drop_acked_frames(sk);
 
-			if ((pi->conn_state & L2CAP_CONN_REMOTE_BUSY)
-					&& (pi->unacked_frames > 0))
+			if ((pi->conn_state & L2CAP_CONN_REMOTE_BUSY) &&
+			    (pi->unacked_frames > 0))
 				__mod_retrans_timer();
 
 			l2cap_ertm_send(sk);
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 57bf05c..3b8e038 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -60,8 +60,8 @@ static inline unsigned long hold_time(const struct net_bridge *br)
 static inline int has_expired(const struct net_bridge *br,
 				  const struct net_bridge_fdb_entry *fdb)
 {
-	return !fdb->is_static
-		&& time_before_eq(fdb->ageing_timer + hold_time(br), jiffies);
+	return !fdb->is_static &&
+		time_before_eq(fdb->ageing_timer + hold_time(br), jiffies);
 }
 
 static inline int br_mac_hash(const unsigned char *mac)
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index ee4820a..bee4f30 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -316,9 +316,9 @@ static ssize_t store_group_addr(struct device *d,
 	if (new_addr[5] & ~0xf)
 		return -EINVAL;
 
-	if (new_addr[5] == 1 	/* 802.3x Pause address */
-	    || new_addr[5] == 2 /* 802.3ad Slow protocols */
-	    || new_addr[5] == 3) /* 802.1X PAE address */
+	if (new_addr[5] == 1 ||		/* 802.3x Pause address */
+	    new_addr[5] == 2 ||		/* 802.3ad Slow protocols */
+	    new_addr[5] == 3)		/* 802.1X PAE address */
 		return -EINVAL;
 
 	spin_lock_bh(&br->lock);
diff --git a/net/bridge/netfilter/ebt_stp.c b/net/bridge/netfilter/ebt_stp.c
index 48527e6..75e29a9 100644
--- a/net/bridge/netfilter/ebt_stp.c
+++ b/net/bridge/netfilter/ebt_stp.c
@@ -135,8 +135,8 @@ ebt_stp_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	if (memcmp(sp, header, sizeof(header)))
 		return false;
 
-	if (info->bitmask & EBT_STP_TYPE
-	    && FWINV(info->type != sp->type, EBT_STP_TYPE))
+	if (info->bitmask & EBT_STP_TYPE &&
+	    FWINV(info->type != sp->type, EBT_STP_TYPE))
 		return false;
 
 	if (sp->type == BPDU_TYPE_CONFIG &&
diff --git a/net/can/af_can.c b/net/can/af_can.c
index f306717..51adc4c 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -375,8 +375,8 @@ static struct hlist_head *find_rcv_list(canid_t *can_id, canid_t *mask,
 		return &d->rx[RX_ALL];
 
 	/* extra filterlists for the subscription of a single non-RTR can_id */
-	if (((*mask & CAN_EFF_RTR_FLAGS) == CAN_EFF_RTR_FLAGS)
-	    && !(*can_id & CAN_RTR_FLAG)) {
+	if (((*mask & CAN_EFF_RTR_FLAGS) == CAN_EFF_RTR_FLAGS) &&
+	    !(*can_id & CAN_RTR_FLAG)) {
 
 		if (*can_id & CAN_EFF_FLAG) {
 			if (*mask == (CAN_EFF_MASK | CAN_EFF_RTR_FLAGS)) {
@@ -525,8 +525,8 @@ void can_rx_unregister(struct net_device *dev, canid_t can_id, canid_t mask,
 	 */
 
 	hlist_for_each_entry_rcu(r, next, rl, list) {
-		if (r->can_id == can_id && r->mask == mask
-		    && r->func == func && r->data == data)
+		if (r->can_id == can_id && r->mask == mask &&
+		    r->func == func && r->data == data)
 			break;
 	}
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 7775e8b..5d131c2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2677,9 +2677,10 @@ __napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 		return GRO_NORMAL;
 
 	for (p = napi->gro_list; p; p = p->next) {
-		NAPI_GRO_CB(p)->same_flow = (p->dev == skb->dev)
-			&& !compare_ether_header(skb_mac_header(p),
-						 skb_gro_mac_header(skb));
+		NAPI_GRO_CB(p)->same_flow =
+			(p->dev == skb->dev) &&
+			!compare_ether_header(skb_mac_header(p),
+					      skb_gro_mac_header(skb));
 		NAPI_GRO_CB(p)->flush = 0;
 	}
 
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 19ee493..a23b45f 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2052,9 +2052,8 @@ static void pktgen_setup_inject(struct pktgen_dev *pkt_dev)
 				read_lock_bh(&idev->lock);
 				for (ifp = idev->addr_list; ifp;
 				     ifp = ifp->if_next) {
-					if (ifp->scope == IFA_LINK
-					    && !(ifp->
-						 flags & IFA_F_TENTATIVE)) {
+					if (ifp->scope == IFA_LINK &&
+					    !(ifp->flags & IFA_F_TENTATIVE)) {
 						ipv6_addr_copy(&pkt_dev->
 							       cur_in6_saddr,
 							       &ifp->addr);
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 2afd617..db9f5b3 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -1085,8 +1085,8 @@ static int dcbnl_bcn_setcfg(struct net_device *netdev, struct nlattr **tb,
 	u8 value_byte;
 	u32 value_int;
 
-	if (!tb[DCB_ATTR_BCN] || !netdev->dcbnl_ops->setbcncfg
-	    || !netdev->dcbnl_ops->setbcnrp)
+	if (!tb[DCB_ATTR_BCN] || !netdev->dcbnl_ops->setbcncfg ||
+	    !netdev->dcbnl_ops->setbcnrp)
 		return ret;
 
 	ret = nla_parse_nested(data, DCB_BCN_ATTR_MAX,
diff --git a/net/decnet/dn_table.c b/net/decnet/dn_table.c
index f281e0f..b9a33bb 100644
--- a/net/decnet/dn_table.c
+++ b/net/decnet/dn_table.c
@@ -581,8 +581,9 @@ static int dn_fib_table_insert(struct dn_fib_table *tb, struct rtmsg *r, struct
 		DN_FIB_SCAN_KEY(f, fp, key) {
 			if (fi->fib_priority != DN_FIB_INFO(f)->fib_priority)
 				break;
-			if (f->fn_type == type && f->fn_scope == r->rtm_scope
-					&& DN_FIB_INFO(f) == fi)
+			if (f->fn_type == type &&
+			    f->fn_scope == r->rtm_scope &&
+			    DN_FIB_INFO(f) == fi)
 				goto out;
 		}
 
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 6110c6d..76c0840 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1899,8 +1899,9 @@ int ip_mc_source(int add, int omode, struct sock *sk, struct
 	err = -EADDRNOTAVAIL;
 
 	for (pmc=inet->mc_list; pmc; pmc=pmc->next) {
-		if (pmc->multi.imr_multiaddr.s_addr == imr.imr_multiaddr.s_addr
-		    && pmc->multi.imr_ifindex == imr.imr_ifindex)
+		if ((pmc->multi.imr_multiaddr.s_addr ==
+		     imr.imr_multiaddr.s_addr) &&
+		    (pmc->multi.imr_ifindex == imr.imr_ifindex))
 			break;
 	}
 	if (!pmc) {		/* must have a prior join */
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index 1725dc0..f53cb8d 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -155,10 +155,10 @@ static int nf_ip_reroute(struct sk_buff *skb,
 	if (entry->hook == NF_INET_LOCAL_OUT) {
 		const struct iphdr *iph = ip_hdr(skb);
 
-		if (!(iph->tos == rt_info->tos
-		      && skb->mark == rt_info->mark
-		      && iph->daddr == rt_info->daddr
-		      && iph->saddr == rt_info->saddr))
+		if (!(iph->tos == rt_info->tos &&
+		      skb->mark == rt_info->mark &&
+		      iph->daddr == rt_info->daddr &&
+		      iph->saddr == rt_info->saddr))
 			return ip_route_me_harder(skb, RTN_UNSPEC);
 	}
 	return 0;
diff --git a/net/irda/irnet/irnet_irda.c b/net/irda/irnet/irnet_irda.c
index cccc2e9..b26dee7 100644
--- a/net/irda/irnet/irnet_irda.c
+++ b/net/irda/irnet/irnet_irda.c
@@ -1403,8 +1403,8 @@ irnet_connect_indication(void *		instance,
   /* Socket already connecting ? On primary ? */
   if(0
 #ifdef ALLOW_SIMULT_CONNECT
-     || ((irttp_is_primary(server->tsap) == 1)	/* primary */
-	 && (test_and_clear_bit(0, &new->ttp_connect)))
+     || ((irttp_is_primary(server->tsap) == 1) &&	/* primary */
+	 (test_and_clear_bit(0, &new->ttp_connect)))
 #endif /* ALLOW_SIMULT_CONNECT */
      )
     {
diff --git a/net/mac80211/agg-rx.c b/net/mac80211/agg-rx.c
index 7ed5fe6..614c65d 100644
--- a/net/mac80211/agg-rx.c
+++ b/net/mac80211/agg-rx.c
@@ -211,9 +211,9 @@ void ieee80211_process_addba_request(struct ieee80211_local *local,
 	 * check if configuration can support the BA policy
 	 * and if buffer size does not exceeds max value */
 	/* XXX: check own ht delayed BA capability?? */
-	if (((ba_policy != 1)
-		&& (!(sta->sta.ht_cap.cap & IEEE80211_HT_CAP_DELAY_BA)))
-		|| (buf_size > IEEE80211_MAX_AMPDU_BUF)) {
+	if (((ba_policy != 1) &&
+	     (!(sta->sta.ht_cap.cap & IEEE80211_HT_CAP_DELAY_BA))) ||
+	    (buf_size > IEEE80211_MAX_AMPDU_BUF)) {
 		status = WLAN_STATUS_INVALID_QOS_PARAM;
 #ifdef CONFIG_MAC80211_HT_DEBUG
 		if (net_ratelimit())
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index dd8ec8d..8116d1a 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -631,8 +631,8 @@ void ieee80211_unregister_hw(struct ieee80211_hw *hw)
 	sta_info_stop(local);
 	rate_control_deinitialize(local);
 
-	if (skb_queue_len(&local->skb_queue)
-			|| skb_queue_len(&local->skb_queue_unreliable))
+	if (skb_queue_len(&local->skb_queue) ||
+	    skb_queue_len(&local->skb_queue_unreliable))
 		printk(KERN_WARNING "%s: skb_queue not empty\n",
 		       wiphy_name(local->hw.wiphy));
 	skb_queue_purge(&local->skb_queue);
diff --git a/net/mac80211/mesh.c b/net/mac80211/mesh.c
index 51adb11..c0fe464 100644
--- a/net/mac80211/mesh.c
+++ b/net/mac80211/mesh.c
@@ -195,8 +195,8 @@ int mesh_rmc_check(u8 *sa, struct ieee80211s_hdr *mesh_hdr,
 			list_del(&p->list);
 			kmem_cache_free(rm_cache, p);
 			--entries;
-		} else if ((seqnum == p->seqnum)
-				&& (memcmp(sa, p->sa, ETH_ALEN) == 0))
+		} else if ((seqnum == p->seqnum) &&
+			   (memcmp(sa, p->sa, ETH_ALEN) == 0))
 			return -1;
 	}
 
diff --git a/net/mac80211/mesh_hwmp.c b/net/mac80211/mesh_hwmp.c
index 9aecf02..833b2f3 100644
--- a/net/mac80211/mesh_hwmp.c
+++ b/net/mac80211/mesh_hwmp.c
@@ -936,17 +936,16 @@ int mesh_nexthop_lookup(struct sk_buff *skb,
 	}
 
 	if (mpath->flags & MESH_PATH_ACTIVE) {
-		if (time_after(jiffies, mpath->exp_time +
-			msecs_to_jiffies(sdata->u.mesh.mshcfg.path_refresh_time))
-				&& !memcmp(sdata->dev->dev_addr, hdr->addr4,
-					   ETH_ALEN)
-				&& !(mpath->flags & MESH_PATH_RESOLVING)
-				&& !(mpath->flags & MESH_PATH_FIXED)) {
+		if (time_after(jiffies,
+			       mpath->exp_time +
+			       msecs_to_jiffies(sdata->u.mesh.mshcfg.path_refresh_time)) &&
+		    !memcmp(sdata->dev->dev_addr, hdr->addr4, ETH_ALEN) &&
+		    !(mpath->flags & MESH_PATH_RESOLVING) &&
+		    !(mpath->flags & MESH_PATH_FIXED)) {
 			mesh_queue_preq(mpath,
 					PREQ_Q_F_START | PREQ_Q_F_REFRESH);
 		}
-		memcpy(hdr->addr1, mpath->next_hop->sta.addr,
-				ETH_ALEN);
+		memcpy(hdr->addr1, mpath->next_hop->sta.addr, ETH_ALEN);
 	} else {
 		struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
 		if (!(mpath->flags & MESH_PATH_RESOLVING)) {
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 96f13ad..beecf50 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -1168,8 +1168,8 @@ ieee80211_drop_unencrypted(struct ieee80211_rx_data *rx, __le16 fc)
 			     rx->key))
 			return -EACCES;
 		/* BIP does not use Protected field, so need to check MMIE */
-		if (unlikely(ieee80211_is_multicast_robust_mgmt_frame(rx->skb)
-			     && ieee80211_get_mmie_keyidx(rx->skb) < 0 &&
+		if (unlikely(ieee80211_is_multicast_robust_mgmt_frame(rx->skb) &&
+			     ieee80211_get_mmie_keyidx(rx->skb) < 0 &&
 			     rx->key))
 			return -EACCES;
 		/*
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 943def2..8834cc9 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -366,10 +366,11 @@ ieee80211_tx_h_unicast_ps_buf(struct ieee80211_tx_data *tx)
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)tx->skb->data;
 	u32 staflags;
 
-	if (unlikely(!sta || ieee80211_is_probe_resp(hdr->frame_control)
-			|| ieee80211_is_auth(hdr->frame_control)
-			|| ieee80211_is_assoc_resp(hdr->frame_control)
-			|| ieee80211_is_reassoc_resp(hdr->frame_control)))
+	if (unlikely(!sta ||
+		     ieee80211_is_probe_resp(hdr->frame_control) ||
+		     ieee80211_is_auth(hdr->frame_control) ||
+		     ieee80211_is_assoc_resp(hdr->frame_control) ||
+		     ieee80211_is_reassoc_resp(hdr->frame_control)))
 		return TX_CONTINUE;
 
 	staflags = get_sta_flags(sta);
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index 2032dfe..fdf5d2a 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -202,9 +202,9 @@ static inline int expect_clash(const struct nf_conntrack_expect *a,
 static inline int expect_matches(const struct nf_conntrack_expect *a,
 				 const struct nf_conntrack_expect *b)
 {
-	return a->master == b->master && a->class == b->class
-		&& nf_ct_tuple_equal(&a->tuple, &b->tuple)
-		&& nf_ct_tuple_mask_equal(&a->mask, &b->mask);
+	return a->master == b->master && a->class == b->class &&
+		nf_ct_tuple_equal(&a->tuple, &b->tuple) &&
+		nf_ct_tuple_mask_equal(&a->mask, &b->mask);
 }
 
 /* Generally a bad idea to call this: could have matched already. */
diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntrack_ftp.c
index 5509dd1..38ea7ef 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -243,8 +243,8 @@ static int try_epsv_response(const char *data, size_t dlen,
 	/* Three delimiters. */
 	if (dlen <= 3) return 0;
 	delim = data[0];
-	if (isdigit(delim) || delim < 33 || delim > 126
-	    || data[1] != delim || data[2] != delim)
+	if (isdigit(delim) || delim < 33 || delim > 126 ||
+	    data[1] != delim || data[2] != delim)
 		return 0;
 
 	return get_port(data, 3, dlen, delim, &cmd->u.tcp.port);
@@ -366,8 +366,8 @@ static int help(struct sk_buff *skb,
 	typeof(nf_nat_ftp_hook) nf_nat_ftp;
 
 	/* Until there's been traffic both ways, don't look in packets. */
-	if (ctinfo != IP_CT_ESTABLISHED
-	    && ctinfo != IP_CT_ESTABLISHED+IP_CT_IS_REPLY) {
+	if (ctinfo != IP_CT_ESTABLISHED &&
+	    ctinfo != IP_CT_ESTABLISHED + IP_CT_IS_REPLY) {
 		pr_debug("ftp: Conntrackinfo = %u\n", ctinfo);
 		return NF_ACCEPT;
 	}
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 940fc20..0205621 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1034,9 +1034,10 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 			goto out_xmit;
 		packet_increment_head(&po->tx_ring);
 		len_sum += tp_len;
-	} while (likely((ph != NULL) || ((!(msg->msg_flags & MSG_DONTWAIT))
-					&& (atomic_read(&po->tx_ring.pending))))
-	      );
+	} while (likely((ph != NULL) ||
+			((!(msg->msg_flags & MSG_DONTWAIT)) &&
+			 (atomic_read(&po->tx_ring.pending))))
+		);
 
 	err = len_sum;
 	goto out_put;
diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index bdc17bd..b6356f3 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -714,8 +714,8 @@ static int pep_ioctl(struct sock *sk, int cmd, unsigned long arg)
 			return -EINVAL;
 
 		lock_sock(sk);
-		if (sock_flag(sk, SOCK_URGINLINE)
-		 && !skb_queue_empty(&pn->ctrlreq_queue))
+		if (sock_flag(sk, SOCK_URGINLINE) &&
+		    !skb_queue_empty(&pn->ctrlreq_queue))
 			answ = skb_peek(&pn->ctrlreq_queue)->len;
 		else if (!skb_queue_empty(&sk->sk_receive_queue))
 			answ = skb_peek(&sk->sk_receive_queue)->len;
diff --git a/net/phonet/socket.c b/net/phonet/socket.c
index 4112b6e..69c8b82 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -98,8 +98,8 @@ struct sock *pn_find_sock_by_sa(struct net *net, const struct sockaddr_pn *spn)
 			if (pn->resource != res)
 				continue;
 		}
-		if (pn_addr(pn->sobject)
-		 && pn_addr(pn->sobject) != pn_addr(obj))
+		if (pn_addr(pn->sobject) &&
+		    pn_addr(pn->sobject) != pn_addr(obj))
 			continue;
 
 		rval = sknode;
diff --git a/net/rds/af_rds.c b/net/rds/af_rds.c
index e25d8d5..853c52b 100644
--- a/net/rds/af_rds.c
+++ b/net/rds/af_rds.c
@@ -174,8 +174,8 @@ static unsigned int rds_poll(struct file *file, struct socket *sock,
 			mask |= (POLLIN | POLLRDNORM);
 		spin_unlock(&rs->rs_lock);
 	}
-	if (!list_empty(&rs->rs_recv_queue)
-	 || !list_empty(&rs->rs_notify_queue))
+	if (!list_empty(&rs->rs_recv_queue) ||
+	    !list_empty(&rs->rs_notify_queue))
 		mask |= (POLLIN | POLLRDNORM);
 	if (rs->rs_snd_bytes < rds_sk_sndbuf(rs))
 		mask |= (POLLOUT | POLLWRNORM);
@@ -308,8 +308,8 @@ static int rds_getsockopt(struct socket *sock, int level, int optname,
 		if (len < sizeof(int))
 			ret = -EINVAL;
 		else
-		if (put_user(rs->rs_recverr, (int __user *) optval)
-		 || put_user(sizeof(int), optlen))
+		if (put_user(rs->rs_recverr, (int __user *) optval) ||
+		    put_user(sizeof(int), optlen))
 			ret = -EFAULT;
 		else
 			ret = 0;
diff --git a/net/rds/connection.c b/net/rds/connection.c
index cc8b568..278f607 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -133,10 +133,8 @@ static struct rds_connection *__rds_conn_create(__be32 laddr, __be32 faddr,
 
 	spin_lock_irqsave(&rds_conn_lock, flags);
 	conn = rds_conn_lookup(head, laddr, faddr, trans);
-	if (conn
-	 && conn->c_loopback
-	 && conn->c_trans != &rds_loop_transport
-	 && !is_outgoing) {
+	if (conn && conn->c_loopback && conn->c_trans != &rds_loop_transport &&
+	    !is_outgoing) {
 		/* This is a looped back IB connection, and we're
 		 * called by the code handling the incoming connect.
 		 * We need a second connection object into which we
diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index 9d32069..647cb8f 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -377,8 +377,8 @@ static u32 rds_ib_protocol_compatible(struct rdma_cm_event *event)
 	}
 
 	/* Even if len is crap *now* I still want to check it. -ASG */
-	if (event->param.conn.private_data_len < sizeof (*dp)
-	    || dp->dp_protocol_major == 0)
+	if (event->param.conn.private_data_len < sizeof (*dp) ||
+	    dp->dp_protocol_major == 0)
 		return RDS_PROTOCOL_3_0;
 
 	common = be16_to_cpu(dp->dp_protocol_minor_mask) & RDS_IB_SUPPORTED_PROTOCOLS;
diff --git a/net/rds/ib_rdma.c b/net/rds/ib_rdma.c
index c5e9165..4b0da86 100644
--- a/net/rds/ib_rdma.c
+++ b/net/rds/ib_rdma.c
@@ -570,8 +570,8 @@ void rds_ib_free_mr(void *trans_private, int invalidate)
 	spin_unlock_irqrestore(&pool->list_lock, flags);
 
 	/* If we've pinned too many pages, request a flush */
-	if (atomic_read(&pool->free_pinned) >= pool->max_free_pinned
-	 || atomic_read(&pool->dirty_count) >= pool->max_items / 10)
+	if (atomic_read(&pool->free_pinned) >= pool->max_free_pinned ||
+	    atomic_read(&pool->dirty_count) >= pool->max_items / 10)
 		queue_work(rds_wq, &pool->flush_worker);
 
 	if (invalidate) {
diff --git a/net/rds/ib_recv.c b/net/rds/ib_recv.c
index fe5ab8c..04dc0d3 100644
--- a/net/rds/ib_recv.c
+++ b/net/rds/ib_recv.c
@@ -230,8 +230,8 @@ int rds_ib_recv_refill(struct rds_connection *conn, gfp_t kptr_gfp,
 	int ret = 0;
 	u32 pos;
 
-	while ((prefill || rds_conn_up(conn))
-			&& rds_ib_ring_alloc(&ic->i_recv_ring, 1, &pos)) {
+	while ((prefill || rds_conn_up(conn)) &&
+	       rds_ib_ring_alloc(&ic->i_recv_ring, 1, &pos)) {
 		if (pos >= ic->i_recv_ring.w_nr) {
 			printk(KERN_NOTICE "Argh - ring alloc returned pos=%u\n",
 					pos);
@@ -771,10 +771,10 @@ static void rds_ib_process_recv(struct rds_connection *conn,
 		hdr = &ibinc->ii_inc.i_hdr;
 		/* We can't just use memcmp here; fragments of a
 		 * single message may carry different ACKs */
-		if (hdr->h_sequence != ihdr->h_sequence
-		 || hdr->h_len != ihdr->h_len
-		 || hdr->h_sport != ihdr->h_sport
-		 || hdr->h_dport != ihdr->h_dport) {
+		if (hdr->h_sequence != ihdr->h_sequence ||
+		    hdr->h_len != ihdr->h_len ||
+		    hdr->h_sport != ihdr->h_sport ||
+		    hdr->h_dport != ihdr->h_dport) {
 			rds_ib_conn_error(conn,
 				"fragment header mismatch; forcing reconnect\n");
 			return;
diff --git a/net/rds/ib_send.c b/net/rds/ib_send.c
index 23bf830..a10fab6 100644
--- a/net/rds/ib_send.c
+++ b/net/rds/ib_send.c
@@ -252,8 +252,8 @@ void rds_ib_send_cq_comp_handler(struct ib_cq *cq, void *context)
 
 		rds_ib_ring_free(&ic->i_send_ring, completed);
 
-		if (test_and_clear_bit(RDS_LL_SEND_FULL, &conn->c_flags)
-		 || test_bit(0, &conn->c_map_queued))
+		if (test_and_clear_bit(RDS_LL_SEND_FULL, &conn->c_flags) ||
+		    test_bit(0, &conn->c_map_queued))
 			queue_delayed_work(rds_wq, &conn->c_send_w, 0);
 
 		/* We expect errors as the qp is drained during shutdown */
diff --git a/net/rds/iw_rdma.c b/net/rds/iw_rdma.c
index b25d785..9eda11c 100644
--- a/net/rds/iw_rdma.c
+++ b/net/rds/iw_rdma.c
@@ -573,8 +573,8 @@ void rds_iw_free_mr(void *trans_private, int invalidate)
 	rds_iw_free_fastreg(pool, ibmr);
 
 	/* If we've pinned too many pages, request a flush */
-	if (atomic_read(&pool->free_pinned) >= pool->max_free_pinned
-	 || atomic_read(&pool->dirty_count) >= pool->max_items / 10)
+	if (atomic_read(&pool->free_pinned) >= pool->max_free_pinned ||
+	    atomic_read(&pool->dirty_count) >= pool->max_items / 10)
 		queue_work(rds_wq, &pool->flush_worker);
 
 	if (invalidate) {
diff --git a/net/rds/iw_recv.c b/net/rds/iw_recv.c
index 24fc53f..54af7d6 100644
--- a/net/rds/iw_recv.c
+++ b/net/rds/iw_recv.c
@@ -230,8 +230,8 @@ int rds_iw_recv_refill(struct rds_connection *conn, gfp_t kptr_gfp,
 	int ret = 0;
 	u32 pos;
 
-	while ((prefill || rds_conn_up(conn))
-			&& rds_iw_ring_alloc(&ic->i_recv_ring, 1, &pos)) {
+	while ((prefill || rds_conn_up(conn)) &&
+	       rds_iw_ring_alloc(&ic->i_recv_ring, 1, &pos)) {
 		if (pos >= ic->i_recv_ring.w_nr) {
 			printk(KERN_NOTICE "Argh - ring alloc returned pos=%u\n",
 					pos);
@@ -730,10 +730,10 @@ static void rds_iw_process_recv(struct rds_connection *conn,
 		hdr = &iwinc->ii_inc.i_hdr;
 		/* We can't just use memcmp here; fragments of a
 		 * single message may carry different ACKs */
-		if (hdr->h_sequence != ihdr->h_sequence
-		 || hdr->h_len != ihdr->h_len
-		 || hdr->h_sport != ihdr->h_sport
-		 || hdr->h_dport != ihdr->h_dport) {
+		if (hdr->h_sequence != ihdr->h_sequence ||
+		    hdr->h_len != ihdr->h_len ||
+		    hdr->h_sport != ihdr->h_sport ||
+		    hdr->h_dport != ihdr->h_dport) {
 			rds_iw_conn_error(conn,
 				"fragment header mismatch; forcing reconnect\n");
 			return;
diff --git a/net/rds/iw_send.c b/net/rds/iw_send.c
index 1f5abe3..1379e9d 100644
--- a/net/rds/iw_send.c
+++ b/net/rds/iw_send.c
@@ -288,8 +288,8 @@ void rds_iw_send_cq_comp_handler(struct ib_cq *cq, void *context)
 
 		rds_iw_ring_free(&ic->i_send_ring, completed);
 
-		if (test_and_clear_bit(RDS_LL_SEND_FULL, &conn->c_flags)
-		 || test_bit(0, &conn->c_map_queued))
+		if (test_and_clear_bit(RDS_LL_SEND_FULL, &conn->c_flags) ||
+		    test_bit(0, &conn->c_map_queued))
 			queue_delayed_work(rds_wq, &conn->c_send_w, 0);
 
 		/* We expect errors as the qp is drained during shutdown */
@@ -519,8 +519,7 @@ int rds_iw_xmit(struct rds_connection *conn, struct rds_message *rm,
 	BUG_ON(hdr_off != 0 && hdr_off != sizeof(struct rds_header));
 
 	/* Fastreg support */
-	if (rds_rdma_cookie_key(rm->m_rdma_cookie)
-	 && !ic->i_fastreg_posted) {
+	if (rds_rdma_cookie_key(rm->m_rdma_cookie) && !ic->i_fastreg_posted) {
 		ret = -EAGAIN;
 		goto out;
 	}
diff --git a/net/rds/message.c b/net/rds/message.c
index ca50a8e..73e600f 100644
--- a/net/rds/message.c
+++ b/net/rds/message.c
@@ -122,8 +122,7 @@ int rds_message_add_extension(struct rds_header *hdr,
 	if (hdr->h_exthdr[0] != RDS_EXTHDR_NONE)
 		return 0;
 
-	if (type >= __RDS_EXTHDR_MAX
-	 || len != rds_exthdr_size[type])
+	if (type >= __RDS_EXTHDR_MAX || len != rds_exthdr_size[type])
 		return 0;
 
 	if (ext_len >= RDS_HEADER_EXT_SPACE)
diff --git a/net/rds/rdma.c b/net/rds/rdma.c
index 971b5a6..4c64daa 100644
--- a/net/rds/rdma.c
+++ b/net/rds/rdma.c
@@ -631,8 +631,8 @@ int rds_cmsg_rdma_args(struct rds_sock *rs, struct rds_message *rm,
 {
 	struct rds_rdma_op *op;
 
-	if (cmsg->cmsg_len < CMSG_LEN(sizeof(struct rds_rdma_args))
-	 || rm->m_rdma_op != NULL)
+	if (cmsg->cmsg_len < CMSG_LEN(sizeof(struct rds_rdma_args)) ||
+	    rm->m_rdma_op != NULL)
 		return -EINVAL;
 
 	op = rds_rdma_prepare(rs, CMSG_DATA(cmsg));
@@ -655,8 +655,8 @@ int rds_cmsg_rdma_dest(struct rds_sock *rs, struct rds_message *rm,
 	u32 r_key;
 	int err = 0;
 
-	if (cmsg->cmsg_len < CMSG_LEN(sizeof(rds_rdma_cookie_t))
-	 || rm->m_rdma_cookie != 0)
+	if (cmsg->cmsg_len < CMSG_LEN(sizeof(rds_rdma_cookie_t)) ||
+	    rm->m_rdma_cookie != 0)
 		return -EINVAL;
 
 	memcpy(&rm->m_rdma_cookie, CMSG_DATA(cmsg), sizeof(rm->m_rdma_cookie));
@@ -692,8 +692,8 @@ int rds_cmsg_rdma_dest(struct rds_sock *rs, struct rds_message *rm,
 int rds_cmsg_rdma_map(struct rds_sock *rs, struct rds_message *rm,
 			  struct cmsghdr *cmsg)
 {
-	if (cmsg->cmsg_len < CMSG_LEN(sizeof(struct rds_get_mr_args))
-	 || rm->m_rdma_cookie != 0)
+	if (cmsg->cmsg_len < CMSG_LEN(sizeof(struct rds_get_mr_args)) ||
+	    rm->m_rdma_cookie != 0)
 		return -EINVAL;
 
 	return __rds_rdma_map(rs, CMSG_DATA(cmsg), &rm->m_rdma_cookie, &rm->m_rdma_mr);
diff --git a/net/rds/recv.c b/net/rds/recv.c
index fdff33c..b426d67 100644
--- a/net/rds/recv.c
+++ b/net/rds/recv.c
@@ -195,8 +195,8 @@ void rds_recv_incoming(struct rds_connection *conn, __be32 saddr, __be32 daddr,
 	 * XXX we could spend more on the wire to get more robust failure
 	 * detection, arguably worth it to avoid data corruption.
 	 */
-	if (be64_to_cpu(inc->i_hdr.h_sequence) < conn->c_next_rx_seq
-	 && (inc->i_hdr.h_flags & RDS_FLAG_RETRANSMITTED)) {
+	if (be64_to_cpu(inc->i_hdr.h_sequence) < conn->c_next_rx_seq &&
+	    (inc->i_hdr.h_flags & RDS_FLAG_RETRANSMITTED)) {
 		rds_stats_inc(s_recv_drop_old_seq);
 		goto out;
 	}
@@ -432,10 +432,9 @@ int rds_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 			}
 
 			timeo = wait_event_interruptible_timeout(*sk->sk_sleep,
-						(!list_empty(&rs->rs_notify_queue)
-						|| rs->rs_cong_notify
-						|| rds_next_incoming(rs, &inc)),
-						timeo);
+					(!list_empty(&rs->rs_notify_queue) ||
+					 rs->rs_cong_notify ||
+					 rds_next_incoming(rs, &inc)), timeo);
 			rdsdebug("recvmsg woke inc %p timeo %ld\n", inc,
 				 timeo);
 			if (timeo > 0 || timeo == MAX_SCHEDULE_TIMEOUT)
diff --git a/net/rds/send.c b/net/rds/send.c
index 28c88ff..b2fccfc 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -235,8 +235,8 @@ int rds_send_xmit(struct rds_connection *conn)
 			 * connection.
 			 * Therefore, we never retransmit messages with RDMA ops.
 			 */
-			if (rm->m_rdma_op
-			 && test_bit(RDS_MSG_RETRANSMITTED, &rm->m_flags)) {
+			if (rm->m_rdma_op &&
+			    test_bit(RDS_MSG_RETRANSMITTED, &rm->m_flags)) {
 				spin_lock_irqsave(&conn->c_lock, flags);
 				if (test_and_clear_bit(RDS_MSG_ON_CONN, &rm->m_flags))
 					list_move(&rm->m_conn_item, &to_be_dropped);
@@ -247,8 +247,8 @@ int rds_send_xmit(struct rds_connection *conn)
 
 			/* Require an ACK every once in a while */
 			len = ntohl(rm->m_inc.i_hdr.h_len);
-			if (conn->c_unacked_packets == 0
-			 || conn->c_unacked_bytes < len) {
+			if (conn->c_unacked_packets == 0 ||
+			    conn->c_unacked_bytes < len) {
 				__set_bit(RDS_MSG_ACK_REQUIRED, &rm->m_flags);
 
 				conn->c_unacked_packets = rds_sysctl_max_unacked_packets;
@@ -418,8 +418,8 @@ void rds_rdma_send_complete(struct rds_message *rm, int status)
 	spin_lock(&rm->m_rs_lock);
 
 	ro = rm->m_rdma_op;
-	if (test_bit(RDS_MSG_ON_SOCK, &rm->m_flags)
-	 && ro && ro->r_notify && ro->r_notifier) {
+	if (test_bit(RDS_MSG_ON_SOCK, &rm->m_flags) &&
+	    ro && ro->r_notify && ro->r_notifier) {
 		notifier = ro->r_notifier;
 		rs = rm->m_rs;
 		sock_hold(rds_rs_to_sk(rs));
@@ -549,8 +549,7 @@ void rds_send_remove_from_sock(struct list_head *messages, int status)
 			list_del_init(&rm->m_sock_item);
 			rds_send_sndbuf_remove(rs, rm);
 
-			if (ro && ro->r_notifier
-			   && (status || ro->r_notify)) {
+			if (ro && ro->r_notifier && (status || ro->r_notify)) {
 				notifier = ro->r_notifier;
 				list_add_tail(&notifier->n_list,
 						&rs->rs_notify_queue);
@@ -877,8 +876,8 @@ int rds_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 	if (ret)
 		goto out;
 
-	if ((rm->m_rdma_cookie || rm->m_rdma_op)
-	 && conn->c_trans->xmit_rdma == NULL) {
+	if ((rm->m_rdma_cookie || rm->m_rdma_op) &&
+	    conn->c_trans->xmit_rdma == NULL) {
 		if (printk_ratelimit())
 			printk(KERN_NOTICE "rdma_op %p conn xmit_rdma %p\n",
 				rm->m_rdma_op, conn->c_trans->xmit_rdma);
@@ -890,8 +889,8 @@ int rds_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 	 * have scheduled a delayed reconnect however - in this case
 	 * we should not interfere.
 	 */
-	if (rds_conn_state(conn) == RDS_CONN_DOWN
-	 && !test_and_set_bit(RDS_RECONNECT_PENDING, &conn->c_flags))
+	if (rds_conn_state(conn) == RDS_CONN_DOWN &&
+	    !test_and_set_bit(RDS_RECONNECT_PENDING, &conn->c_flags))
 		queue_delayed_work(rds_wq, &conn->c_conn_w, 0);
 
 	ret = rds_cong_wait(conn->c_fcong, dport, nonblock, rs);
@@ -973,8 +972,8 @@ rds_send_pong(struct rds_connection *conn, __be16 dport)
 	 * have scheduled a delayed reconnect however - in this case
 	 * we should not interfere.
 	 */
-	if (rds_conn_state(conn) == RDS_CONN_DOWN
-	 && !test_and_set_bit(RDS_RECONNECT_PENDING, &conn->c_flags))
+	if (rds_conn_state(conn) == RDS_CONN_DOWN &&
+	    !test_and_set_bit(RDS_RECONNECT_PENDING, &conn->c_flags))
 		queue_delayed_work(rds_wq, &conn->c_conn_w, 0);
 
 	ret = rds_cong_wait(conn->c_fcong, dport, 1, NULL);
diff --git a/net/rds/threads.c b/net/rds/threads.c
index dd7e0ca..00fa10e 100644
--- a/net/rds/threads.c
+++ b/net/rds/threads.c
@@ -170,8 +170,8 @@ void rds_shutdown_worker(struct work_struct *work)
 		 * handler is supposed to check for state DISCONNECTING
 		 */
 		mutex_lock(&conn->c_cm_lock);
-		if (!rds_conn_transition(conn, RDS_CONN_UP, RDS_CONN_DISCONNECTING)
-		 && !rds_conn_transition(conn, RDS_CONN_ERROR, RDS_CONN_DISCONNECTING)) {
+		if (!rds_conn_transition(conn, RDS_CONN_UP, RDS_CONN_DISCONNECTING) &&
+		    !rds_conn_transition(conn, RDS_CONN_ERROR, RDS_CONN_DISCONNECTING)) {
 			rds_conn_error(conn, "shutdown called in state %d\n",
 					atomic_read(&conn->c_state));
 			mutex_unlock(&conn->c_cm_lock);
diff --git a/net/rose/rose_route.c b/net/rose/rose_route.c
index ea2e723..795c4b0 100644
--- a/net/rose/rose_route.c
+++ b/net/rose/rose_route.c
@@ -77,8 +77,9 @@ static int __must_check rose_add_node(struct rose_route_struct *rose_route,
 
 	rose_neigh = rose_neigh_list;
 	while (rose_neigh != NULL) {
-		if (ax25cmp(&rose_route->neighbour, &rose_neigh->callsign) == 0
-		    && rose_neigh->dev == dev)
+		if (ax25cmp(&rose_route->neighbour,
+			    &rose_neigh->callsign) == 0 &&
+		    rose_neigh->dev == dev)
 			break;
 		rose_neigh = rose_neigh->next;
 	}
@@ -311,8 +312,9 @@ static int rose_del_node(struct rose_route_struct *rose_route,
 
 	rose_neigh = rose_neigh_list;
 	while (rose_neigh != NULL) {
-		if (ax25cmp(&rose_route->neighbour, &rose_neigh->callsign) == 0
-		    && rose_neigh->dev == dev)
+		if (ax25cmp(&rose_route->neighbour,
+			    &rose_neigh->callsign) == 0 &&
+		    rose_neigh->dev == dev)
 			break;
 		rose_neigh = rose_neigh->next;
 	}
diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index 7034ea4..dd9414e 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -170,21 +170,23 @@ restart:
 	for (s = sht[h1]; s; s = s->next) {
 		if (dst[RSVP_DST_LEN-1] == s->dst[RSVP_DST_LEN-1] &&
 		    protocol == s->protocol &&
-		    !(s->dpi.mask & (*(u32*)(xprt+s->dpi.offset)^s->dpi.key))
+		    !(s->dpi.mask &
+		      (*(u32*)(xprt+s->dpi.offset)^s->dpi.key)) &&
 #if RSVP_DST_LEN == 4
-		    && dst[0] == s->dst[0]
-		    && dst[1] == s->dst[1]
-		    && dst[2] == s->dst[2]
+		    dst[0] == s->dst[0] &&
+		    dst[1] == s->dst[1] &&
+		    dst[2] == s->dst[2] &&
 #endif
-		    && tunnelid == s->tunnelid) {
+		    tunnelid == s->tunnelid) {
 
 			for (f = s->ht[h2]; f; f = f->next) {
 				if (src[RSVP_DST_LEN-1] == f->src[RSVP_DST_LEN-1] &&
 				    !(f->spi.mask & (*(u32*)(xprt+f->spi.offset)^f->spi.key))
 #if RSVP_DST_LEN == 4
-				    && src[0] == f->src[0]
-				    && src[1] == f->src[1]
-				    && src[2] == f->src[2]
+				    &&
+				    src[0] == f->src[0] &&
+				    src[1] == f->src[1] &&
+				    src[2] == f->src[2]
 #endif
 				    ) {
 					*res = f->res;
@@ -493,13 +495,13 @@ static int rsvp_change(struct tcf_proto *tp, unsigned long base,
 	for (sp = &data->ht[h1]; (s=*sp) != NULL; sp = &s->next) {
 		if (dst[RSVP_DST_LEN-1] == s->dst[RSVP_DST_LEN-1] &&
 		    pinfo && pinfo->protocol == s->protocol &&
-		    memcmp(&pinfo->dpi, &s->dpi, sizeof(s->dpi)) == 0
+		    memcmp(&pinfo->dpi, &s->dpi, sizeof(s->dpi)) == 0 &&
 #if RSVP_DST_LEN == 4
-		    && dst[0] == s->dst[0]
-		    && dst[1] == s->dst[1]
-		    && dst[2] == s->dst[2]
+		    dst[0] == s->dst[0] &&
+		    dst[1] == s->dst[1] &&
+		    dst[2] == s->dst[2] &&
 #endif
-		    && pinfo->tunnelid == s->tunnelid) {
+		    pinfo->tunnelid == s->tunnelid) {
 
 insert:
 			/* OK, we found appropriate session */
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 2e38d1a..508cf5f 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1344,8 +1344,8 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 		};
 
 		/* check for valid classid */
-		if (!classid || TC_H_MAJ(classid ^ sch->handle)
-		    || htb_find(classid, sch))
+		if (!classid || TC_H_MAJ(classid ^ sch->handle) ||
+		    htb_find(classid, sch))
 			goto failure;
 
 		/* check maximal depth */
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 2b88295..d8b10e0 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -199,9 +199,9 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	 * do it now in software before we mangle it.
 	 */
 	if (q->corrupt && q->corrupt >= get_crandom(&q->corrupt_cor)) {
-		if (!(skb = skb_unshare(skb, GFP_ATOMIC))
-		    || (skb->ip_summed == CHECKSUM_PARTIAL
-			&& skb_checksum_help(skb))) {
+		if (!(skb = skb_unshare(skb, GFP_ATOMIC)) ||
+		    (skb->ip_summed == CHECKSUM_PARTIAL &&
+		     skb_checksum_help(skb))) {
 			sch->qstats.drops++;
 			return NET_XMIT_DROP;
 		}
@@ -210,9 +210,9 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	}
 
 	cb = netem_skb_cb(skb);
-	if (q->gap == 0 		/* not doing reordering */
-	    || q->counter < q->gap 	/* inside last reordering gap */
-	    || q->reorder < get_crandom(&q->reorder_cor)) {
+	if (q->gap == 0 || 		/* not doing reordering */
+	    q->counter < q->gap || 	/* inside last reordering gap */
+	    q->reorder < get_crandom(&q->reorder_cor)) {
 		psched_time_t now;
 		psched_tdiff_t delay;
 
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index 5a002c2..db69637 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -190,10 +190,13 @@ static int teql_qdisc_init(struct Qdisc *sch, struct nlattr *opt)
 
 	if (m->slaves) {
 		if (m->dev->flags & IFF_UP) {
-			if ((m->dev->flags&IFF_POINTOPOINT && !(dev->flags&IFF_POINTOPOINT))
-			    || (m->dev->flags&IFF_BROADCAST && !(dev->flags&IFF_BROADCAST))
-			    || (m->dev->flags&IFF_MULTICAST && !(dev->flags&IFF_MULTICAST))
-			    || dev->mtu < m->dev->mtu)
+			if ((m->dev->flags & IFF_POINTOPOINT &&
+			     !(dev->flags & IFF_POINTOPOINT)) ||
+			    (m->dev->flags & IFF_BROADCAST &&
+			     !(dev->flags & IFF_BROADCAST)) ||
+			    (m->dev->flags & IFF_MULTICAST &&
+			     !(dev->flags & IFF_MULTICAST)) ||
+			    dev->mtu < m->dev->mtu)
 				return -EINVAL;
 		} else {
 			if (!(dev->flags&IFF_POINTOPOINT))
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index e231a98..229690f 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -191,8 +191,8 @@ static inline int sctp_cacc_skip(struct sctp_transport *primary,
 				 __u32 tsn)
 {
 	if (primary->cacc.changeover_active &&
-	    (sctp_cacc_skip_3_1(primary, transport, count_of_newacks)
-	     || sctp_cacc_skip_3_2(primary, tsn)))
+	    (sctp_cacc_skip_3_1(primary, transport, count_of_newacks) ||
+	     sctp_cacc_skip_3_2(primary, tsn)))
 		return 1;
 	return 0;
 }
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 71513b3..5fa9ac5 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2356,8 +2356,8 @@ static int sctp_setsockopt_peer_addr_params(struct sock *sk,
 	    pmtud_change     == SPP_PMTUD ||
 	    sackdelay_change == SPP_SACKDELAY ||
 	    params.spp_sackdelay > 500 ||
-	    (params.spp_pathmtu
-	    && params.spp_pathmtu < SCTP_DEFAULT_MINSEGMENT))
+	    (params.spp_pathmtu &&
+	     params.spp_pathmtu < SCTP_DEFAULT_MINSEGMENT))
 		return -EINVAL;
 
 	/* If an address other than INADDR_ANY is specified, and
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 54a4e04..7535a7b 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -332,9 +332,9 @@ rpcauth_lookup_credcache(struct rpc_auth *auth, struct auth_cred * acred,
 		list_add_tail(&new->cr_lru, &free);
 	spin_unlock(&cache->lock);
 found:
-	if (test_bit(RPCAUTH_CRED_NEW, &cred->cr_flags)
-			&& cred->cr_ops->cr_init != NULL
-			&& !(flags & RPCAUTH_LOOKUP_NEW)) {
+	if (test_bit(RPCAUTH_CRED_NEW, &cred->cr_flags) &&
+	    cred->cr_ops->cr_init != NULL &&
+	    !(flags & RPCAUTH_LOOKUP_NEW)) {
 		int res = cred->cr_ops->cr_init(auth, cred);
 		if (res < 0) {
 			put_rpccred(cred);
diff --git a/net/sunrpc/auth_gss/gss_krb5_seqnum.c b/net/sunrpc/auth_gss/gss_krb5_seqnum.c
index f160be6..17562b4 100644
--- a/net/sunrpc/auth_gss/gss_krb5_seqnum.c
+++ b/net/sunrpc/auth_gss/gss_krb5_seqnum.c
@@ -75,8 +75,8 @@ krb5_get_seq_num(struct crypto_blkcipher *key,
 	if ((code = krb5_decrypt(key, cksum, buf, plain, 8)))
 		return code;
 
-	if ((plain[4] != plain[5]) || (plain[4] != plain[6])
-				   || (plain[4] != plain[7]))
+	if ((plain[4] != plain[5]) || (plain[4] != plain[6]) ||
+	    (plain[4] != plain[7]))
 		return (s32)KG_BAD_SEQ;
 
 	*direction = plain[4];
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index f6c51e5..e34bc53 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -105,8 +105,8 @@ static int rsi_match(struct cache_head *a, struct cache_head *b)
 {
 	struct rsi *item = container_of(a, struct rsi, h);
 	struct rsi *tmp = container_of(b, struct rsi, h);
-	return netobj_equal(&item->in_handle, &tmp->in_handle)
-		&& netobj_equal(&item->in_token, &tmp->in_token);
+	return netobj_equal(&item->in_handle, &tmp->in_handle) &&
+	       netobj_equal(&item->in_token, &tmp->in_token);
 }
 
 static int dup_to_netobj(struct xdr_netobj *dst, char *src, int len)
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index d6eee29..39bddba 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -401,9 +401,8 @@ static int cache_clean(void)
 		for (; ch; cp= & ch->next, ch= *cp) {
 			if (current_detail->nextcheck > ch->expiry_time)
 				current_detail->nextcheck = ch->expiry_time+1;
-			if (ch->expiry_time >= get_seconds()
-			    && ch->last_refresh >= current_detail->flush_time
-				)
+			if (ch->expiry_time >= get_seconds() &&
+			    ch->last_refresh >= current_detail->flush_time)
 				continue;
 			if (test_and_clear_bit(CACHE_PENDING, &ch->flags))
 				cache_dequeue(current_detail, ch);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 952f206..538ca43 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1103,8 +1103,9 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 				procp->pc_release(rqstp, NULL, rqstp->rq_resp);
 			goto dropit;
 		}
-		if (*statp == rpc_success && (xdr = procp->pc_encode)
-		 && !xdr(rqstp, resv->iov_base+resv->iov_len, rqstp->rq_resp)) {
+		if (*statp == rpc_success &&
+		    (xdr = procp->pc_encode) &&
+		    !xdr(rqstp, resv->iov_base+resv->iov_len, rqstp->rq_resp)) {
 			dprintk("svc: failed to encode reply\n");
 			/* serv->sv_stats->rpcsystemerr++; */
 			*statp = rpc_system_err;
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index df124f7..b845e22 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -129,8 +129,8 @@ static void svc_xprt_free(struct kref *kref)
 	struct svc_xprt *xprt =
 		container_of(kref, struct svc_xprt, xpt_ref);
 	struct module *owner = xprt->xpt_class->xcl_owner;
-	if (test_bit(XPT_CACHE_AUTH, &xprt->xpt_flags)
-	    && xprt->xpt_auth_cache != NULL)
+	if (test_bit(XPT_CACHE_AUTH, &xprt->xpt_flags) &&
+	    xprt->xpt_auth_cache != NULL)
 		svcauth_unix_info_release(xprt->xpt_auth_cache);
 	xprt->xpt_ops->xpo_free(xprt);
 	module_put(owner);
@@ -846,8 +846,8 @@ static void svc_age_temp_xprts(unsigned long closure)
 		 * through, close it. */
 		if (!test_and_set_bit(XPT_OLD, &xprt->xpt_flags))
 			continue;
-		if (atomic_read(&xprt->xpt_ref.refcount) > 1
-		    || test_bit(XPT_BUSY, &xprt->xpt_flags))
+		if (atomic_read(&xprt->xpt_ref.refcount) > 1 ||
+		    test_bit(XPT_BUSY, &xprt->xpt_flags))
 			continue;
 		svc_xprt_get(xprt);
 		list_move(le, &to_be_aged);
diff --git a/net/sunrpc/svcauth.c b/net/sunrpc/svcauth.c
index e64109b..4e9393c 100644
--- a/net/sunrpc/svcauth.c
+++ b/net/sunrpc/svcauth.c
@@ -46,8 +46,8 @@ svc_authenticate(struct svc_rqst *rqstp, __be32 *authp)
 	dprintk("svc: svc_authenticate (%d)\n", flavor);
 
 	spin_lock(&authtab_lock);
-	if (flavor >= RPC_AUTH_MAXFLAVOR || !(aops = authtab[flavor])
-			|| !try_module_get(aops->owner)) {
+	if (flavor >= RPC_AUTH_MAXFLAVOR || !(aops = authtab[flavor]) ||
+	    !try_module_get(aops->owner)) {
 		spin_unlock(&authtab_lock);
 		*authp = rpc_autherr_badcred;
 		return SVC_DENIED;
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index f4c7ff3..4a8f655 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -125,8 +125,8 @@ static int ip_map_match(struct cache_head *corig, struct cache_head *cnew)
 {
 	struct ip_map *orig = container_of(corig, struct ip_map, h);
 	struct ip_map *new = container_of(cnew, struct ip_map, h);
-	return strcmp(orig->m_class, new->m_class) == 0
-		&& ipv6_addr_equal(&orig->m_addr, &new->m_addr);
+	return strcmp(orig->m_class, new->m_class) == 0 &&
+	       ipv6_addr_equal(&orig->m_addr, &new->m_addr);
 }
 static void ip_map_init(struct cache_head *cnew, struct cache_head *citem)
 {
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 9e88438..f92e37e 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -337,10 +337,9 @@ static int rdma_set_ctxt_sge(struct svcxprt_rdma *xprt,
 
 static int rdma_read_max_sge(struct svcxprt_rdma *xprt, int sge_count)
 {
-	if ((RDMA_TRANSPORT_IWARP ==
-	     rdma_node_get_transport(xprt->sc_cm_id->
-				     device->node_type))
-	    && sge_count > 1)
+	if ((rdma_node_get_transport(xprt->sc_cm_id->device->node_type) ==
+	     RDMA_TRANSPORT_IWARP) &&
+	    sge_count > 1)
 		return 1;
 	else
 		return min_t(int, sge_count, xprt->sc_max_sge);
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 465aafc..2209aa8 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -878,8 +878,8 @@ if (strnicmp(ia->ri_id->device->dma_device->bus->name, "pci", 3) == 0) {
 	 * others indicate a transport condition which has already
 	 * undergone a best-effort.
 	 */
-	if (ep->rep_connected == -ECONNREFUSED
-	    && ++retry_count <= RDMA_CONNECT_RETRY_MAX) {
+	if (ep->rep_connected == -ECONNREFUSED &&
+	    ++retry_count <= RDMA_CONNECT_RETRY_MAX) {
 		dprintk("RPC:       %s: non-peer_reject, retry\n", __func__);
 		goto retry;
 	}
diff --git a/net/tipc/cluster.c b/net/tipc/cluster.c
index 689fdef..a7eac00 100644
--- a/net/tipc/cluster.c
+++ b/net/tipc/cluster.c
@@ -437,11 +437,11 @@ void tipc_cltr_recv_routing_table(struct sk_buff *buf)
 		break;
 	case ROUTE_ADDITION:
 		if (!is_slave(tipc_own_addr)) {
-			assert(!in_own_cluster(c_ptr->addr)
-			       || is_slave(rem_node));
+			assert(!in_own_cluster(c_ptr->addr) ||
+			       is_slave(rem_node));
 		} else {
-			assert(in_own_cluster(c_ptr->addr)
-			       && !is_slave(rem_node));
+			assert(in_own_cluster(c_ptr->addr) &&
+			       !is_slave(rem_node));
 		}
 		n_ptr = c_ptr->nodes[tipc_node(rem_node)];
 		if (!n_ptr)
@@ -451,11 +451,11 @@ void tipc_cltr_recv_routing_table(struct sk_buff *buf)
 		break;
 	case ROUTE_REMOVAL:
 		if (!is_slave(tipc_own_addr)) {
-			assert(!in_own_cluster(c_ptr->addr)
-			       || is_slave(rem_node));
+			assert(!in_own_cluster(c_ptr->addr) ||
+			       is_slave(rem_node));
 		} else {
-			assert(in_own_cluster(c_ptr->addr)
-			       && !is_slave(rem_node));
+			assert(in_own_cluster(c_ptr->addr) &&
+			       !is_slave(rem_node));
 		}
 		n_ptr = c_ptr->nodes[tipc_node(rem_node)];
 		if (n_ptr)
diff --git a/net/tipc/link.c b/net/tipc/link.c
index dd4c18b..6f50f64 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -378,8 +378,8 @@ static void link_timeout(struct link *l_ptr)
 		struct tipc_msg *msg = buf_msg(l_ptr->first_out);
 		u32 length = msg_size(msg);
 
-		if ((msg_user(msg) == MSG_FRAGMENTER)
-		    && (msg_type(msg) == FIRST_FRAGMENT)) {
+		if ((msg_user(msg) == MSG_FRAGMENTER) &&
+		    (msg_type(msg) == FIRST_FRAGMENT)) {
 			length = msg_size(msg_get_wrapped(msg));
 		}
 		if (length) {
@@ -2788,8 +2788,8 @@ int tipc_link_recv_fragment(struct sk_buff **pending, struct sk_buff **fb,
 
 	/* Is there an incomplete message waiting for this fragment? */
 
-	while (pbuf && ((msg_seqno(buf_msg(pbuf)) != long_msg_seq_no)
-			|| (msg_orignode(fragm) != msg_orignode(buf_msg(pbuf))))) {
+	while (pbuf && ((msg_seqno(buf_msg(pbuf)) != long_msg_seq_no) ||
+			(msg_orignode(fragm) != msg_orignode(buf_msg(pbuf))))) {
 		prev = pbuf;
 		pbuf = pbuf->next;
 	}
@@ -3325,8 +3325,8 @@ static void link_print(struct link *l_ptr, struct print_buf *buf,
 				      (l_ptr->last_out)), l_ptr->out_queue_size);
 		if ((mod(msg_seqno(buf_msg(l_ptr->last_out)) -
 			 msg_seqno(buf_msg(l_ptr->first_out)))
-		     != (l_ptr->out_queue_size - 1))
-		    || (l_ptr->last_out->next != NULL)) {
+		     != (l_ptr->out_queue_size - 1)) ||
+		    (l_ptr->last_out->next != NULL)) {
 			tipc_printf(buf, "\nSend queue inconsistency\n");
 			tipc_printf(buf, "first_out= %x ", l_ptr->first_out);
 			tipc_printf(buf, "next_out= %x ", l_ptr->next_out);
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index eca5eb0..1ea64f0 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1136,13 +1136,11 @@ restart:
 
 	/* Loop around if more data is required */
 
-	if ((sz_copied < buf_len)    /* didn't get all requested data */
-	    && (!skb_queue_empty(&sk->sk_receive_queue) ||
-		(flags & MSG_WAITALL))
-				     /* ... and more is ready or required */
-	    && (!(flags & MSG_PEEK)) /* ... and aren't just peeking at data */
-	    && (!err)                /* ... and haven't reached a FIN */
-	    )
+	if ((sz_copied < buf_len) &&	/* didn't get all requested data */
+	    (!skb_queue_empty(&sk->sk_receive_queue) ||
+	     (flags & MSG_WAITALL)) &&	/* and more is ready or required */
+	    (!(flags & MSG_PEEK)) &&	/* and aren't just peeking at data */
+	    (!err))			/* and haven't reached a FIN */
 		goto restart;
 
 exit:
diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index 0747d8a..ac91f0d 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -364,9 +364,9 @@ static struct subscription *subscr_subscribe(struct tipc_subscr *s,
 	sub->seq.upper = htohl(s->seq.upper, swap);
 	sub->timeout = htohl(s->timeout, swap);
 	sub->filter = htohl(s->filter, swap);
-	if ((!(sub->filter & TIPC_SUB_PORTS)
-	     == !(sub->filter & TIPC_SUB_SERVICE))
-	    || (sub->seq.lower > sub->seq.upper)) {
+	if ((!(sub->filter & TIPC_SUB_PORTS) ==
+	     !(sub->filter & TIPC_SUB_SERVICE)) ||
+	    (sub->seq.lower > sub->seq.upper)) {
 		warn("Subscription rejected, illegal request\n");
 		kfree(sub);
 		subscr_terminate(subscriber);
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 7553ea6..f255119 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1033,8 +1033,8 @@ static int unix_stream_connect(struct socket *sock, struct sockaddr *uaddr,
 		goto out;
 	addr_len = err;
 
-	if (test_bit(SOCK_PASSCRED, &sock->flags)
-		&& !u->addr && (err = unix_autobind(sock)) != 0)
+	if (test_bit(SOCK_PASSCRED, &sock->flags) && !u->addr &&
+	    (err = unix_autobind(sock)) != 0)
 		goto out;
 
 	timeo = sock_sndtimeo(sk, flags & O_NONBLOCK);
@@ -1378,8 +1378,8 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 			goto out;
 	}
 
-	if (test_bit(SOCK_PASSCRED, &sock->flags)
-		&& !u->addr && (err = unix_autobind(sock)) != 0)
+	if (test_bit(SOCK_PASSCRED, &sock->flags) && !u->addr
+	    && (err = unix_autobind(sock)) != 0)
 		goto out;
 
 	err = -EMSGSIZE;
diff --git a/net/wimax/op-rfkill.c b/net/wimax/op-rfkill.c
index 94d339c..ae752a6 100644
--- a/net/wimax/op-rfkill.c
+++ b/net/wimax/op-rfkill.c
@@ -107,8 +107,8 @@ void wimax_report_rfkill_hw(struct wimax_dev *wimax_dev,
 
 	if (state != wimax_dev->rf_hw) {
 		wimax_dev->rf_hw = state;
-		if (wimax_dev->rf_hw == WIMAX_RF_ON
-		    && wimax_dev->rf_sw == WIMAX_RF_ON)
+		if (wimax_dev->rf_hw == WIMAX_RF_ON &&
+		    wimax_dev->rf_sw == WIMAX_RF_ON)
 			wimax_state = WIMAX_ST_READY;
 		else
 			wimax_state = WIMAX_ST_RADIO_OFF;
@@ -163,8 +163,8 @@ void wimax_report_rfkill_sw(struct wimax_dev *wimax_dev,
 
 	if (state != wimax_dev->rf_sw) {
 		wimax_dev->rf_sw = state;
-		if (wimax_dev->rf_hw == WIMAX_RF_ON
-		    && wimax_dev->rf_sw == WIMAX_RF_ON)
+		if (wimax_dev->rf_hw == WIMAX_RF_ON &&
+		    wimax_dev->rf_sw == WIMAX_RF_ON)
 			wimax_state = WIMAX_ST_READY;
 		else
 			wimax_state = WIMAX_ST_RADIO_OFF;
diff --git a/net/wireless/scan.c b/net/wireless/scan.c
index 227d57b..96df34c 100644
--- a/net/wireless/scan.c
+++ b/net/wireless/scan.c
@@ -937,8 +937,8 @@ ieee80211_bss(struct wiphy *wiphy, struct iw_request_info *info,
 		ie += ie[1] + 2;
 	}
 
-	if (bss->pub.capability & (WLAN_CAPABILITY_ESS | WLAN_CAPABILITY_IBSS)
-	    || ismesh) {
+	if (bss->pub.capability & (WLAN_CAPABILITY_ESS | WLAN_CAPABILITY_IBSS) ||
+	    ismesh) {
 		memset(&iwe, 0, sizeof(iwe));
 		iwe.cmd = SIOCGIWMODE;
 		if (ismesh)
diff --git a/net/wireless/wext-core.c b/net/wireless/wext-core.c
index a4e5ddc..58dfb95 100644
--- a/net/wireless/wext-core.c
+++ b/net/wireless/wext-core.c
@@ -911,8 +911,9 @@ static int wireless_process_ioctl(struct net *net, struct ifreq *ifr,
  */
 static int wext_permission_check(unsigned int cmd)
 {
-	if ((IW_IS_SET(cmd) || cmd == SIOCGIWENCODE || cmd == SIOCGIWENCODEEXT)
-	    && !capable(CAP_NET_ADMIN))
+	if ((IW_IS_SET(cmd) || cmd == SIOCGIWENCODE ||
+	     cmd == SIOCGIWENCODEEXT) &&
+	    !capable(CAP_NET_ADMIN))
 		return -EPERM;
 
 	return 0;


