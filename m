From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: return operator cleanup
Date: Thu, 23 Sep 2010 08:43:57 +0200
Message-ID: <1285224237.2380.111.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:60918 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750976Ab0IWGoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 02:44:11 -0400
Received: by fxm12 with SMTP id 12so570798fxm.19
        for <netdev@vger.kernel.org>; Wed, 22 Sep 2010 23:44:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change "return (EXPR);" to "return EXPR;"

return is not a function, parentheses are not required.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/atmdev.h                  |    2 -
 include/linux/etherdevice.h             |    4 +-
 include/linux/netdevice.h               |    2 -
 include/linux/skbuff.h                  |    6 +--
 include/net/bluetooth/hci_core.h        |    2 -
 include/net/bluetooth/l2cap.h           |    2 -
 include/net/inet_ecn.h                  |    2 -
 include/net/ip.h                        |    4 +-
 include/net/ipv6.h                      |   35 ++++++++---------
 include/net/irda/irlap.h                |    2 -
 include/net/irda/irlmp.h                |    2 -
 include/net/irda/irttp.h                |    2 -
 include/net/sch_generic.h               |    2 -
 include/net/sctp/sctp.h                 |   12 +++---
 include/net/sctp/sm.h                   |   10 ++---
 include/net/sctp/structs.h              |    2 -
 include/net/sctp/tsnmap.h               |    2 -
 include/net/tipc/tipc_msg.h             |   10 ++---
 net/802/fc.c                            |    2 -
 net/802/fddi.c                          |   12 +++---
 net/802/hippi.c                         |    2 -
 net/802/tr.c                            |    2 -
 net/8021q/vlan_core.c                   |    2 -
 net/9p/client.c                         |    4 +-
 net/bluetooth/rfcomm/core.c             |    4 +-
 net/core/flow.c                         |    4 +-
 net/core/neighbour.c                    |    6 +--
 net/core/utils.c                        |    2 -
 net/dccp/ccids/lib/loss_interval.c      |    2 -
 net/econet/af_econet.c                  |    4 +-
 net/ethernet/eth.c                      |    2 -
 net/ipv4/arp.c                          |    2 -
 net/ipv4/datagram.c                     |    2 -
 net/ipv4/inet_diag.c                    |    2 -
 net/ipv4/ip_fragment.c                  |    4 +-
 net/ipv4/ip_gre.c                       |    2 -
 net/ipv4/netfilter/arp_tables.c         |    2 -
 net/ipv4/route.c                        |    2 -
 net/ipv4/tcp_input.c                    |   10 ++---
 net/ipv4/tcp_minisocks.c                |    2 -
 net/ipv4/tcp_output.c                   |    8 ++--
 net/ipv4/tcp_westwood.c                 |    2 -
 net/ipv6/addrconf.c                     |    2 -
 net/ipv6/addrlabel.c                    |    5 +-
 net/ipv6/af_inet6.c                     |    6 +--
 net/ipv6/exthdrs_core.c                 |    4 +-
 net/ipv6/ip6_output.c                   |    4 +-
 net/ipv6/ndisc.c                        |    8 ++--
 net/ipv6/netfilter/ip6_tables.c         |   14 +++----
 net/ipv6/raw.c                          |   12 +++---
 net/ipv6/route.c                        |   14 +++----
 net/ipv6/tcp_ipv6.c                     |    2 -
 net/ipv6/xfrm6_policy.c                 |    2 -
 net/irda/af_irda.c                      |   14 +++----
 net/irda/discovery.c                    |    2 -
 net/irda/ircomm/ircomm_tty.c            |    4 +-
 net/irda/irlmp.c                        |    2 -
 net/irda/irlmp_frame.c                  |    2 -
 net/irda/irnet/irnet_irda.c             |   22 +++++------
 net/irda/irnet/irnet_ppp.c              |    8 ++--
 net/key/af_key.c                        |    4 +-
 net/mac80211/rate.c                     |    2 -
 net/rfkill/input.c                      |    2 -
 net/rose/rose_link.c                    |    4 +-
 net/sctp/protocol.c                     |    2 -
 net/sctp/socket.c                       |    6 +--
 net/sunrpc/auth_gss/auth_gss.c          |    2 -
 net/sunrpc/auth_gss/gss_generic_token.c |   44 +++++++++++-----------
 net/sunrpc/auth_gss/gss_krb5_seqnum.c   |    2 -
 net/sunrpc/auth_gss/gss_mech_switch.c   |    2 -
 net/sunrpc/sched.c                      |    2 -
 net/tipc/addr.c                         |    2 -
 net/tipc/bcast.c                        |    2 -
 net/tipc/bearer.c                       |    2 -
 net/tipc/dbg.c                          |    4 +-
 net/tipc/link.c                         |    6 +--
 net/tipc/link.h                         |   16 ++++----
 net/tipc/msg.h                          |    6 +--
 net/tipc/name_table.c                   |    2 -
 net/tipc/node.c                         |    6 +--
 net/tipc/port.h                         |    2 -
 net/tipc/socket.c                       |    2 -
 net/tipc/subscr.c                       |    2 -
 net/wireless/core.h                     |    2 -
 84 files changed, 220 insertions(+), 222 deletions(-)

diff --git a/include/linux/atmdev.h b/include/linux/atmdev.h
index f6481da..a8e4e83 100644
--- a/include/linux/atmdev.h
+++ b/include/linux/atmdev.h
@@ -449,7 +449,7 @@ void vcc_insert_socket(struct sock *sk);
 
 static inline int atm_guess_pdu2truesize(int size)
 {
-	return (SKB_DATA_ALIGN(size) + sizeof(struct skb_shared_info));
+	return SKB_DATA_ALIGN(size) + sizeof(struct skb_shared_info);
 }
 
 
diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index fb6aa60..f16a010 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -71,7 +71,7 @@ static inline int is_zero_ether_addr(const u8 *addr)
  */
 static inline int is_multicast_ether_addr(const u8 *addr)
 {
-	return (0x01 & addr[0]);
+	return 0x01 & addr[0];
 }
 
 /**
@@ -82,7 +82,7 @@ static inline int is_multicast_ether_addr(const u8 *addr)
  */
 static inline int is_local_ether_addr(const u8 *addr)
 {
-	return (0x02 & addr[0]);
+	return 0x02 & addr[0];
 }
 
 /**
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f7f1302..45dcda5 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1676,7 +1676,7 @@ static inline void netif_wake_subqueue(struct net_device *dev, u16 queue_index)
  */
 static inline int netif_is_multiqueue(const struct net_device *dev)
 {
-	return (dev->num_tx_queues > 1);
+	return dev->num_tx_queues > 1;
 }
 
 extern void netif_set_real_num_tx_queues(struct net_device *dev,
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 9e8085a..b2c41d1 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -601,7 +601,7 @@ static inline int skb_queue_empty(const struct sk_buff_head *list)
 static inline bool skb_queue_is_last(const struct sk_buff_head *list,
 				     const struct sk_buff *skb)
 {
-	return (skb->next == (struct sk_buff *) list);
+	return skb->next == (struct sk_buff *)list;
 }
 
 /**
@@ -614,7 +614,7 @@ static inline bool skb_queue_is_last(const struct sk_buff_head *list,
 static inline bool skb_queue_is_first(const struct sk_buff_head *list,
 				      const struct sk_buff *skb)
 {
-	return (skb->prev == (struct sk_buff *) list);
+	return skb->prev == (struct sk_buff *)list;
 }
 
 /**
@@ -2156,7 +2156,7 @@ static inline u16 skb_get_rx_queue(const struct sk_buff *skb)
 
 static inline bool skb_rx_queue_recorded(const struct sk_buff *skb)
 {
-	return (skb->queue_mapping != 0);
+	return skb->queue_mapping != 0;
 }
 
 extern u16 skb_tx_hash(const struct net_device *dev,
diff --git a/include/net/bluetooth/hci_core.h b/include/net/bluetooth/hci_core.h
index 4568b93..ebec8c9 100644
--- a/include/net/bluetooth/hci_core.h
+++ b/include/net/bluetooth/hci_core.h
@@ -233,7 +233,7 @@ static inline void inquiry_cache_init(struct hci_dev *hdev)
 static inline int inquiry_cache_empty(struct hci_dev *hdev)
 {
 	struct inquiry_cache *c = &hdev->inq_cache;
-	return (c->list == NULL);
+	return c->list == NULL;
 }
 
 static inline long inquiry_cache_age(struct hci_dev *hdev)
diff --git a/include/net/bluetooth/l2cap.h b/include/net/bluetooth/l2cap.h
index 6c24144..c819c8b 100644
--- a/include/net/bluetooth/l2cap.h
+++ b/include/net/bluetooth/l2cap.h
@@ -414,7 +414,7 @@ static inline int l2cap_tx_window_full(struct sock *sk)
 	if (sub < 0)
 		sub += 64;
 
-	return (sub == pi->remote_tx_win);
+	return sub == pi->remote_tx_win;
 }
 
 #define __get_txseq(ctrl) ((ctrl) & L2CAP_CTRL_TXSEQ) >> 1
diff --git a/include/net/inet_ecn.h b/include/net/inet_ecn.h
index 9b5d08f..88bdd01 100644
--- a/include/net/inet_ecn.h
+++ b/include/net/inet_ecn.h
@@ -27,7 +27,7 @@ static inline int INET_ECN_is_not_ect(__u8 dsfield)
 
 static inline int INET_ECN_is_capable(__u8 dsfield)
 {
-	return (dsfield & INET_ECN_ECT_0);
+	return dsfield & INET_ECN_ECT_0;
 }
 
 static inline __u8 INET_ECN_encapsulate(__u8 outer, __u8 inner)
diff --git a/include/net/ip.h b/include/net/ip.h
index 7691aca..dbee3fe 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -238,9 +238,9 @@ int ip_decrease_ttl(struct iphdr *iph)
 static inline
 int ip_dont_fragment(struct sock *sk, struct dst_entry *dst)
 {
-	return (inet_sk(sk)->pmtudisc == IP_PMTUDISC_DO ||
+	return  inet_sk(sk)->pmtudisc == IP_PMTUDISC_DO ||
 		(inet_sk(sk)->pmtudisc == IP_PMTUDISC_WANT &&
-		 !(dst_metric_locked(dst, RTAX_MTU))));
+		 !(dst_metric_locked(dst, RTAX_MTU)));
 }
 
 extern void __ip_select_ident(struct iphdr *iph, struct dst_entry *dst, int more);
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 1f84124..4a3cd2c 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -262,7 +262,7 @@ static inline int ipv6_addr_scope(const struct in6_addr *addr)
 
 static inline int __ipv6_addr_src_scope(int type)
 {
-	return (type == IPV6_ADDR_ANY ? __IPV6_ADDR_SCOPE_INVALID : (type >> 16));
+	return (type == IPV6_ADDR_ANY) ? __IPV6_ADDR_SCOPE_INVALID : (type >> 16);
 }
 
 static inline int ipv6_addr_src_scope(const struct in6_addr *addr)
@@ -279,10 +279,10 @@ static inline int
 ipv6_masked_addr_cmp(const struct in6_addr *a1, const struct in6_addr *m,
 		     const struct in6_addr *a2)
 {
-	return (!!(((a1->s6_addr32[0] ^ a2->s6_addr32[0]) & m->s6_addr32[0]) |
-		   ((a1->s6_addr32[1] ^ a2->s6_addr32[1]) & m->s6_addr32[1]) |
-		   ((a1->s6_addr32[2] ^ a2->s6_addr32[2]) & m->s6_addr32[2]) |
-		   ((a1->s6_addr32[3] ^ a2->s6_addr32[3]) & m->s6_addr32[3])));
+	return !!(((a1->s6_addr32[0] ^ a2->s6_addr32[0]) & m->s6_addr32[0]) |
+		  ((a1->s6_addr32[1] ^ a2->s6_addr32[1]) & m->s6_addr32[1]) |
+		  ((a1->s6_addr32[2] ^ a2->s6_addr32[2]) & m->s6_addr32[2]) |
+		  ((a1->s6_addr32[3] ^ a2->s6_addr32[3]) & m->s6_addr32[3]));
 }
 
 static inline void ipv6_addr_copy(struct in6_addr *a1, const struct in6_addr *a2)
@@ -317,10 +317,10 @@ static inline void ipv6_addr_set(struct in6_addr *addr,
 static inline int ipv6_addr_equal(const struct in6_addr *a1,
 				  const struct in6_addr *a2)
 {
-	return (((a1->s6_addr32[0] ^ a2->s6_addr32[0]) |
-		 (a1->s6_addr32[1] ^ a2->s6_addr32[1]) |
-		 (a1->s6_addr32[2] ^ a2->s6_addr32[2]) |
-		 (a1->s6_addr32[3] ^ a2->s6_addr32[3])) == 0);
+	return ((a1->s6_addr32[0] ^ a2->s6_addr32[0]) |
+		(a1->s6_addr32[1] ^ a2->s6_addr32[1]) |
+		(a1->s6_addr32[2] ^ a2->s6_addr32[2]) |
+		(a1->s6_addr32[3] ^ a2->s6_addr32[3])) == 0;
 }
 
 static inline int __ipv6_prefix_equal(const __be32 *a1, const __be32 *a2,
@@ -373,20 +373,20 @@ int ip6_frag_match(struct inet_frag_queue *q, void *a);
 
 static inline int ipv6_addr_any(const struct in6_addr *a)
 {
-	return ((a->s6_addr32[0] | a->s6_addr32[1] | 
-		 a->s6_addr32[2] | a->s6_addr32[3] ) == 0); 
+	return (a->s6_addr32[0] | a->s6_addr32[1] |
+		a->s6_addr32[2] | a->s6_addr32[3]) == 0;
 }
 
 static inline int ipv6_addr_loopback(const struct in6_addr *a)
 {
-	return ((a->s6_addr32[0] | a->s6_addr32[1] |
-		 a->s6_addr32[2] | (a->s6_addr32[3] ^ htonl(1))) == 0);
+	return (a->s6_addr32[0] | a->s6_addr32[1] |
+		a->s6_addr32[2] | (a->s6_addr32[3] ^ htonl(1))) == 0;
 }
 
 static inline int ipv6_addr_v4mapped(const struct in6_addr *a)
 {
-	return ((a->s6_addr32[0] | a->s6_addr32[1] |
-		 (a->s6_addr32[2] ^ htonl(0x0000ffff))) == 0);
+	return (a->s6_addr32[0] | a->s6_addr32[1] |
+		 (a->s6_addr32[2] ^ htonl(0x0000ffff))) == 0;
 }
 
 /*
@@ -395,8 +395,7 @@ static inline int ipv6_addr_v4mapped(const struct in6_addr *a)
  */
 static inline int ipv6_addr_orchid(const struct in6_addr *a)
 {
-	return ((a->s6_addr32[0] & htonl(0xfffffff0))
-		== htonl(0x20010010));
+	return (a->s6_addr32[0] & htonl(0xfffffff0)) == htonl(0x20010010);
 }
 
 static inline void ipv6_addr_set_v4mapped(const __be32 addr,
@@ -441,7 +440,7 @@ static inline int __ipv6_addr_diff(const void *token1, const void *token2, int a
 	 *	if returned value is greater than prefix length.
 	 *					--ANK (980803)
 	 */
-	return (addrlen << 5);
+	return addrlen << 5;
 }
 
 static inline int ipv6_addr_diff(const struct in6_addr *a1, const struct in6_addr *a2)
diff --git a/include/net/irda/irlap.h b/include/net/irda/irlap.h
index 9d0c78e..17fcd96 100644
--- a/include/net/irda/irlap.h
+++ b/include/net/irda/irlap.h
@@ -282,7 +282,7 @@ static inline int irlap_is_primary(struct irlap_cb *self)
 	default:
 		ret = -1;
 	}
-	return(ret);
+	return ret;
 }
 
 /* Clear a pending IrLAP disconnect. - Jean II */
diff --git a/include/net/irda/irlmp.h b/include/net/irda/irlmp.h
index 3ffc1d0..fff11b7 100644
--- a/include/net/irda/irlmp.h
+++ b/include/net/irda/irlmp.h
@@ -274,7 +274,7 @@ static inline int irlmp_lap_tx_queue_full(struct lsap_cb *self)
 	if (self->lap->irlap == NULL)
 		return 0;
 
-	return(IRLAP_GET_TX_QUEUE_LEN(self->lap->irlap) >= LAP_HIGH_THRESHOLD);
+	return IRLAP_GET_TX_QUEUE_LEN(self->lap->irlap) >= LAP_HIGH_THRESHOLD;
 }
 
 /* After doing a irlmp_dup(), this get one of the two socket back into
diff --git a/include/net/irda/irttp.h b/include/net/irda/irttp.h
index 11aee7a..af4b877 100644
--- a/include/net/irda/irttp.h
+++ b/include/net/irda/irttp.h
@@ -204,7 +204,7 @@ static inline int irttp_is_primary(struct tsap_cb *self)
 	    (self->lsap->lap == NULL) ||
 	    (self->lsap->lap->irlap == NULL))
 		return -2;
-	return(irlap_is_primary(self->lsap->lap->irlap));
+	return irlap_is_primary(self->lsap->lap->irlap);
 }
 
 #endif /* IRTTP_H */
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 3c8728a..eda8808 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -601,7 +601,7 @@ static inline u32 qdisc_l2t(struct qdisc_rate_table* rtab, unsigned int pktlen)
 		slot = 0;
 	slot >>= rtab->rate.cell_log;
 	if (slot > 255)
-		return (rtab->data[255]*(slot >> 8) + rtab->data[slot & 0xFF]);
+		return rtab->data[255]*(slot >> 8) + rtab->data[slot & 0xFF];
 	return rtab->data[slot];
 }
 
diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 2cb3980..505845d 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -405,7 +405,7 @@ static inline void sctp_v6_del_protocol(void) { return; }
 /* Map an association to an assoc_id. */
 static inline sctp_assoc_t sctp_assoc2id(const struct sctp_association *asoc)
 {
-	return (asoc?asoc->assoc_id:0);
+	return asoc ? asoc->assoc_id : 0;
 }
 
 /* Look up the association by its id.  */
@@ -473,7 +473,7 @@ static inline void sctp_skb_set_owner_r(struct sk_buff *skb, struct sock *sk)
 /* Tests if the list has one and only one entry. */
 static inline int sctp_list_single_entry(struct list_head *head)
 {
-	return ((head->next != head) && (head->next == head->prev));
+	return (head->next != head) && (head->next == head->prev);
 }
 
 /* Generate a random jitter in the range of -50% ~ +50% of input RTO. */
@@ -631,13 +631,13 @@ static inline int sctp_sanity_check(void)
 /* This is the hash function for the SCTP port hash table. */
 static inline int sctp_phashfn(__u16 lport)
 {
-	return (lport & (sctp_port_hashsize - 1));
+	return lport & (sctp_port_hashsize - 1);
 }
 
 /* This is the hash function for the endpoint hash table. */
 static inline int sctp_ep_hashfn(__u16 lport)
 {
-	return (lport & (sctp_ep_hashsize - 1));
+	return lport & (sctp_ep_hashsize - 1);
 }
 
 /* This is the hash function for the association hash table. */
@@ -645,7 +645,7 @@ static inline int sctp_assoc_hashfn(__u16 lport, __u16 rport)
 {
 	int h = (lport << 16) + rport;
 	h ^= h>>8;
-	return (h & (sctp_assoc_hashsize - 1));
+	return h & (sctp_assoc_hashsize - 1);
 }
 
 /* This is the hash function for the association hash table.  This is
@@ -656,7 +656,7 @@ static inline int sctp_vtag_hashfn(__u16 lport, __u16 rport, __u32 vtag)
 {
 	int h = (lport << 16) + rport;
 	h ^= vtag;
-	return (h & (sctp_assoc_hashsize-1));
+	return h & (sctp_assoc_hashsize - 1);
 }
 
 #define sctp_for_each_hentry(epb, node, head) \
diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index 4088c89..9352d12 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -345,12 +345,12 @@ enum {
 
 static inline int TSN_lt(__u32 s, __u32 t)
 {
-	return (((s) - (t)) & TSN_SIGN_BIT);
+	return ((s) - (t)) & TSN_SIGN_BIT;
 }
 
 static inline int TSN_lte(__u32 s, __u32 t)
 {
-	return (((s) == (t)) || (((s) - (t)) & TSN_SIGN_BIT));
+	return ((s) == (t)) || (((s) - (t)) & TSN_SIGN_BIT);
 }
 
 /* Compare two SSNs */
@@ -369,12 +369,12 @@ enum {
 
 static inline int SSN_lt(__u16 s, __u16 t)
 {
-	return (((s) - (t)) & SSN_SIGN_BIT);
+	return ((s) - (t)) & SSN_SIGN_BIT;
 }
 
 static inline int SSN_lte(__u16 s, __u16 t)
 {
-	return (((s) == (t)) || (((s) - (t)) & SSN_SIGN_BIT));
+	return ((s) == (t)) || (((s) - (t)) & SSN_SIGN_BIT);
 }
 
 /*
@@ -388,7 +388,7 @@ enum {
 
 static inline int ADDIP_SERIAL_gte(__u16 s, __u16 t)
 {
-	return (((s) == (t)) || (((t) - (s)) & ADDIP_SERIAL_SIGN_BIT));
+	return ((s) == (t)) || (((t) - (s)) & ADDIP_SERIAL_SIGN_BIT);
 }
 
 /* Check VTAG of the packet matches the sender's own tag. */
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index f9e7473..69fef4f 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -847,7 +847,7 @@ void sctp_packet_free(struct sctp_packet *);
 
 static inline int sctp_packet_empty(struct sctp_packet *packet)
 {
-	return (packet->size == packet->overhead);
+	return packet->size == packet->overhead;
 }
 
 /* This represents a remote transport address.
diff --git a/include/net/sctp/tsnmap.h b/include/net/sctp/tsnmap.h
index 4aabc5a..e7728bc 100644
--- a/include/net/sctp/tsnmap.h
+++ b/include/net/sctp/tsnmap.h
@@ -157,7 +157,7 @@ __u16 sctp_tsnmap_pending(struct sctp_tsnmap *map);
 /* Is there a gap in the TSN map?  */
 static inline int sctp_tsnmap_has_gap(const struct sctp_tsnmap *map)
 {
-	return (map->cumulative_tsn_ack_point != map->max_tsn_seen);
+	return map->cumulative_tsn_ack_point != map->max_tsn_seen;
 }
 
 /* Mark a duplicate TSN.  Note:  limit the storage of duplicate TSN
diff --git a/include/net/tipc/tipc_msg.h b/include/net/tipc/tipc_msg.h
index 2e159a8..ffe50b4 100644
--- a/include/net/tipc/tipc_msg.h
+++ b/include/net/tipc/tipc_msg.h
@@ -107,7 +107,7 @@ static inline u32 msg_hdr_sz(struct tipc_msg *m)
 
 static inline int msg_short(struct tipc_msg *m)
 {
-	return (msg_hdr_sz(m) == 24);
+	return msg_hdr_sz(m) == 24;
 }
 
 static inline u32 msg_size(struct tipc_msg *m)
@@ -117,7 +117,7 @@ static inline u32 msg_size(struct tipc_msg *m)
 
 static inline u32 msg_data_sz(struct tipc_msg *m)
 {
-	return (msg_size(m) - msg_hdr_sz(m));
+	return msg_size(m) - msg_hdr_sz(m);
 }
 
 static inline unchar *msg_data(struct tipc_msg *m)
@@ -132,17 +132,17 @@ static inline u32 msg_type(struct tipc_msg *m)
 
 static inline u32 msg_named(struct tipc_msg *m)
 {
-	return (msg_type(m) == TIPC_NAMED_MSG);
+	return msg_type(m) == TIPC_NAMED_MSG;
 }
 
 static inline u32 msg_mcast(struct tipc_msg *m)
 {
-	return (msg_type(m) == TIPC_MCAST_MSG);
+	return msg_type(m) == TIPC_MCAST_MSG;
 }
 
 static inline u32 msg_connected(struct tipc_msg *m)
 {
-	return (msg_type(m) == TIPC_CONN_MSG);
+	return msg_type(m) == TIPC_CONN_MSG;
 }
 
 static inline u32 msg_errcode(struct tipc_msg *m)
diff --git a/net/802/fc.c b/net/802/fc.c
index 34cf1ee..1e49f2d 100644
--- a/net/802/fc.c
+++ b/net/802/fc.c
@@ -70,7 +70,7 @@ static int fc_header(struct sk_buff *skb, struct net_device *dev,
 	if(daddr)
 	{
 		memcpy(fch->daddr,daddr,dev->addr_len);
-		return(hdr_len);
+		return hdr_len;
 	}
 	return -hdr_len;
 }
diff --git a/net/802/fddi.c b/net/802/fddi.c
index 3ef0ab0..94b3ad0 100644
--- a/net/802/fddi.c
+++ b/net/802/fddi.c
@@ -82,10 +82,10 @@ static int fddi_header(struct sk_buff *skb, struct net_device *dev,
 	if (daddr != NULL)
 	{
 		memcpy(fddi->daddr, daddr, dev->addr_len);
-		return(hl);
+		return hl;
 	}
 
-	return(-hl);
+	return -hl;
 }
 
 
@@ -108,7 +108,7 @@ static int fddi_rebuild_header(struct sk_buff	*skb)
 	{
 		printk("%s: Don't know how to resolve type %04X addresses.\n",
 		       skb->dev->name, ntohs(fddi->hdr.llc_snap.ethertype));
-		return(0);
+		return 0;
 	}
 }
 
@@ -162,7 +162,7 @@ __be16 fddi_type_trans(struct sk_buff *skb, struct net_device *dev)
 
 	/* Assume 802.2 SNAP frames, for now */
 
-	return(type);
+	return type;
 }
 
 EXPORT_SYMBOL(fddi_type_trans);
@@ -170,9 +170,9 @@ EXPORT_SYMBOL(fddi_type_trans);
 int fddi_change_mtu(struct net_device *dev, int new_mtu)
 {
 	if ((new_mtu < FDDI_K_SNAP_HLEN) || (new_mtu > FDDI_K_SNAP_DLEN))
-		return(-EINVAL);
+		return -EINVAL;
 	dev->mtu = new_mtu;
-	return(0);
+	return 0;
 }
 EXPORT_SYMBOL(fddi_change_mtu);
 
diff --git a/net/802/hippi.c b/net/802/hippi.c
index cd3e8e9..91aca87 100644
--- a/net/802/hippi.c
+++ b/net/802/hippi.c
@@ -152,7 +152,7 @@ int hippi_change_mtu(struct net_device *dev, int new_mtu)
 	if ((new_mtu < 68) || (new_mtu > 65280))
 		return -EINVAL;
 	dev->mtu = new_mtu;
-	return(0);
+	return 0;
 }
 EXPORT_SYMBOL(hippi_change_mtu);
 
diff --git a/net/802/tr.c b/net/802/tr.c
index 1c6e596..5e20cf8 100644
--- a/net/802/tr.c
+++ b/net/802/tr.c
@@ -145,7 +145,7 @@ static int tr_header(struct sk_buff *skb, struct net_device *dev,
 	{
 		memcpy(trh->daddr,daddr,dev->addr_len);
 		tr_source_route(skb, trh, dev);
-		return(hdr_len);
+		return hdr_len;
 	}
 
 	return -hdr_len;
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 889f4ac..0eb486d 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -27,7 +27,7 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 	else if (vlan_id)
 		goto drop;
 
-	return (polling ? netif_receive_skb(skb) : netif_rx(skb));
+	return polling ? netif_receive_skb(skb) : netif_rx(skb);
 
 drop:
 	dev_kfree_skb_any(skb);
diff --git a/net/9p/client.c b/net/9p/client.c
index dc6f2f2..f34b9f5 100644
--- a/net/9p/client.c
+++ b/net/9p/client.c
@@ -61,13 +61,13 @@ static const match_table_t tokens = {
 
 inline int p9_is_proto_dotl(struct p9_client *clnt)
 {
-	return (clnt->proto_version == p9_proto_2000L);
+	return clnt->proto_version == p9_proto_2000L;
 }
 EXPORT_SYMBOL(p9_is_proto_dotl);
 
 inline int p9_is_proto_dotu(struct p9_client *clnt)
 {
-	return (clnt->proto_version == p9_proto_2000u);
+	return clnt->proto_version == p9_proto_2000u;
 }
 EXPORT_SYMBOL(p9_is_proto_dotu);
 
diff --git a/net/bluetooth/rfcomm/core.c b/net/bluetooth/rfcomm/core.c
index 7dca91b..15ea84b 100644
--- a/net/bluetooth/rfcomm/core.c
+++ b/net/bluetooth/rfcomm/core.c
@@ -179,13 +179,13 @@ static unsigned char rfcomm_crc_table[256] = {
 /* FCS on 2 bytes */
 static inline u8 __fcs(u8 *data)
 {
-	return (0xff - __crc(data));
+	return 0xff - __crc(data);
 }
 
 /* FCS on 3 bytes */
 static inline u8 __fcs2(u8 *data)
 {
-	return (0xff - rfcomm_crc_table[__crc(data) ^ data[2]]);
+	return 0xff - rfcomm_crc_table[__crc(data) ^ data[2]];
 }
 
 /* Check FCS */
diff --git a/net/core/flow.c b/net/core/flow.c
index b143b86..127c8a7 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -176,8 +176,8 @@ static u32 flow_hash_code(struct flow_cache *fc,
 {
 	u32 *k = (u32 *) key;
 
-	return (jhash2(k, (sizeof(*key) / sizeof(u32)), fcp->hash_rnd)
-		& (flow_cache_hash_size(fc) - 1));
+	return jhash2(k, (sizeof(*key) / sizeof(u32)), fcp->hash_rnd)
+		& (flow_cache_hash_size(fc) - 1);
 }
 
 typedef unsigned long flow_compare_t;
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index a4e0a74..96b1a74 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -122,7 +122,7 @@ static void neigh_cleanup_and_release(struct neighbour *neigh)
 
 unsigned long neigh_rand_reach_time(unsigned long base)
 {
-	return (base ? (net_random() % base) + (base >> 1) : 0);
+	return base ? (net_random() % base) + (base >> 1) : 0;
 }
 EXPORT_SYMBOL(neigh_rand_reach_time);
 
@@ -766,9 +766,9 @@ next_elt:
 static __inline__ int neigh_max_probes(struct neighbour *n)
 {
 	struct neigh_parms *p = n->parms;
-	return (n->nud_state & NUD_PROBE ?
+	return (n->nud_state & NUD_PROBE) ?
 		p->ucast_probes :
-		p->ucast_probes + p->app_probes + p->mcast_probes);
+		p->ucast_probes + p->app_probes + p->mcast_probes;
 }
 
 static void neigh_invalidate(struct neighbour *neigh)
diff --git a/net/core/utils.c b/net/core/utils.c
index ec6bb32..5fea0ab 100644
--- a/net/core/utils.c
+++ b/net/core/utils.c
@@ -75,7 +75,7 @@ __be32 in_aton(const char *str)
 				str++;
 		}
 	}
-	return(htonl(l));
+	return htonl(l);
 }
 EXPORT_SYMBOL(in_aton);
 
diff --git a/net/dccp/ccids/lib/loss_interval.c b/net/dccp/ccids/lib/loss_interval.c
index 8fc3cbf..497723c 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -116,7 +116,7 @@ u8 tfrc_lh_update_i_mean(struct tfrc_loss_hist *lh, struct sk_buff *skb)
 	cur->li_length = len;
 	tfrc_lh_calc_i_mean(lh);
 
-	return (lh->i_mean < old_i_mean);
+	return lh->i_mean < old_i_mean;
 }
 
 /* Determine if `new_loss' does begin a new loss interval [RFC 4342, 10.2] */
diff --git a/net/econet/af_econet.c b/net/econet/af_econet.c
index baa98fb..f8c1ae4 100644
--- a/net/econet/af_econet.c
+++ b/net/econet/af_econet.c
@@ -392,7 +392,7 @@ static int econet_sendmsg(struct kiocb *iocb, struct socket *sock,
 		dev_queue_xmit(skb);
 		dev_put(dev);
 		mutex_unlock(&econet_mutex);
-		return(len);
+		return len;
 
 	out_free:
 		kfree_skb(skb);
@@ -637,7 +637,7 @@ static int econet_create(struct net *net, struct socket *sock, int protocol,
 	eo->num = protocol;
 
 	econet_insert_socket(&econet_sklist, sk);
-	return(0);
+	return 0;
 out:
 	return err;
 }
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 85e7b45..f00ef2f 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -387,6 +387,6 @@ ssize_t sysfs_format_mac(char *buf, const unsigned char *addr, int len)
 
 	l = _format_mac_addr(buf, PAGE_SIZE, addr, len);
 	l += scnprintf(buf + l, PAGE_SIZE - l, "\n");
-	return ((ssize_t) l);
+	return (ssize_t)l;
 }
 EXPORT_SYMBOL(sysfs_format_mac);
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index dcfe7e9..4083c18 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -567,7 +567,7 @@ static inline int arp_fwd_proxy(struct in_device *in_dev,
 	if (out_dev)
 		omi = IN_DEV_MEDIUM_ID(out_dev);
 
-	return (omi != imi && omi != -1);
+	return omi != imi && omi != -1;
 }
 
 /*
diff --git a/net/ipv4/datagram.c b/net/ipv4/datagram.c
index 721a8a3..174be6c 100644
--- a/net/ipv4/datagram.c
+++ b/net/ipv4/datagram.c
@@ -73,6 +73,6 @@ int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	inet->inet_id = jiffies;
 
 	sk_dst_set(sk, &rt->dst);
-	return(0);
+	return 0;
 }
 EXPORT_SYMBOL(ip4_datagram_connect);
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index e5fa2dd..ba80426 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -425,7 +425,7 @@ static int inet_diag_bc_run(const void *bc, int len,
 			bc += op->no;
 		}
 	}
-	return (len == 0);
+	return len == 0;
 }
 
 static int valid_cc(const void *bc, int len, int cc)
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index f4dc879..1684408 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -116,11 +116,11 @@ static int ip4_frag_match(struct inet_frag_queue *q, void *a)
 	struct ip4_create_arg *arg = a;
 
 	qp = container_of(q, struct ipq, q);
-	return (qp->id == arg->iph->id &&
+	return	qp->id == arg->iph->id &&
 			qp->saddr == arg->iph->saddr &&
 			qp->daddr == arg->iph->daddr &&
 			qp->protocol == arg->iph->protocol &&
-			qp->user == arg->user);
+			qp->user == arg->user;
 }
 
 /* Memory Tracking Functions. */
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 714b6a8..0967d02 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -659,7 +659,7 @@ drop:
 	rcu_read_unlock();
 drop_nolock:
 	kfree_skb(skb);
-	return(0);
+	return 0;
 }
 
 static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index e8f4f9a..8b642f1 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -72,7 +72,7 @@ static inline int arp_devaddr_compare(const struct arpt_devaddr_info *ap,
 	for (i = 0; i < len; i++)
 		ret |= (hdr_addr[i] ^ ap->addr[i]) & ap->mask[i];
 
-	return (ret != 0);
+	return ret != 0;
 }
 
 /*
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index e24d48d..ae1d4a4 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2791,7 +2791,7 @@ static int ipv4_dst_blackhole(struct net *net, struct rtable **rp, struct flowi
 
 	dst_release(&(*rp)->dst);
 	*rp = rt;
-	return (rt ? 0 : -ENOMEM);
+	return rt ? 0 : -ENOMEM;
 }
 
 int ip_route_output_flow(struct net *net, struct rtable **rp, struct flowi *flp,
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 1bc87a0..51966b3 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2301,7 +2301,7 @@ static inline int tcp_dupack_heuristics(struct tcp_sock *tp)
 
 static inline int tcp_skb_timedout(struct sock *sk, struct sk_buff *skb)
 {
-	return (tcp_time_stamp - TCP_SKB_CB(skb)->when > inet_csk(sk)->icsk_rto);
+	return tcp_time_stamp - TCP_SKB_CB(skb)->when > inet_csk(sk)->icsk_rto;
 }
 
 static inline int tcp_head_timedout(struct sock *sk)
@@ -3398,8 +3398,8 @@ static void tcp_ack_probe(struct sock *sk)
 
 static inline int tcp_ack_is_dubious(const struct sock *sk, const int flag)
 {
-	return (!(flag & FLAG_NOT_DUP) || (flag & FLAG_CA_ALERT) ||
-		inet_csk(sk)->icsk_ca_state != TCP_CA_Open);
+	return !(flag & FLAG_NOT_DUP) || (flag & FLAG_CA_ALERT) ||
+		inet_csk(sk)->icsk_ca_state != TCP_CA_Open;
 }
 
 static inline int tcp_may_raise_cwnd(const struct sock *sk, const int flag)
@@ -3416,9 +3416,9 @@ static inline int tcp_may_update_window(const struct tcp_sock *tp,
 					const u32 ack, const u32 ack_seq,
 					const u32 nwin)
 {
-	return (after(ack, tp->snd_una) ||
+	return	after(ack, tp->snd_una) ||
 		after(ack_seq, tp->snd_wl1) ||
-		(ack_seq == tp->snd_wl1 && nwin > tp->snd_wnd));
+		(ack_seq == tp->snd_wl1 && nwin > tp->snd_wnd);
 }
 
 /* Update our send window.
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index f25b56c..43cf901 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -55,7 +55,7 @@ static __inline__ int tcp_in_window(u32 seq, u32 end_seq, u32 s_win, u32 e_win)
 		return 1;
 	if (after(end_seq, s_win) && before(seq, e_win))
 		return 1;
-	return (seq == e_win && seq == end_seq);
+	return seq == e_win && seq == end_seq;
 }
 
 /*
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index ea09d2f..05b1ecf 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1370,9 +1370,9 @@ static inline int tcp_nagle_check(const struct tcp_sock *tp,
 				  const struct sk_buff *skb,
 				  unsigned mss_now, int nonagle)
 {
-	return (skb->len < mss_now &&
+	return skb->len < mss_now &&
 		((nonagle & TCP_NAGLE_CORK) ||
-		 (!nonagle && tp->packets_out && tcp_minshall_check(tp))));
+		 (!nonagle && tp->packets_out && tcp_minshall_check(tp)));
 }
 
 /* Return non-zero if the Nagle test allows this packet to be
@@ -1443,10 +1443,10 @@ int tcp_may_send_now(struct sock *sk)
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb = tcp_send_head(sk);
 
-	return (skb &&
+	return skb &&
 		tcp_snd_test(sk, skb, tcp_current_mss(sk),
 			     (tcp_skb_is_last(sk, skb) ?
-			      tp->nonagle : TCP_NAGLE_PUSH)));
+			      tp->nonagle : TCP_NAGLE_PUSH));
 }
 
 /* Trim TSO SKB to LEN bytes, put the remaining data into a new packet
diff --git a/net/ipv4/tcp_westwood.c b/net/ipv4/tcp_westwood.c
index 20151d6..a534dda 100644
--- a/net/ipv4/tcp_westwood.c
+++ b/net/ipv4/tcp_westwood.c
@@ -80,7 +80,7 @@ static void tcp_westwood_init(struct sock *sk)
  */
 static inline u32 westwood_do_filter(u32 a, u32 b)
 {
-	return (((7 * a) + b) >> 3);
+	return ((7 * a) + b) >> 3;
 }
 
 static void westwood_filter(struct westwood *w, u32 delta)
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 5bc893e..89aa543 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -243,7 +243,7 @@ static inline bool addrconf_qdisc_ok(const struct net_device *dev)
 /* Check if a route is valid prefix route */
 static inline int addrconf_is_prefix_route(const struct rt6_info *rt)
 {
-	return ((rt->rt6i_flags & (RTF_GATEWAY | RTF_DEFAULT)) == 0);
+	return (rt->rt6i_flags & (RTF_GATEWAY | RTF_DEFAULT)) == 0;
 }
 
 static void addrconf_del_timer(struct inet6_ifaddr *ifp)
diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index f0e774c..921dcf6 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -513,10 +513,9 @@ static int ip6addrlbl_dump(struct sk_buff *skb, struct netlink_callback *cb)
 
 static inline int ip6addrlbl_msgsize(void)
 {
-	return (NLMSG_ALIGN(sizeof(struct ifaddrlblmsg))
+	return NLMSG_ALIGN(sizeof(struct ifaddrlblmsg))
 		+ nla_total_size(16)	/* IFAL_ADDRESS */
-		+ nla_total_size(4)	/* IFAL_LABEL */
-	);
+		+ nla_total_size(4);	/* IFAL_LABEL */
 }
 
 static int ip6addrlbl_get(struct sk_buff *in_skb, struct nlmsghdr* nlh,
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 56b9bf2..6022098 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -467,7 +467,7 @@ int inet6_getname(struct socket *sock, struct sockaddr *uaddr,
 	if (ipv6_addr_type(&sin->sin6_addr) & IPV6_ADDR_LINKLOCAL)
 		sin->sin6_scope_id = sk->sk_bound_dev_if;
 	*uaddr_len = sizeof(*sin);
-	return(0);
+	return 0;
 }
 
 EXPORT_SYMBOL(inet6_getname);
@@ -488,7 +488,7 @@ int inet6_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 	case SIOCADDRT:
 	case SIOCDELRT:
 
-		return(ipv6_route_ioctl(net, cmd, (void __user *)arg));
+		return ipv6_route_ioctl(net, cmd, (void __user *)arg);
 
 	case SIOCSIFADDR:
 		return addrconf_add_ifaddr(net, (void __user *) arg);
@@ -502,7 +502,7 @@ int inet6_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 		return sk->sk_prot->ioctl(sk, cmd, arg);
 	}
 	/*NOTREACHED*/
-	return(0);
+	return 0;
 }
 
 EXPORT_SYMBOL(inet6_ioctl);
diff --git a/net/ipv6/exthdrs_core.c b/net/ipv6/exthdrs_core.c
index e1caa5d..14ed0a9 100644
--- a/net/ipv6/exthdrs_core.c
+++ b/net/ipv6/exthdrs_core.c
@@ -13,12 +13,12 @@ int ipv6_ext_hdr(u8 nexthdr)
 	/*
 	 * find out if nexthdr is an extension header or a protocol
 	 */
-	return ( (nexthdr == NEXTHDR_HOP)	||
+	return   (nexthdr == NEXTHDR_HOP)	||
 		 (nexthdr == NEXTHDR_ROUTING)	||
 		 (nexthdr == NEXTHDR_FRAGMENT)	||
 		 (nexthdr == NEXTHDR_AUTH)	||
 		 (nexthdr == NEXTHDR_NONE)	||
-		 (nexthdr == NEXTHDR_DEST) );
+		 (nexthdr == NEXTHDR_DEST);
 }
 
 /*
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 1838927..efbbbce 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -870,8 +870,8 @@ static inline int ip6_rt_check(struct rt6key *rt_key,
 			       struct in6_addr *fl_addr,
 			       struct in6_addr *addr_cache)
 {
-	return ((rt_key->plen != 128 || !ipv6_addr_equal(fl_addr, &rt_key->addr)) &&
-		(addr_cache == NULL || !ipv6_addr_equal(fl_addr, addr_cache)));
+	return (rt_key->plen != 128 || !ipv6_addr_equal(fl_addr, &rt_key->addr)) &&
+		(addr_cache == NULL || !ipv6_addr_equal(fl_addr, addr_cache));
 }
 
 static struct dst_entry *ip6_sk_dst_check(struct sock *sk,
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 69a0051..b3dd844 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -228,12 +228,12 @@ static struct nd_opt_hdr *ndisc_next_option(struct nd_opt_hdr *cur,
 	do {
 		cur = ((void *)cur) + (cur->nd_opt_len << 3);
 	} while(cur < end && cur->nd_opt_type != type);
-	return (cur <= end && cur->nd_opt_type == type ? cur : NULL);
+	return cur <= end && cur->nd_opt_type == type ? cur : NULL;
 }
 
 static inline int ndisc_is_useropt(struct nd_opt_hdr *opt)
 {
-	return (opt->nd_opt_type == ND_OPT_RDNSS);
+	return opt->nd_opt_type == ND_OPT_RDNSS;
 }
 
 static struct nd_opt_hdr *ndisc_next_useropt(struct nd_opt_hdr *cur,
@@ -244,7 +244,7 @@ static struct nd_opt_hdr *ndisc_next_useropt(struct nd_opt_hdr *cur,
 	do {
 		cur = ((void *)cur) + (cur->nd_opt_len << 3);
 	} while(cur < end && !ndisc_is_useropt(cur));
-	return (cur <= end && ndisc_is_useropt(cur) ? cur : NULL);
+	return cur <= end && ndisc_is_useropt(cur) ? cur : NULL;
 }
 
 static struct ndisc_options *ndisc_parse_options(u8 *opt, int opt_len,
@@ -319,7 +319,7 @@ static inline u8 *ndisc_opt_addr_data(struct nd_opt_hdr *p,
 	int prepad = ndisc_addr_option_pad(dev->type);
 	if (lladdrlen != NDISC_OPT_SPACE(dev->addr_len + prepad))
 		return NULL;
-	return (lladdr + prepad);
+	return lladdr + prepad;
 }
 
 int ndisc_mc_map(struct in6_addr *addr, char *buf, struct net_device *dev, int dir)
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 8e754be..6b331e9 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -82,13 +82,13 @@ EXPORT_SYMBOL_GPL(ip6t_alloc_initial_table);
 int
 ip6t_ext_hdr(u8 nexthdr)
 {
-	return ( (nexthdr == IPPROTO_HOPOPTS)   ||
-		 (nexthdr == IPPROTO_ROUTING)   ||
-		 (nexthdr == IPPROTO_FRAGMENT)  ||
-		 (nexthdr == IPPROTO_ESP)       ||
-		 (nexthdr == IPPROTO_AH)        ||
-		 (nexthdr == IPPROTO_NONE)      ||
-		 (nexthdr == IPPROTO_DSTOPTS) );
+	return  (nexthdr == IPPROTO_HOPOPTS)   ||
+		(nexthdr == IPPROTO_ROUTING)   ||
+		(nexthdr == IPPROTO_FRAGMENT)  ||
+		(nexthdr == IPPROTO_ESP)       ||
+		(nexthdr == IPPROTO_AH)        ||
+		(nexthdr == IPPROTO_NONE)      ||
+		(nexthdr == IPPROTO_DSTOPTS);
 }
 
 /* Returns whether matches rule or not. */
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index e677937..45e6efb 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -764,7 +764,7 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 			return -EINVAL;
 
 		if (sin6->sin6_family && sin6->sin6_family != AF_INET6)
-			return(-EAFNOSUPPORT);
+			return -EAFNOSUPPORT;
 
 		/* port is the proto value [0..255] carried in nexthdr */
 		proto = ntohs(sin6->sin6_port);
@@ -772,10 +772,10 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 		if (!proto)
 			proto = inet->inet_num;
 		else if (proto != inet->inet_num)
-			return(-EINVAL);
+			return -EINVAL;
 
 		if (proto > 255)
-			return(-EINVAL);
+			return -EINVAL;
 
 		daddr = &sin6->sin6_addr;
 		if (np->sndflow) {
@@ -985,7 +985,7 @@ static int do_rawv6_setsockopt(struct sock *sk, int level, int optname,
 			/* You may get strange result with a positive odd offset;
 			   RFC2292bis agrees with me. */
 			if (val > 0 && (val&1))
-				return(-EINVAL);
+				return -EINVAL;
 			if (val < 0) {
 				rp->checksum = 0;
 			} else {
@@ -997,7 +997,7 @@ static int do_rawv6_setsockopt(struct sock *sk, int level, int optname,
 			break;
 
 		default:
-			return(-ENOPROTOOPT);
+			return -ENOPROTOOPT;
 	}
 }
 
@@ -1190,7 +1190,7 @@ static int rawv6_init_sk(struct sock *sk)
 	default:
 		break;
 	}
-	return(0);
+	return 0;
 }
 
 struct proto rawv6_prot = {
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index d126365..25b0bed 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -217,14 +217,14 @@ static void ip6_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 
 static __inline__ int rt6_check_expired(const struct rt6_info *rt)
 {
-	return (rt->rt6i_flags & RTF_EXPIRES &&
-		time_after(jiffies, rt->rt6i_expires));
+	return (rt->rt6i_flags & RTF_EXPIRES) &&
+		time_after(jiffies, rt->rt6i_expires);
 }
 
 static inline int rt6_need_strict(struct in6_addr *daddr)
 {
-	return (ipv6_addr_type(daddr) &
-		(IPV6_ADDR_MULTICAST | IPV6_ADDR_LINKLOCAL | IPV6_ADDR_LOOPBACK));
+	return ipv6_addr_type(daddr) &
+		(IPV6_ADDR_MULTICAST | IPV6_ADDR_LINKLOCAL | IPV6_ADDR_LOOPBACK);
 }
 
 /*
@@ -440,7 +440,7 @@ static struct rt6_info *rt6_select(struct fib6_node *fn, int oif, int strict)
 		  __func__, match);
 
 	net = dev_net(rt0->rt6i_dev);
-	return (match ? match : net->ipv6.ip6_null_entry);
+	return match ? match : net->ipv6.ip6_null_entry;
 }
 
 #ifdef CONFIG_IPV6_ROUTE_INFO
@@ -859,7 +859,7 @@ int ip6_dst_blackhole(struct sock *sk, struct dst_entry **dstp, struct flowi *fl
 
 	dst_release(*dstp);
 	*dstp = new;
-	return (new ? 0 : -ENOMEM);
+	return new ? 0 : -ENOMEM;
 }
 EXPORT_SYMBOL_GPL(ip6_dst_blackhole);
 
@@ -1070,7 +1070,7 @@ static int ip6_dst_gc(struct dst_ops *ops)
 		net->ipv6.ip6_rt_gc_expire = rt_gc_timeout>>1;
 out:
 	net->ipv6.ip6_rt_gc_expire -= net->ipv6.ip6_rt_gc_expire>>rt_elasticity;
-	return (atomic_read(&ops->entries) > rt_max_size);
+	return atomic_read(&ops->entries) > rt_max_size;
 }
 
 /* Clean host part of a prefix. Not necessary in radix tree,
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index fe6d404..8d93f6d 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -139,7 +139,7 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 		return -EINVAL;
 
 	if (usin->sin6_family != AF_INET6)
-		return(-EAFNOSUPPORT);
+		return -EAFNOSUPPORT;
 
 	memset(&fl, 0, sizeof(fl));
 
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 6baeabb..39676ea 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -199,7 +199,7 @@ static inline int xfrm6_garbage_collect(struct dst_ops *ops)
 	struct net *net = container_of(ops, struct net, xfrm.xfrm6_dst_ops);
 
 	xfrm6_policy_afinfo.garbage_collect(net);
-	return (atomic_read(&ops->entries) > ops->gc_thresh * 2);
+	return atomic_read(&ops->entries) > ops->gc_thresh * 2;
 }
 
 static void xfrm6_update_pmtu(struct dst_entry *dst, u32 mtu)
diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index fd55b51..bf36351 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -573,9 +573,9 @@ static int irda_find_lsap_sel(struct irda_sock *self, char *name)
 		/* Requested object/attribute doesn't exist */
 		if((self->errno == IAS_CLASS_UNKNOWN) ||
 		   (self->errno == IAS_ATTRIB_UNKNOWN))
-			return (-EADDRNOTAVAIL);
+			return -EADDRNOTAVAIL;
 		else
-			return (-EHOSTUNREACH);
+			return -EHOSTUNREACH;
 	}
 
 	/* Get the remote TSAP selector */
@@ -663,7 +663,7 @@ static int irda_discover_daddr_and_lsap_sel(struct irda_sock *self, char *name)
 					   __func__, name);
 				self->daddr = DEV_ADDR_ANY;
 				kfree(discoveries);
-				return(-ENOTUNIQ);
+				return -ENOTUNIQ;
 			}
 			/* First time we found that one, save it ! */
 			daddr = self->daddr;
@@ -677,7 +677,7 @@ static int irda_discover_daddr_and_lsap_sel(struct irda_sock *self, char *name)
 			IRDA_DEBUG(0, "%s(), unexpected IAS query failure\n", __func__);
 			self->daddr = DEV_ADDR_ANY;
 			kfree(discoveries);
-			return(-EHOSTUNREACH);
+			return -EHOSTUNREACH;
 			break;
 		}
 	}
@@ -689,7 +689,7 @@ static int irda_discover_daddr_and_lsap_sel(struct irda_sock *self, char *name)
 		IRDA_DEBUG(1, "%s(), cannot discover service ''%s'' in any device !!!\n",
 			   __func__, name);
 		self->daddr = DEV_ADDR_ANY;
-		return(-EADDRNOTAVAIL);
+		return -EADDRNOTAVAIL;
 	}
 
 	/* Revert back to discovered device & service */
@@ -2465,9 +2465,9 @@ bed:
 			/* Requested object/attribute doesn't exist */
 			if((self->errno == IAS_CLASS_UNKNOWN) ||
 			   (self->errno == IAS_ATTRIB_UNKNOWN))
-				return (-EADDRNOTAVAIL);
+				return -EADDRNOTAVAIL;
 			else
-				return (-EHOSTUNREACH);
+				return -EHOSTUNREACH;
 		}
 
 		/* Translate from internal to user structure */
diff --git a/net/irda/discovery.c b/net/irda/discovery.c
index c1c8ae9..36c3f03 100644
--- a/net/irda/discovery.c
+++ b/net/irda/discovery.c
@@ -315,7 +315,7 @@ struct irda_device_info *irlmp_copy_discoveries(hashbin_t *log, int *pn,
 
 	/* Get the actual number of device in the buffer and return */
 	*pn = i;
-	return(buffer);
+	return buffer;
 }
 
 #ifdef CONFIG_PROC_FS
diff --git a/net/irda/ircomm/ircomm_tty.c b/net/irda/ircomm/ircomm_tty.c
index faa82ca..a39cca8 100644
--- a/net/irda/ircomm/ircomm_tty.c
+++ b/net/irda/ircomm/ircomm_tty.c
@@ -449,8 +449,8 @@ static int ircomm_tty_open(struct tty_struct *tty, struct file *filp)
 		}
 
 #ifdef SERIAL_DO_RESTART
-		return ((self->flags & ASYNC_HUP_NOTIFY) ?
-			-EAGAIN : -ERESTARTSYS);
+		return (self->flags & ASYNC_HUP_NOTIFY) ?
+			-EAGAIN : -ERESTARTSYS;
 #else
 		return -EAGAIN;
 #endif
diff --git a/net/irda/irlmp.c b/net/irda/irlmp.c
index 0e7d8bd..6115a44 100644
--- a/net/irda/irlmp.c
+++ b/net/irda/irlmp.c
@@ -939,7 +939,7 @@ struct irda_device_info *irlmp_get_discoveries(int *pn, __u16 mask, int nslots)
 	}
 
 	/* Return current cached discovery log */
-	return(irlmp_copy_discoveries(irlmp->cachelog, pn, mask, TRUE));
+	return irlmp_copy_discoveries(irlmp->cachelog, pn, mask, TRUE);
 }
 EXPORT_SYMBOL(irlmp_get_discoveries);
 
diff --git a/net/irda/irlmp_frame.c b/net/irda/irlmp_frame.c
index 3750884..062e63b 100644
--- a/net/irda/irlmp_frame.c
+++ b/net/irda/irlmp_frame.c
@@ -448,7 +448,7 @@ static struct lsap_cb *irlmp_find_lsap(struct lap_cb *self, __u8 dlsap_sel,
 	    (self->cache.slsap_sel == slsap_sel) &&
 	    (self->cache.dlsap_sel == dlsap_sel))
 	{
-		return (self->cache.lsap);
+		return self->cache.lsap;
 	}
 #endif
 
diff --git a/net/irda/irnet/irnet_irda.c b/net/irda/irnet/irnet_irda.c
index e98e40d..7f17a80 100644
--- a/net/irda/irnet/irnet_irda.c
+++ b/net/irda/irnet/irnet_irda.c
@@ -238,7 +238,7 @@ irnet_ias_to_tsap(irnet_socket *	self,
   DEXIT(IRDA_SR_TRACE, "\n");
 
   /* Return the TSAP */
-  return(dtsap_sel);
+  return dtsap_sel;
 }
 
 /*------------------------------------------------------------------*/
@@ -301,7 +301,7 @@ irnet_connect_tsap(irnet_socket *	self)
     {
       clear_bit(0, &self->ttp_connect);
       DERROR(IRDA_SR_ERROR, "connect aborted!\n");
-      return(err);
+      return err;
     }
 
   /* Connect to remote device */
@@ -312,7 +312,7 @@ irnet_connect_tsap(irnet_socket *	self)
     {
       clear_bit(0, &self->ttp_connect);
       DERROR(IRDA_SR_ERROR, "connect aborted!\n");
-      return(err);
+      return err;
     }
 
   /* The above call is non-blocking.
@@ -321,7 +321,7 @@ irnet_connect_tsap(irnet_socket *	self)
    * See you there ;-) */
 
   DEXIT(IRDA_SR_TRACE, "\n");
-  return(err);
+  return err;
 }
 
 /*------------------------------------------------------------------*/
@@ -362,10 +362,10 @@ irnet_discover_next_daddr(irnet_socket *	self)
       /* The above request is non-blocking.
        * After a while, IrDA will call us back in irnet_discovervalue_confirm()
        * We will then call irnet_ias_to_tsap() and come back here again... */
-      return(0);
+      return 0;
     }
   else
-    return(1);
+    return 1;
 }
 
 /*------------------------------------------------------------------*/
@@ -436,7 +436,7 @@ irnet_discover_daddr_and_lsap_sel(irnet_socket *	self)
   /* Follow me in irnet_discovervalue_confirm() */
 
   DEXIT(IRDA_SR_TRACE, "\n");
-  return(0);
+  return 0;
 }
 
 /*------------------------------------------------------------------*/
@@ -485,7 +485,7 @@ irnet_dname_to_daddr(irnet_socket *	self)
   /* No luck ! */
   DEBUG(IRDA_SR_INFO, "cannot discover device ``%s'' !!!\n", self->rname);
   kfree(discoveries);
-  return(-EADDRNOTAVAIL);
+  return -EADDRNOTAVAIL;
 }
 
 
@@ -527,7 +527,7 @@ irda_irnet_create(irnet_socket *	self)
   INIT_WORK(&self->disconnect_work, irnet_ppp_disconnect);
 
   DEXIT(IRDA_SOCK_TRACE, "\n");
-  return(0);
+  return 0;
 }
 
 /*------------------------------------------------------------------*/
@@ -601,7 +601,7 @@ irda_irnet_connect(irnet_socket *	self)
    * We will finish the connection procedure in irnet_connect_tsap().
    */
   DEXIT(IRDA_SOCK_TRACE, "\n");
-  return(0);
+  return 0;
 }
 
 /*------------------------------------------------------------------*/
@@ -733,7 +733,7 @@ irnet_daddr_to_dname(irnet_socket *	self)
   /* No luck ! */
   DEXIT(IRDA_SERV_INFO, ": cannot discover device 0x%08x !!!\n", self->daddr);
   kfree(discoveries);
-  return(-EADDRNOTAVAIL);
+  return -EADDRNOTAVAIL;
 }
 
 /*------------------------------------------------------------------*/
diff --git a/net/irda/irnet/irnet_ppp.c b/net/irda/irnet/irnet_ppp.c
index dfe7b38..69f1fa6 100644
--- a/net/irda/irnet/irnet_ppp.c
+++ b/net/irda/irnet/irnet_ppp.c
@@ -166,7 +166,7 @@ irnet_ctrl_write(irnet_socket *	ap,
     }
 
   /* Success : we have parsed all commands successfully */
-  return(count);
+  return count;
 }
 
 #ifdef INITIAL_DISCOVERY
@@ -300,7 +300,7 @@ irnet_ctrl_read(irnet_socket *	ap,
 	}
 
       DEXIT(CTRL_TRACE, "\n");
-      return(strlen(event));
+      return strlen(event);
     }
 #endif /* INITIAL_DISCOVERY */
 
@@ -409,7 +409,7 @@ irnet_ctrl_read(irnet_socket *	ap,
     }
 
   DEXIT(CTRL_TRACE, "\n");
-  return(strlen(event));
+  return strlen(event);
 }
 
 /*------------------------------------------------------------------*/
@@ -623,7 +623,7 @@ dev_irnet_poll(struct file *	file,
     mask |= irnet_ctrl_poll(ap, file, wait);
 
   DEXIT(FS_TRACE, " - mask=0x%X\n", mask);
-  return(mask);
+  return mask;
 }
 
 /*------------------------------------------------------------------*/
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 43040e9..d87c22d 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -565,12 +565,12 @@ pfkey_proto2satype(uint16_t proto)
 
 static uint8_t pfkey_proto_to_xfrm(uint8_t proto)
 {
-	return (proto == IPSEC_PROTO_ANY ? 0 : proto);
+	return proto == IPSEC_PROTO_ANY ? 0 : proto;
 }
 
 static uint8_t pfkey_proto_from_xfrm(uint8_t proto)
 {
-	return (proto ? proto : IPSEC_PROTO_ANY);
+	return proto ? proto : IPSEC_PROTO_ANY;
 }
 
 static inline int pfkey_sockaddr_len(sa_family_t family)
diff --git a/net/mac80211/rate.c b/net/mac80211/rate.c
index 4f772de..b0cc385 100644
--- a/net/mac80211/rate.c
+++ b/net/mac80211/rate.c
@@ -207,7 +207,7 @@ static bool rc_no_data_or_no_ack(struct ieee80211_tx_rate_control *txrc)
 
 	fc = hdr->frame_control;
 
-	return ((info->flags & IEEE80211_TX_CTL_NO_ACK) || !ieee80211_is_data(fc));
+	return (info->flags & IEEE80211_TX_CTL_NO_ACK) || !ieee80211_is_data(fc);
 }
 
 static void rc_send_low_broadcast(s8 *idx, u32 basic_rates, u8 max_rate_idx)
diff --git a/net/rfkill/input.c b/net/rfkill/input.c
index 3713d7e..1bca6d4 100644
--- a/net/rfkill/input.c
+++ b/net/rfkill/input.c
@@ -142,7 +142,7 @@ static unsigned long rfkill_last_scheduled;
 static unsigned long rfkill_ratelimit(const unsigned long last)
 {
 	const unsigned long delay = msecs_to_jiffies(RFKILL_OPS_DELAY);
-	return (time_after(jiffies, last + delay)) ? 0 : delay;
+	return time_after(jiffies, last + delay) ? 0 : delay;
 }
 
 static void rfkill_schedule_ratelimited(void)
diff --git a/net/rose/rose_link.c b/net/rose/rose_link.c
index a750a28..fa5f564 100644
--- a/net/rose/rose_link.c
+++ b/net/rose/rose_link.c
@@ -114,7 +114,7 @@ static int rose_send_frame(struct sk_buff *skb, struct rose_neigh *neigh)
 	if (ax25s)
 		ax25_cb_put(ax25s);
 
-	return (neigh->ax25 != NULL);
+	return neigh->ax25 != NULL;
 }
 
 /*
@@ -137,7 +137,7 @@ static int rose_link_up(struct rose_neigh *neigh)
 	if (ax25s)
 		ax25_cb_put(ax25s);
 
-	return (neigh->ax25 != NULL);
+	return neigh->ax25 != NULL;
 }
 
 /*
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index f774e65..1ef29c7 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -799,7 +799,7 @@ static void sctp_inet_skb_msgname(struct sk_buff *skb, char *msgname, int *len)
 static int sctp_inet_af_supported(sa_family_t family, struct sctp_sock *sp)
 {
 	/* PF_INET only supports AF_INET addresses. */
-	return (AF_INET == family);
+	return AF_INET == family;
 }
 
 /* Address matching with wildcards allowed. */
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 6a691d8..535659f 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3884,7 +3884,7 @@ static int sctp_getsockopt_sctp_status(struct sock *sk, int len,
 	}
 
 out:
-	return (retval);
+	return retval;
 }
 
 
@@ -3940,7 +3940,7 @@ static int sctp_getsockopt_peer_addr_info(struct sock *sk, int len,
 	}
 
 out:
-	return (retval);
+	return retval;
 }
 
 /* 7.1.12 Enable/Disable message fragmentation (SCTP_DISABLE_FRAGMENTS)
@@ -5594,7 +5594,7 @@ static int sctp_get_port(struct sock *sk, unsigned short snum)
 	/* Note: sk->sk_num gets filled in if ephemeral port request. */
 	ret = sctp_get_port_local(sk, &addr);
 
-	return (ret ? 1 : 0);
+	return ret ? 1 : 0;
 }
 
 /*
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index dcfc66b..597c493 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1049,7 +1049,7 @@ gss_match(struct auth_cred *acred, struct rpc_cred *rc, int flags)
 out:
 	if (acred->machine_cred != gss_cred->gc_machine_cred)
 		return 0;
-	return (rc->cr_uid == acred->uid);
+	return rc->cr_uid == acred->uid;
 }
 
 /*
diff --git a/net/sunrpc/auth_gss/gss_generic_token.c b/net/sunrpc/auth_gss/gss_generic_token.c
index 310b78e..c586e92 100644
--- a/net/sunrpc/auth_gss/gss_generic_token.c
+++ b/net/sunrpc/auth_gss/gss_generic_token.c
@@ -76,19 +76,19 @@ static int
 der_length_size( int length)
 {
 	if (length < (1<<7))
-		return(1);
+		return 1;
 	else if (length < (1<<8))
-		return(2);
+		return 2;
 #if (SIZEOF_INT == 2)
 	else
-		return(3);
+		return 3;
 #else
 	else if (length < (1<<16))
-		return(3);
+		return 3;
 	else if (length < (1<<24))
-		return(4);
+		return 4;
 	else
-		return(5);
+		return 5;
 #endif
 }
 
@@ -121,14 +121,14 @@ der_read_length(unsigned char **buf, int *bufsize)
 	int ret;
 
 	if (*bufsize < 1)
-		return(-1);
+		return -1;
 	sf = *(*buf)++;
 	(*bufsize)--;
 	if (sf & 0x80) {
 		if ((sf &= 0x7f) > ((*bufsize)-1))
-			return(-1);
+			return -1;
 		if (sf > SIZEOF_INT)
-			return (-1);
+			return -1;
 		ret = 0;
 		for (; sf; sf--) {
 			ret = (ret<<8) + (*(*buf)++);
@@ -138,7 +138,7 @@ der_read_length(unsigned char **buf, int *bufsize)
 		ret = sf;
 	}
 
-	return(ret);
+	return ret;
 }
 
 /* returns the length of a token, given the mech oid and the body size */
@@ -148,7 +148,7 @@ g_token_size(struct xdr_netobj *mech, unsigned int body_size)
 {
 	/* set body_size to sequence contents size */
 	body_size += 2 + (int) mech->len;         /* NEED overflow check */
-	return(1 + der_length_size(body_size) + body_size);
+	return 1 + der_length_size(body_size) + body_size;
 }
 
 EXPORT_SYMBOL_GPL(g_token_size);
@@ -186,27 +186,27 @@ g_verify_token_header(struct xdr_netobj *mech, int *body_size,
 	int ret = 0;
 
 	if ((toksize-=1) < 0)
-		return(G_BAD_TOK_HEADER);
+		return G_BAD_TOK_HEADER;
 	if (*buf++ != 0x60)
-		return(G_BAD_TOK_HEADER);
+		return G_BAD_TOK_HEADER;
 
 	if ((seqsize = der_read_length(&buf, &toksize)) < 0)
-		return(G_BAD_TOK_HEADER);
+		return G_BAD_TOK_HEADER;
 
 	if (seqsize != toksize)
-		return(G_BAD_TOK_HEADER);
+		return G_BAD_TOK_HEADER;
 
 	if ((toksize-=1) < 0)
-		return(G_BAD_TOK_HEADER);
+		return G_BAD_TOK_HEADER;
 	if (*buf++ != 0x06)
-		return(G_BAD_TOK_HEADER);
+		return G_BAD_TOK_HEADER;
 
 	if ((toksize-=1) < 0)
-		return(G_BAD_TOK_HEADER);
+		return G_BAD_TOK_HEADER;
 	toid.len = *buf++;
 
 	if ((toksize-=toid.len) < 0)
-		return(G_BAD_TOK_HEADER);
+		return G_BAD_TOK_HEADER;
 	toid.data = buf;
 	buf+=toid.len;
 
@@ -217,17 +217,17 @@ g_verify_token_header(struct xdr_netobj *mech, int *body_size,
       to return G_BAD_TOK_HEADER if the token header is in fact bad */
 
 	if ((toksize-=2) < 0)
-		return(G_BAD_TOK_HEADER);
+		return G_BAD_TOK_HEADER;
 
 	if (ret)
-		return(ret);
+		return ret;
 
 	if (!ret) {
 		*buf_in = buf;
 		*body_size = toksize;
 	}
 
-	return(ret);
+	return ret;
 }
 
 EXPORT_SYMBOL_GPL(g_verify_token_header);
diff --git a/net/sunrpc/auth_gss/gss_krb5_seqnum.c b/net/sunrpc/auth_gss/gss_krb5_seqnum.c
index 415c013..62ac90c 100644
--- a/net/sunrpc/auth_gss/gss_krb5_seqnum.c
+++ b/net/sunrpc/auth_gss/gss_krb5_seqnum.c
@@ -162,5 +162,5 @@ krb5_get_seq_num(struct krb5_ctx *kctx,
 	*seqnum = ((plain[0]) |
 		   (plain[1] << 8) | (plain[2] << 16) | (plain[3] << 24));
 
-	return (0);
+	return 0;
 }
diff --git a/net/sunrpc/auth_gss/gss_mech_switch.c b/net/sunrpc/auth_gss/gss_mech_switch.c
index 2689de3..8b40610 100644
--- a/net/sunrpc/auth_gss/gss_mech_switch.c
+++ b/net/sunrpc/auth_gss/gss_mech_switch.c
@@ -331,7 +331,7 @@ gss_delete_sec_context(struct gss_ctx	**context_handle)
 			*context_handle);
 
 	if (!*context_handle)
-		return(GSS_S_NO_CONTEXT);
+		return GSS_S_NO_CONTEXT;
 	if ((*context_handle)->internal_ctx_id)
 		(*context_handle)->mech_type->gm_ops
 			->gss_delete_sec_context((*context_handle)
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index cace604..aa5dbda 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -376,7 +376,7 @@ int rpc_queue_empty(struct rpc_wait_queue *queue)
 	spin_lock_bh(&queue->lock);
 	res = queue->qlen;
 	spin_unlock_bh(&queue->lock);
-	return (res == 0);
+	return res == 0;
 }
 EXPORT_SYMBOL_GPL(rpc_queue_empty);
 
diff --git a/net/tipc/addr.c b/net/tipc/addr.c
index c048543..2ddc351 100644
--- a/net/tipc/addr.c
+++ b/net/tipc/addr.c
@@ -89,7 +89,7 @@ int tipc_addr_domain_valid(u32 addr)
 
 int tipc_addr_node_valid(u32 addr)
 {
-	return (tipc_addr_domain_valid(addr) && tipc_node(addr));
+	return tipc_addr_domain_valid(addr) && tipc_node(addr);
 }
 
 int tipc_in_scope(u32 domain, u32 addr)
diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index b11248c..ecfaac1 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -184,7 +184,7 @@ static void bclink_set_gap(struct tipc_node *n_ptr)
 
 static int bclink_ack_allowed(u32 n)
 {
-	return((n % TIPC_MIN_LINK_WIN) == tipc_own_tag);
+	return (n % TIPC_MIN_LINK_WIN) == tipc_own_tag;
 }
 
 
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 52ae17b..9c10c6b 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -63,7 +63,7 @@ static int media_name_valid(const char *name)
 	len = strlen(name);
 	if ((len + 1) > TIPC_MAX_MEDIA_NAME)
 		return 0;
-	return (strspn(name, tipc_alphabet) == len);
+	return strspn(name, tipc_alphabet) == len;
 }
 
 /**
diff --git a/net/tipc/dbg.c b/net/tipc/dbg.c
index 1885a7e..6569d45 100644
--- a/net/tipc/dbg.c
+++ b/net/tipc/dbg.c
@@ -134,7 +134,7 @@ void tipc_printbuf_reset(struct print_buf *pb)
 
 int tipc_printbuf_empty(struct print_buf *pb)
 {
-	return (!pb->buf || (pb->crs == pb->buf));
+	return !pb->buf || (pb->crs == pb->buf);
 }
 
 /**
@@ -169,7 +169,7 @@ int tipc_printbuf_validate(struct print_buf *pb)
 			tipc_printf(pb, err);
 		}
 	}
-	return (pb->crs - pb->buf + 1);
+	return pb->crs - pb->buf + 1;
 }
 
 /**
diff --git a/net/tipc/link.c b/net/tipc/link.c
index a6a3102..b8cf1e9 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -239,13 +239,13 @@ int tipc_link_is_up(struct link *l_ptr)
 {
 	if (!l_ptr)
 		return 0;
-	return (link_working_working(l_ptr) || link_working_unknown(l_ptr));
+	return link_working_working(l_ptr) || link_working_unknown(l_ptr);
 }
 
 int tipc_link_is_active(struct link *l_ptr)
 {
-	return ((l_ptr->owner->active_links[0] == l_ptr) ||
-		(l_ptr->owner->active_links[1] == l_ptr));
+	return	(l_ptr->owner->active_links[0] == l_ptr) ||
+		(l_ptr->owner->active_links[1] == l_ptr);
 }
 
 /**
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 2e5385c..26151d3 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -279,12 +279,12 @@ static inline int between(u32 lower, u32 upper, u32 n)
 
 static inline int less_eq(u32 left, u32 right)
 {
-	return (mod(right - left) < 32768u);
+	return mod(right - left) < 32768u;
 }
 
 static inline int less(u32 left, u32 right)
 {
-	return (less_eq(left, right) && (mod(right) != mod(left)));
+	return less_eq(left, right) && (mod(right) != mod(left));
 }
 
 static inline u32 lesser(u32 left, u32 right)
@@ -299,32 +299,32 @@ static inline u32 lesser(u32 left, u32 right)
 
 static inline int link_working_working(struct link *l_ptr)
 {
-	return (l_ptr->state == WORKING_WORKING);
+	return l_ptr->state == WORKING_WORKING;
 }
 
 static inline int link_working_unknown(struct link *l_ptr)
 {
-	return (l_ptr->state == WORKING_UNKNOWN);
+	return l_ptr->state == WORKING_UNKNOWN;
 }
 
 static inline int link_reset_unknown(struct link *l_ptr)
 {
-	return (l_ptr->state == RESET_UNKNOWN);
+	return l_ptr->state == RESET_UNKNOWN;
 }
 
 static inline int link_reset_reset(struct link *l_ptr)
 {
-	return (l_ptr->state == RESET_RESET);
+	return l_ptr->state == RESET_RESET;
 }
 
 static inline int link_blocked(struct link *l_ptr)
 {
-	return (l_ptr->exp_msg_count || l_ptr->blocked);
+	return l_ptr->exp_msg_count || l_ptr->blocked;
 }
 
 static inline int link_congested(struct link *l_ptr)
 {
-	return (l_ptr->out_queue_size >= l_ptr->queue_limit[0]);
+	return l_ptr->out_queue_size >= l_ptr->queue_limit[0];
 }
 
 #endif
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 995d2da..031aad1 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -104,7 +104,7 @@ static inline u32 msg_user(struct tipc_msg *m)
 
 static inline u32 msg_isdata(struct tipc_msg *m)
 {
-	return (msg_user(m) <= TIPC_CRITICAL_IMPORTANCE);
+	return msg_user(m) <= TIPC_CRITICAL_IMPORTANCE;
 }
 
 static inline void msg_set_user(struct tipc_msg *m, u32 n)
@@ -289,7 +289,7 @@ static inline void msg_set_destnode(struct tipc_msg *m, u32 a)
 
 static inline int msg_is_dest(struct tipc_msg *m, u32 d)
 {
-	return(msg_short(m) || (msg_destnode(m) == d));
+	return msg_short(m) || (msg_destnode(m) == d);
 }
 
 static inline u32 msg_routed(struct tipc_msg *m)
@@ -632,7 +632,7 @@ static inline void msg_set_bcast_tag(struct tipc_msg *m, u32 n)
 
 static inline u32 msg_max_pkt(struct tipc_msg *m)
 {
-	return (msg_bits(m, 9, 16, 0xffff) * 4);
+	return msg_bits(m, 9, 16, 0xffff) * 4;
 }
 
 static inline void msg_set_max_pkt(struct tipc_msg *m, u32 n)
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index c13c2c7..9ca4b06 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -116,7 +116,7 @@ DEFINE_RWLOCK(tipc_nametbl_lock);
 
 static int hash(int x)
 {
-	return(x & (tipc_nametbl_size - 1));
+	return x & (tipc_nametbl_size - 1);
 }
 
 /**
diff --git a/net/tipc/node.c b/net/tipc/node.c
index b702c7b..7c49cd0 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -242,17 +242,17 @@ int tipc_node_has_active_links(struct tipc_node *n_ptr)
 
 int tipc_node_has_redundant_links(struct tipc_node *n_ptr)
 {
-	return (n_ptr->working_links > 1);
+	return n_ptr->working_links > 1;
 }
 
 static int tipc_node_has_active_routes(struct tipc_node *n_ptr)
 {
-	return (n_ptr && (n_ptr->last_router >= 0));
+	return n_ptr && (n_ptr->last_router >= 0);
 }
 
 int tipc_node_is_up(struct tipc_node *n_ptr)
 {
-	return (tipc_node_has_active_links(n_ptr) || tipc_node_has_active_routes(n_ptr));
+	return tipc_node_has_active_links(n_ptr) || tipc_node_has_active_routes(n_ptr);
 }
 
 struct tipc_node *tipc_node_attach_link(struct link *l_ptr)
diff --git a/net/tipc/port.h b/net/tipc/port.h
index 8d1652a..e74bd95 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -157,7 +157,7 @@ static inline u32 tipc_peer_node(struct port *p_ptr)
 
 static inline int tipc_port_congested(struct port *p_ptr)
 {
-	return((p_ptr->sent - p_ptr->acked) >= (TIPC_FLOW_CONTROL_WIN * 2));
+	return (p_ptr->sent - p_ptr->acked) >= (TIPC_FLOW_CONTROL_WIN * 2);
 }
 
 /**
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index f7ac94d..33217fc 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1195,7 +1195,7 @@ static int rx_queue_full(struct tipc_msg *msg, u32 queue_size, u32 base)
 	if (msg_connected(msg))
 		threshold *= 4;
 
-	return (queue_size >= threshold);
+	return queue_size >= threshold;
 }
 
 /**
diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index ab6eab4..1a5b9a6 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -604,6 +604,6 @@ int tipc_ispublished(struct tipc_name const *name)
 {
 	u32 domain = 0;
 
-	return(tipc_nametbl_translate(name->type, name->instance,&domain) != 0);
+	return tipc_nametbl_translate(name->type, name->instance, &domain) != 0;
 }
 
diff --git a/net/wireless/core.h b/net/wireless/core.h
index 37580e0..5d89310 100644
--- a/net/wireless/core.h
+++ b/net/wireless/core.h
@@ -86,7 +86,7 @@ struct cfg80211_registered_device *wiphy_to_dev(struct wiphy *wiphy)
 static inline
 bool wiphy_idx_valid(int wiphy_idx)
 {
-	return (wiphy_idx >= 0);
+	return wiphy_idx >= 0;
 }
 
 


