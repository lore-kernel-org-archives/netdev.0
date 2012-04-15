From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: cleanup unsigned to unsigned int
Date: Sun, 15 Apr 2012 17:58:06 +0200
Message-ID: <1334505486.28012.27.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:41564 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752627Ab2DOP6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Apr 2012 11:58:14 -0400
Received: by wejx9 with SMTP id x9so2873577wej.19
        for <netdev@vger.kernel.org>; Sun, 15 Apr 2012 08:58:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use of "unsigned int" is preferred to bare "unsigned" in net tree.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/ip_vs.h                             |   12 ++--
 include/linux/netdevice.h                         |   14 ++--
 include/linux/netfilter/ipset/ip_set.h            |    8 +-
 include/linux/netfilter/nf_conntrack_h323_types.h |   12 ++--
 include/linux/netfilter/nfnetlink.h               |    2 
 include/linux/socket.h                            |    4 -
 include/net/addrconf.h                            |    2 
 include/net/af_unix.h                             |    2 
 include/net/compat.h                              |    8 +-
 include/net/dn.h                                  |    2 
 include/net/dn_fib.h                              |    6 +-
 include/net/dn_route.h                            |    4 -
 include/net/dst_ops.h                             |    2 
 include/net/icmp.h                                |    2 
 include/net/if_inet6.h                            |    2 
 include/net/ip6_route.h                           |    2 
 include/net/ip_fib.h                              |    4 -
 include/net/ip_vs.h                               |   16 ++---
 include/net/ipv6.h                                |    2 
 include/net/llc_c_ev.h                            |    2 
 include/net/neighbour.h                           |    4 -
 include/net/netns/hash.h                          |    2 
 include/net/nfc/nfc.h                             |    2 
 include/net/pkt_sched.h                           |    2 
 include/net/route.h                               |    6 +-
 include/net/sctp/structs.h                        |    8 +-
 include/net/tcp.h                                 |    2 
 include/net/udp.h                                 |    2 
 include/net/wimax.h                               |    4 -
 include/net/x25.h                                 |    2 
 net/802/fc.c                                      |    2 
 net/802/fddi.c                                    |    2 
 net/802/hippi.c                                   |    2 
 net/802/tr.c                                      |    4 -
 net/9p/client.c                                   |    6 +-
 net/9p/trans_fd.c                                 |    2 
 net/atm/br2684.c                                  |    2 
 net/atm/mpoa_proc.c                               |    2 
 net/atm/signaling.c                               |    2 
 net/ax25/ax25_ip.c                                |    4 -
 net/batman-adv/bat_sysfs.c                        |    6 +-
 net/bridge/br_forward.c                           |    2 
 net/bridge/br_multicast.c                         |   10 +--
 net/bridge/br_netlink.c                           |    2 
 net/bridge/br_private_stp.h                       |    7 +-
 net/bridge/br_stp.c                               |    4 -
 net/bridge/br_stp_timer.c                         |    6 +-
 net/bridge/br_sysfs_br.c                          |    2 
 net/caif/caif_socket.c                            |    2 
 net/ceph/auth_x.h                                 |    6 +-
 net/ceph/ceph_common.c                            |    4 -
 net/ceph/ceph_hash.c                              |    6 +-
 net/ceph/crush/mapper.c                           |    8 +-
 net/ceph/debugfs.c                                |    6 +-
 net/ceph/messenger.c                              |   16 ++---
 net/ceph/mon_client.c                             |   10 +--
 net/ceph/osd_client.c                             |    2 
 net/ceph/osdmap.c                                 |   14 ++--
 net/compat.c                                      |   10 +--
 net/core/datagram.c                               |    6 +-
 net/core/dev.c                                    |    7 +-
 net/core/filter.c                                 |    2 
 net/core/neighbour.c                              |    2 
 net/core/net-sysfs.c                              |    8 +-
 net/core/pktgen.c                                 |   20 +++----
 net/core/rtnetlink.c                              |    6 +-
 net/core/skbuff.c                                 |    2 
 net/core/sock.c                                   |    2 
 net/dccp/ccids/ccid3.c                            |   12 ++--
 net/dccp/dccp.h                                   |    8 +-
 net/dccp/input.c                                  |   10 +--
 net/decnet/af_decnet.c                            |    6 +-
 net/decnet/dn_fib.c                               |    5 +
 net/decnet/dn_nsp_in.c                            |    2 
 net/decnet/dn_nsp_out.c                           |    4 -
 net/decnet/dn_route.c                             |   18 +++---
 net/decnet/dn_rules.c                             |    4 -
 net/dns_resolver/dns_key.c                        |    2 
 net/dns_resolver/internal.h                       |    2 
 net/ethernet/eth.c                                |    2 
 net/ieee802154/6lowpan.c                          |    2 
 net/ieee802154/dgram.c                            |    6 +-
 net/ieee802154/raw.c                              |    2 
 net/ipv4/arp.c                                    |    4 -
 net/ipv4/devinet.c                                |    2 
 net/ipv4/fib_frontend.c                           |   10 +--
 net/ipv4/inet_connection_sock.c                   |    3 -
 net/ipv4/inet_timewait_sock.c                     |    2 
 net/ipv4/ip_options.c                             |   12 ++--
 net/ipv4/ip_sockglue.c                            |    4 -
 net/ipv4/ipconfig.c                               |    2 
 net/ipv4/netfilter.c                              |    2 
 net/ipv4/netfilter/arp_tables.c                   |    2 
 net/ipv4/netfilter/ip_tables.c                    |    2 
 net/ipv4/netfilter/nf_nat_sip.c                   |    2 
 net/ipv4/ping.c                                   |    8 +-
 net/ipv4/route.c                                  |   16 ++---
 net/ipv4/sysctl_net_ipv4.c                        |    2 
 net/ipv4/tcp.c                                    |    8 +-
 net/ipv4/tcp_input.c                              |    2 
 net/ipv4/tcp_output.c                             |   24 ++++----
 net/ipv4/tcp_probe.c                              |    2 
 net/ipv4/udp.c                                    |    2 
 net/ipv6/addrconf_core.c                          |    2 
 net/ipv6/datagram.c                               |    2 
 net/ipv6/ip6_flowlabel.c                          |    4 -
 net/ipv6/ip6_tunnel.c                             |    2 
 net/ipv6/ipv6_sockglue.c                          |    2 
 net/ipv6/netfilter/ip6_tables.c                   |    2 
 net/ipv6/route.c                                  |   11 +--
 net/ipv6/xfrm6_tunnel.c                           |    6 +-
 net/irda/ircomm/ircomm_tty_ioctl.c                |    2 
 net/key/af_key.c                                  |    4 -
 net/l2tp/l2tp_core.h                              |   16 ++---
 net/llc/af_llc.c                                  |    2 
 net/netfilter/ipset/ip_set_core.c                 |    6 +-
 net/netfilter/ipvs/ip_vs_app.c                    |    2 
 net/netfilter/ipvs/ip_vs_conn.c                   |   34 ++++++------
 net/netfilter/ipvs/ip_vs_core.c                   |    2 
 net/netfilter/ipvs/ip_vs_ctl.c                    |   26 ++++-----
 net/netfilter/ipvs/ip_vs_dh.c                     |    2 
 net/netfilter/ipvs/ip_vs_ftp.c                    |    2 
 net/netfilter/ipvs/ip_vs_lblc.c                   |    6 +-
 net/netfilter/ipvs/ip_vs_lblcr.c                  |    6 +-
 net/netfilter/ipvs/ip_vs_proto.c                  |   12 ++--
 net/netfilter/ipvs/ip_vs_sh.c                     |    2 
 net/netfilter/ipvs/ip_vs_sync.c                   |    4 -
 net/netfilter/nf_conntrack_h323_main.c            |    2 
 net/netfilter/nfnetlink.c                         |    2 
 net/netfilter/xt_recent.c                         |    2 
 net/netrom/nr_dev.c                               |    2 
 net/nfc/core.c                                    |    4 -
 net/nfc/nfc.h                                     |    2 
 net/openvswitch/vport-netdev.c                    |    4 -
 net/packet/af_packet.c                            |    2 
 net/phonet/af_phonet.c                            |    2 
 net/phonet/pep.c                                  |    8 +-
 net/phonet/pn_dev.c                               |    2 
 net/phonet/socket.c                               |   12 ++--
 net/phonet/sysctl.c                               |    3 -
 net/rose/rose_dev.c                               |    2 
 net/rose/rose_subr.c                              |    2 
 net/rxrpc/af_rxrpc.c                              |    8 +-
 net/rxrpc/ar-ack.c                                |    6 +-
 net/rxrpc/ar-call.c                               |    4 -
 net/rxrpc/ar-input.c                              |    2 
 net/rxrpc/ar-internal.h                           |   16 ++---
 net/rxrpc/ar-key.c                                |   22 +++----
 net/rxrpc/rxkad.c                                 |    6 +-
 net/sctp/associola.c                              |    4 -
 net/sctp/output.c                                 |    4 -
 net/sctp/outqueue.c                               |    2 
 net/sctp/sm_sideeffect.c                          |    4 -
 net/sctp/sm_statefuns.c                           |    4 -
 net/socket.c                                      |   18 +++---
 net/sunrpc/auth_gss/gss_krb5_mech.c               |    2 
 net/sunrpc/cache.c                                |    2 
 net/sunrpc/timer.c                                |    6 +-
 net/sunrpc/xdr.c                                  |    2 
 net/sunrpc/xprt.c                                 |    2 
 net/tipc/link.c                                   |    2 
 net/tipc/socket.c                                 |    8 +-
 net/unix/af_unix.c                                |   21 +++----
 net/wimax/stack.c                                 |    5 +
 net/wireless/wext-core.c                          |    6 +-
 net/x25/x25_facilities.c                          |    4 -
 net/xfrm/xfrm_hash.h                              |    8 +-
 167 files changed, 465 insertions(+), 457 deletions(-)

diff --git a/include/linux/ip_vs.h b/include/linux/ip_vs.h
index 4deb383..be0ef3d 100644
--- a/include/linux/ip_vs.h
+++ b/include/linux/ip_vs.h
@@ -125,8 +125,8 @@ struct ip_vs_service_user {
 
 	/* virtual service options */
 	char			sched_name[IP_VS_SCHEDNAME_MAXLEN];
-	unsigned		flags;		/* virtual service flags */
-	unsigned		timeout;	/* persistent timeout in sec */
+	unsigned int		flags;		/* virtual service flags */
+	unsigned int		timeout;	/* persistent timeout in sec */
 	__be32			netmask;	/* persistent netmask */
 };
 
@@ -137,7 +137,7 @@ struct ip_vs_dest_user {
 	__be16			port;
 
 	/* real server options */
-	unsigned		conn_flags;	/* connection flags */
+	unsigned int		conn_flags;	/* connection flags */
 	int			weight;		/* destination weight */
 
 	/* thresholds for active connections */
@@ -187,8 +187,8 @@ struct ip_vs_service_entry {
 
 	/* service options */
 	char			sched_name[IP_VS_SCHEDNAME_MAXLEN];
-	unsigned		flags;          /* virtual service flags */
-	unsigned		timeout;	/* persistent timeout */
+	unsigned int		flags;          /* virtual service flags */
+	unsigned int		timeout;	/* persistent timeout */
 	__be32			netmask;	/* persistent netmask */
 
 	/* number of real servers */
@@ -202,7 +202,7 @@ struct ip_vs_service_entry {
 struct ip_vs_dest_entry {
 	__be32			addr;		/* destination address */
 	__be16			port;
-	unsigned		conn_flags;	/* connection flags */
+	unsigned int		conn_flags;	/* connection flags */
 	int			weight;		/* destination weight */
 
 	__u32		u_threshold;	/* upper threshold */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5cbaa20..d312232 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -288,7 +288,7 @@ struct hh_cache {
 struct header_ops {
 	int	(*create) (struct sk_buff *skb, struct net_device *dev,
 			   unsigned short type, const void *daddr,
-			   const void *saddr, unsigned len);
+			   const void *saddr, unsigned int len);
 	int	(*parse)(const struct sk_buff *skb, unsigned char *haddr);
 	int	(*rebuild)(struct sk_buff *skb);
 	int	(*cache)(const struct neighbour *neigh, struct hh_cache *hh, __be16 type);
@@ -1689,7 +1689,7 @@ static inline void *skb_gro_network_header(struct sk_buff *skb)
 static inline int dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 				  unsigned short type,
 				  const void *daddr, const void *saddr,
-				  unsigned len)
+				  unsigned int len)
 {
 	if (!dev->header_ops || !dev->header_ops->create)
 		return 0;
@@ -1740,7 +1740,7 @@ struct softnet_data {
 	unsigned int		input_queue_head;
 	unsigned int		input_queue_tail;
 #endif
-	unsigned		dropped;
+	unsigned int		dropped;
 	struct sk_buff_head	input_pkt_queue;
 	struct napi_struct	backlog;
 };
@@ -1925,7 +1925,7 @@ static inline void netdev_sent_queue(struct net_device *dev, unsigned int bytes)
 }
 
 static inline void netdev_tx_completed_queue(struct netdev_queue *dev_queue,
-					     unsigned pkts, unsigned bytes)
+					     unsigned int pkts, unsigned int bytes)
 {
 #ifdef CONFIG_BQL
 	if (unlikely(!bytes))
@@ -1949,7 +1949,7 @@ static inline void netdev_tx_completed_queue(struct netdev_queue *dev_queue,
 }
 
 static inline void netdev_completed_queue(struct net_device *dev,
-					  unsigned pkts, unsigned bytes)
+					  unsigned int pkts, unsigned int bytes)
 {
 	netdev_tx_completed_queue(netdev_get_tx_queue(dev, 0), pkts, bytes);
 }
@@ -2144,9 +2144,9 @@ extern void netdev_rx_handler_unregister(struct net_device *dev);
 extern bool		dev_valid_name(const char *name);
 extern int		dev_ioctl(struct net *net, unsigned int cmd, void __user *);
 extern int		dev_ethtool(struct net *net, struct ifreq *);
-extern unsigned		dev_get_flags(const struct net_device *);
+extern unsigned int	dev_get_flags(const struct net_device *);
 extern int		__dev_change_flags(struct net_device *, unsigned int flags);
-extern int		dev_change_flags(struct net_device *, unsigned);
+extern int		dev_change_flags(struct net_device *, unsigned int);
 extern void		__dev_notify_flags(struct net_device *, unsigned int old_flags);
 extern int		dev_change_name(struct net_device *, const char *);
 extern int		dev_set_alias(struct net_device *, const char *, size_t);
diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index d6d549c..2edc64c 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -478,8 +478,8 @@ union ip_set_name_index {
 
 #define IP_SET_OP_GET_BYNAME	0x00000006	/* Get set index by name */
 struct ip_set_req_get_set {
-	unsigned op;
-	unsigned version;
+	unsigned int op;
+	unsigned int version;
 	union ip_set_name_index set;
 };
 
@@ -488,8 +488,8 @@ struct ip_set_req_get_set {
 
 #define IP_SET_OP_VERSION	0x00000100	/* Ask kernel version */
 struct ip_set_req_version {
-	unsigned op;
-	unsigned version;
+	unsigned int op;
+	unsigned int version;
 };
 
 #endif /*_IP_SET_H */
diff --git a/include/linux/netfilter/nf_conntrack_h323_types.h b/include/linux/netfilter/nf_conntrack_h323_types.h
index f35b6b4..b0821f4 100644
--- a/include/linux/netfilter/nf_conntrack_h323_types.h
+++ b/include/linux/netfilter/nf_conntrack_h323_types.h
@@ -7,12 +7,12 @@
 
 typedef struct TransportAddress_ipAddress {	/* SEQUENCE */
 	int options;		/* No use */
-	unsigned ip;
+	unsigned int ip;
 } TransportAddress_ipAddress;
 
 typedef struct TransportAddress_ip6Address {	/* SEQUENCE */
 	int options;		/* No use */
-	unsigned ip;
+	unsigned int ip;
 } TransportAddress_ip6Address;
 
 typedef struct TransportAddress {	/* CHOICE */
@@ -96,12 +96,12 @@ typedef struct DataType {	/* CHOICE */
 
 typedef struct UnicastAddress_iPAddress {	/* SEQUENCE */
 	int options;		/* No use */
-	unsigned network;
+	unsigned int network;
 } UnicastAddress_iPAddress;
 
 typedef struct UnicastAddress_iP6Address {	/* SEQUENCE */
 	int options;		/* No use */
-	unsigned network;
+	unsigned int network;
 } UnicastAddress_iP6Address;
 
 typedef struct UnicastAddress {	/* CHOICE */
@@ -698,7 +698,7 @@ typedef struct RegistrationRequest {	/* SEQUENCE */
 	} options;
 	RegistrationRequest_callSignalAddress callSignalAddress;
 	RegistrationRequest_rasAddress rasAddress;
-	unsigned timeToLive;
+	unsigned int timeToLive;
 } RegistrationRequest;
 
 typedef struct RegistrationConfirm_callSignalAddress {	/* SEQUENCE OF */
@@ -730,7 +730,7 @@ typedef struct RegistrationConfirm {	/* SEQUENCE */
 		eRegistrationConfirm_genericData = (1 << 12),
 	} options;
 	RegistrationConfirm_callSignalAddress callSignalAddress;
-	unsigned timeToLive;
+	unsigned int timeToLive;
 } RegistrationConfirm;
 
 typedef struct UnregistrationRequest_callSignalAddress {	/* SEQUENCE OF */
diff --git a/include/linux/netfilter/nfnetlink.h b/include/linux/netfilter/nfnetlink.h
index 6fd1f0d..a1048c1 100644
--- a/include/linux/netfilter/nfnetlink.h
+++ b/include/linux/netfilter/nfnetlink.h
@@ -80,7 +80,7 @@ extern int nfnetlink_subsys_register(const struct nfnetlink_subsystem *n);
 extern int nfnetlink_subsys_unregister(const struct nfnetlink_subsystem *n);
 
 extern int nfnetlink_has_listeners(struct net *net, unsigned int group);
-extern int nfnetlink_send(struct sk_buff *skb, struct net *net, u32 pid, unsigned group,
+extern int nfnetlink_send(struct sk_buff *skb, struct net *net, u32 pid, unsigned int group,
 			  int echo, gfp_t flags);
 extern int nfnetlink_set_err(struct net *net, u32 pid, u32 group, int error);
 extern int nfnetlink_unicast(struct sk_buff *skb, struct net *net, u_int32_t pid, int flags);
diff --git a/include/linux/socket.h b/include/linux/socket.h
index b84bbd4..25d6322 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -68,13 +68,13 @@ struct msghdr {
 	__kernel_size_t	msg_iovlen;	/* Number of blocks		*/
 	void 	*	msg_control;	/* Per protocol magic (eg BSD file descriptor passing) */
 	__kernel_size_t	msg_controllen;	/* Length of cmsg list */
-	unsigned	msg_flags;
+	unsigned int	msg_flags;
 };
 
 /* For recvmmsg/sendmmsg */
 struct mmsghdr {
 	struct msghdr   msg_hdr;
-	unsigned        msg_len;
+	unsigned int        msg_len;
 };
 
 /*
diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 757a176..27f450b 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -92,7 +92,7 @@ extern void			addrconf_leave_solict(struct inet6_dev *idev,
 					const struct in6_addr *addr);
 
 static inline unsigned long addrconf_timeout_fixup(u32 timeout,
-						    unsigned unit)
+						   unsigned int unit)
 {
 	if (timeout == 0xffffffff)
 		return ~0UL;
diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index ca68e2c..2ee33da 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -22,7 +22,7 @@ extern struct hlist_head unix_socket_table[UNIX_HASH_SIZE + 1];
 struct unix_address {
 	atomic_t	refcnt;
 	int		len;
-	unsigned	hash;
+	unsigned int	hash;
 	struct sockaddr_un name[0];
 };
 
diff --git a/include/net/compat.h b/include/net/compat.h
index a974ae9..6e95653 100644
--- a/include/net/compat.h
+++ b/include/net/compat.h
@@ -42,12 +42,12 @@ extern int compat_sock_get_timestampns(struct sock *, struct timespec __user *);
 
 extern int get_compat_msghdr(struct msghdr *, struct compat_msghdr __user *);
 extern int verify_compat_iovec(struct msghdr *, struct iovec *, struct sockaddr_storage *, int);
-extern asmlinkage long compat_sys_sendmsg(int,struct compat_msghdr __user *,unsigned);
+extern asmlinkage long compat_sys_sendmsg(int,struct compat_msghdr __user *,unsigned int);
 extern asmlinkage long compat_sys_sendmmsg(int, struct compat_mmsghdr __user *,
-					   unsigned, unsigned);
-extern asmlinkage long compat_sys_recvmsg(int,struct compat_msghdr __user *,unsigned);
+					   unsigned int, unsigned int);
+extern asmlinkage long compat_sys_recvmsg(int,struct compat_msghdr __user *,unsigned int);
 extern asmlinkage long compat_sys_recvmmsg(int, struct compat_mmsghdr __user *,
-					   unsigned, unsigned,
+					   unsigned int, unsigned int,
 					   struct compat_timespec __user *);
 extern asmlinkage long compat_sys_getsockopt(int, int, int, char __user *, int __user *);
 extern int put_cmsg_compat(struct msghdr*, int, int, int, void *);
diff --git a/include/net/dn.h b/include/net/dn.h
index 814af0b..c88bf4e 100644
--- a/include/net/dn.h
+++ b/include/net/dn.h
@@ -199,7 +199,7 @@ static inline void dn_sk_ports_copy(struct flowidn *fld, struct dn_scp *scp)
 	fld->fld_dport = scp->addrrem;
 }
 
-extern unsigned dn_mss_from_pmtu(struct net_device *dev, int mtu);
+extern unsigned int dn_mss_from_pmtu(struct net_device *dev, int mtu);
 
 #define DN_MENUVER_ACC 0x01
 #define DN_MENUVER_USR 0x02
diff --git a/include/net/dn_fib.h b/include/net/dn_fib.h
index 782ef7c..1ee9d4b 100644
--- a/include/net/dn_fib.h
+++ b/include/net/dn_fib.h
@@ -31,7 +31,7 @@ struct dn_fib_res {
 
 struct dn_fib_nh {
 	struct net_device	*nh_dev;
-	unsigned		nh_flags;
+	unsigned int		nh_flags;
 	unsigned char		nh_scope;
 	int			nh_weight;
 	int			nh_power;
@@ -45,7 +45,7 @@ struct dn_fib_info {
 	int 			fib_treeref;
 	atomic_t		fib_clntref;
 	int			fib_dead;
-	unsigned		fib_flags;
+	unsigned int		fib_flags;
 	int			fib_protocol;
 	__le16			fib_prefsrc;
 	__u32			fib_priority;
@@ -140,7 +140,7 @@ extern void dn_fib_table_cleanup(void);
  */
 extern void dn_fib_rules_init(void);
 extern void dn_fib_rules_cleanup(void);
-extern unsigned dnet_addr_type(__le16 addr);
+extern unsigned int dnet_addr_type(__le16 addr);
 extern int dn_fib_lookup(struct flowidn *fld, struct dn_fib_res *res);
 
 extern int dn_fib_dump(struct sk_buff *skb, struct netlink_callback *cb);
diff --git a/include/net/dn_route.h b/include/net/dn_route.h
index 81712cf..c507e05 100644
--- a/include/net/dn_route.h
+++ b/include/net/dn_route.h
@@ -76,8 +76,8 @@ struct dn_route {
 	__le16 rt_src_map;
 	__le16 rt_dst_map;
 
-	unsigned rt_flags;
-	unsigned rt_type;
+	unsigned int rt_flags;
+	unsigned int rt_type;
 };
 
 static inline bool dn_is_input_route(struct dn_route *rt)
diff --git a/include/net/dst_ops.h b/include/net/dst_ops.h
index e1c2ee0..3682a0a 100644
--- a/include/net/dst_ops.h
+++ b/include/net/dst_ops.h
@@ -12,7 +12,7 @@ struct sk_buff;
 struct dst_ops {
 	unsigned short		family;
 	__be16			protocol;
-	unsigned		gc_thresh;
+	unsigned int		gc_thresh;
 
 	int			(*gc)(struct dst_ops *ops);
 	struct dst_entry *	(*check)(struct dst_entry *, __u32 cookie);
diff --git a/include/net/icmp.h b/include/net/icmp.h
index ce70a58..9ac2524 100644
--- a/include/net/icmp.h
+++ b/include/net/icmp.h
@@ -25,7 +25,7 @@
 
 struct icmp_err {
   int		errno;
-  unsigned	fatal:1;
+  unsigned int	fatal:1;
 };
 
 extern const struct icmp_err icmp_err_convert[];
diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index 51a7031..50f325f 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -120,7 +120,7 @@ struct ifmcaddr6 {
 	unsigned char		mca_crcount;
 	unsigned long		mca_sfcount[2];
 	struct timer_list	mca_timer;
-	unsigned		mca_flags;
+	unsigned int		mca_flags;
 	int			mca_users;
 	atomic_t		mca_refcnt;
 	spinlock_t		mca_lock;
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 2ad92ca..c062b67 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -146,7 +146,7 @@ struct rt6_rtnl_dump_arg {
 
 extern int rt6_dump_route(struct rt6_info *rt, void *p_arg);
 extern void rt6_ifdown(struct net *net, struct net_device *dev);
-extern void rt6_mtu_change(struct net_device *dev, unsigned mtu);
+extern void rt6_mtu_change(struct net_device *dev, unsigned int mtu);
 extern void rt6_remove_prefsrc(struct inet6_ifaddr *ifp);
 
 
diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 10422ef..78df0866 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -49,7 +49,7 @@ struct fib_nh {
 	struct net_device	*nh_dev;
 	struct hlist_node	nh_hash;
 	struct fib_info		*nh_parent;
-	unsigned		nh_flags;
+	unsigned int		nh_flags;
 	unsigned char		nh_scope;
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	int			nh_weight;
@@ -74,7 +74,7 @@ struct fib_info {
 	struct net		*fib_net;
 	int			fib_treeref;
 	atomic_t		fib_clntref;
-	unsigned		fib_flags;
+	unsigned int		fib_flags;
 	unsigned char		fib_dead;
 	unsigned char		fib_protocol;
 	unsigned char		fib_scope;
diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 2bdee51..a903a82 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -580,8 +580,8 @@ struct ip_vs_service_user_kern {
 	/* virtual service options */
 	char			*sched_name;
 	char			*pe_name;
-	unsigned		flags;		/* virtual service flags */
-	unsigned		timeout;	/* persistent timeout in sec */
+	unsigned int		flags;		/* virtual service flags */
+	unsigned int		timeout;	/* persistent timeout in sec */
 	u32			netmask;	/* persistent netmask */
 };
 
@@ -592,7 +592,7 @@ struct ip_vs_dest_user_kern {
 	u16			port;
 
 	/* real server options */
-	unsigned		conn_flags;	/* connection flags */
+	unsigned int		conn_flags;	/* connection flags */
 	int			weight;		/* destination weight */
 
 	/* thresholds for active connections */
@@ -616,8 +616,8 @@ struct ip_vs_service {
 	union nf_inet_addr	addr;	  /* IP address for virtual service */
 	__be16			port;	  /* port number for the service */
 	__u32                   fwmark;   /* firewall mark of the service */
-	unsigned		flags;	  /* service status flags */
-	unsigned		timeout;  /* persistent timeout in ticks */
+	unsigned int		flags;	  /* service status flags */
+	unsigned int		timeout;  /* persistent timeout in ticks */
 	__be32			netmask;  /* grouping granularity */
 	struct net		*net;
 
@@ -647,7 +647,7 @@ struct ip_vs_dest {
 	u16			af;		/* address family */
 	__be16			port;		/* port number of the server */
 	union nf_inet_addr	addr;		/* IP address of the server */
-	volatile unsigned	flags;		/* dest status flags */
+	volatile unsigned int	flags;		/* dest status flags */
 	atomic_t		conn_flags;	/* flags to copy to conn */
 	atomic_t		weight;		/* server weight */
 
@@ -953,7 +953,7 @@ static inline int sysctl_sync_ver(struct netns_ipvs *ipvs)
  *      IPVS core functions
  *      (from ip_vs_core.c)
  */
-extern const char *ip_vs_proto_name(unsigned proto);
+extern const char *ip_vs_proto_name(unsigned int proto);
 extern void ip_vs_init_hash_table(struct list_head *table, int rows);
 #define IP_VS_INIT_HASH_TABLE(t) ip_vs_init_hash_table((t), ARRAY_SIZE((t)))
 
@@ -1014,7 +1014,7 @@ extern void ip_vs_conn_fill_cport(struct ip_vs_conn *cp, __be16 cport);
 
 struct ip_vs_conn *ip_vs_conn_new(const struct ip_vs_conn_param *p,
 				  const union nf_inet_addr *daddr,
-				  __be16 dport, unsigned flags,
+				  __be16 dport, unsigned int flags,
 				  struct ip_vs_dest *dest, __u32 fwmark);
 extern void ip_vs_conn_expire_now(struct ip_vs_conn *cp);
 
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index e4170a2..2d3fca37 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -345,7 +345,7 @@ static inline int ipv6_addr_equal(const struct in6_addr *a1,
 static inline int __ipv6_prefix_equal(const __be32 *a1, const __be32 *a2,
 				      unsigned int prefixlen)
 {
-	unsigned pdw, pbi;
+	unsigned int pdw, pbi;
 
 	/* check complete u32 in prefix */
 	pdw = prefixlen >> 5;
diff --git a/include/net/llc_c_ev.h b/include/net/llc_c_ev.h
index 23a4093..6ca3113 100644
--- a/include/net/llc_c_ev.h
+++ b/include/net/llc_c_ev.h
@@ -264,6 +264,6 @@ extern int llc_conn_ev_qlfy_set_status_rst_done(struct sock *sk,
 static __inline__ int llc_conn_space(struct sock *sk, struct sk_buff *skb)
 {
 	return atomic_read(&sk->sk_rmem_alloc) + skb->truesize <
-	       (unsigned)sk->sk_rcvbuf;
+	       (unsigned int)sk->sk_rcvbuf;
 }
 #endif /* LLC_C_EV_H */
diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 63ebd70..6cdfeed 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -322,7 +322,7 @@ static inline int neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
 #ifdef CONFIG_BRIDGE_NETFILTER
 static inline int neigh_hh_bridge(struct hh_cache *hh, struct sk_buff *skb)
 {
-	unsigned seq, hh_alen;
+	unsigned int seq, hh_alen;
 
 	do {
 		seq = read_seqbegin(&hh->hh_lock);
@@ -335,7 +335,7 @@ static inline int neigh_hh_bridge(struct hh_cache *hh, struct sk_buff *skb)
 
 static inline int neigh_hh_output(struct hh_cache *hh, struct sk_buff *skb)
 {
-	unsigned seq;
+	unsigned int seq;
 	int hh_len;
 
 	do {
diff --git a/include/net/netns/hash.h b/include/net/netns/hash.h
index 548d78f..c06ac58 100644
--- a/include/net/netns/hash.h
+++ b/include/net/netns/hash.h
@@ -5,7 +5,7 @@
 
 struct net;
 
-static inline unsigned net_hash_mix(struct net *net)
+static inline unsigned int net_hash_mix(struct net *net)
 {
 #ifdef CONFIG_NET_NS
 	/*
diff --git a/include/net/nfc/nfc.h b/include/net/nfc/nfc.h
index bac070b..79955a2 100644
--- a/include/net/nfc/nfc.h
+++ b/include/net/nfc/nfc.h
@@ -86,7 +86,7 @@ struct nfc_genl_data {
 };
 
 struct nfc_dev {
-	unsigned idx;
+	unsigned int idx;
 	struct nfc_target *targets;
 	int n_targets;
 	int targets_generation;
diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index fffdc60..66f5ac3 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -107,7 +107,7 @@ extern int tc_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 /* Calculate maximal size of packet seen by hard_start_xmit
    routine of this device.
  */
-static inline unsigned psched_mtu(const struct net_device *dev)
+static inline unsigned int psched_mtu(const struct net_device *dev)
 {
 	return dev->mtu + dev->hard_header_len;
 }
diff --git a/include/net/route.h b/include/net/route.h
index b1c0d5b..ed2b78e 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -50,7 +50,7 @@ struct rtable {
 	__be32			rt_key_src;
 
 	int			rt_genid;
-	unsigned		rt_flags;
+	unsigned int		rt_flags;
 	__u16			rt_type;
 	__u8			rt_key_tos;
 
@@ -185,8 +185,8 @@ extern unsigned short	ip_rt_frag_needed(struct net *net, const struct iphdr *iph
 					  unsigned short new_mtu, struct net_device *dev);
 extern void		ip_rt_send_redirect(struct sk_buff *skb);
 
-extern unsigned		inet_addr_type(struct net *net, __be32 addr);
-extern unsigned		inet_dev_addr_type(struct net *net, const struct net_device *dev, __be32 addr);
+extern unsigned int		inet_addr_type(struct net *net, __be32 addr);
+extern unsigned int		inet_dev_addr_type(struct net *net, const struct net_device *dev, __be32 addr);
 extern void		ip_rt_multicast_event(struct in_device *);
 extern int		ip_rt_ioctl(struct net *, unsigned int cmd, void __user *arg);
 extern void		ip_rt_get_source(u8 *src, struct sk_buff *skb, struct rtable *rt);
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 88949a9..e4652fe 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1145,10 +1145,10 @@ struct sctp_outq {
 	/* Data pending that has never been transmitted.  */
 	struct list_head out_chunk_list;
 
-	unsigned out_qlen;	/* Total length of queued data chunks. */
+	unsigned int out_qlen;	/* Total length of queued data chunks. */
 
 	/* Error of send failed, may used in SCTP_SEND_FAILED event. */
-	unsigned error;
+	unsigned int error;
 
 	/* These are control chunks we want to send.  */
 	struct list_head control_chunk_list;
@@ -2000,8 +2000,8 @@ void sctp_assoc_update(struct sctp_association *old,
 __u32 sctp_association_get_next_tsn(struct sctp_association *);
 
 void sctp_assoc_sync_pmtu(struct sctp_association *);
-void sctp_assoc_rwnd_increase(struct sctp_association *, unsigned);
-void sctp_assoc_rwnd_decrease(struct sctp_association *, unsigned);
+void sctp_assoc_rwnd_increase(struct sctp_association *, unsigned int);
+void sctp_assoc_rwnd_decrease(struct sctp_association *, unsigned int);
 void sctp_assoc_set_primary(struct sctp_association *,
 			    struct sctp_transport *);
 void sctp_assoc_del_nonprimary_peers(struct sctp_association *,
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 057f016..025c31aa 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1226,7 +1226,7 @@ extern void tcp_put_md5sig_pool(void);
 
 extern int tcp_md5_hash_header(struct tcp_md5sig_pool *, const struct tcphdr *);
 extern int tcp_md5_hash_skb_data(struct tcp_md5sig_pool *, const struct sk_buff *,
-				 unsigned header_len);
+				 unsigned int header_len);
 extern int tcp_md5_hash_key(struct tcp_md5sig_pool *hp,
 			    const struct tcp_md5sig_key *key);
 
diff --git a/include/net/udp.h b/include/net/udp.h
index 9671f5f..e66fc29 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -81,7 +81,7 @@ struct udp_table {
 extern struct udp_table udp_table;
 extern void udp_table_init(struct udp_table *, const char *);
 static inline struct udp_hslot *udp_hashslot(struct udp_table *table,
-					     struct net *net, unsigned num)
+					     struct net *net, unsigned int num)
 {
 	return &table->hash[udp_hashfn(net, num, table->mask)];
 }
diff --git a/include/net/wimax.h b/include/net/wimax.h
index 322ff4f..bbb74f9 100644
--- a/include/net/wimax.h
+++ b/include/net/wimax.h
@@ -423,8 +423,8 @@ struct wimax_dev {
 	int (*op_reset)(struct wimax_dev *wimax_dev);
 
 	struct rfkill *rfkill;
-	unsigned rf_hw;
-	unsigned rf_sw;
+	unsigned int rf_hw;
+	unsigned int rf_sw;
 	char name[32];
 
 	struct dentry *debugfs_dentry;
diff --git a/include/net/x25.h b/include/net/x25.h
index a06119a..b4a8a89 100644
--- a/include/net/x25.h
+++ b/include/net/x25.h
@@ -305,7 +305,7 @@ static inline void x25_unregister_sysctl(void) {};
 #endif /* CONFIG_SYSCTL */
 
 struct x25_skb_cb {
-	unsigned flags;
+	unsigned int flags;
 };
 #define X25_SKB_CB(s) ((struct x25_skb_cb *) ((s)->cb))
 
diff --git a/net/802/fc.c b/net/802/fc.c
index b324e31..05eea6b 100644
--- a/net/802/fc.c
+++ b/net/802/fc.c
@@ -35,7 +35,7 @@
 
 static int fc_header(struct sk_buff *skb, struct net_device *dev,
 		     unsigned short type,
-		     const void *daddr, const void *saddr, unsigned len)
+		     const void *daddr, const void *saddr, unsigned int len)
 {
 	struct fch_hdr *fch;
 	int hdr_len;
diff --git a/net/802/fddi.c b/net/802/fddi.c
index 5ab25cd..9cda406 100644
--- a/net/802/fddi.c
+++ b/net/802/fddi.c
@@ -51,7 +51,7 @@
 
 static int fddi_header(struct sk_buff *skb, struct net_device *dev,
 		       unsigned short type,
-		       const void *daddr, const void *saddr, unsigned len)
+		       const void *daddr, const void *saddr, unsigned int len)
 {
 	int hl = FDDI_K_SNAP_HLEN;
 	struct fddihdr *fddi;
diff --git a/net/802/hippi.c b/net/802/hippi.c
index 056794e..51a1f53 100644
--- a/net/802/hippi.c
+++ b/net/802/hippi.c
@@ -45,7 +45,7 @@
 
 static int hippi_header(struct sk_buff *skb, struct net_device *dev,
 			unsigned short type,
-			const void *daddr, const void *saddr, unsigned len)
+			const void *daddr, const void *saddr, unsigned int len)
 {
 	struct hippi_hdr *hip = (struct hippi_hdr *)skb_push(skb, HIPPI_HLEN);
 	struct hippi_cb *hcb = (struct hippi_cb *) skb->cb;
diff --git a/net/802/tr.c b/net/802/tr.c
index b9a3a14..e65f0b8 100644
--- a/net/802/tr.c
+++ b/net/802/tr.c
@@ -101,7 +101,7 @@ static inline unsigned long rif_hash(const unsigned char *addr)
 
 static int tr_header(struct sk_buff *skb, struct net_device *dev,
 		     unsigned short type,
-		     const void *daddr, const void *saddr, unsigned len)
+		     const void *daddr, const void *saddr, unsigned int len)
 {
 	struct trh_hdr *trh;
 	int hdr_len;
@@ -193,7 +193,7 @@ __be16 tr_type_trans(struct sk_buff *skb, struct net_device *dev)
 
 	struct trh_hdr *trh;
 	struct trllc *trllc;
-	unsigned riflen=0;
+	unsigned int riflen=0;
 
 	skb->dev = dev;
 	skb_reset_mac_header(skb);
diff --git a/net/9p/client.c b/net/9p/client.c
index b23a17c..a170893 100644
--- a/net/9p/client.c
+++ b/net/9p/client.c
@@ -1530,7 +1530,7 @@ p9_client_read(struct p9_fid *fid, char *data, char __user *udata, u64 offset,
 
 
 	p9_debug(P9_DEBUG_9P, ">>> TREAD fid %d offset %llu %d\n",
-		   fid->fid, (long long unsigned) offset, count);
+		   fid->fid, (unsigned long long) offset, count);
 	err = 0;
 	clnt = fid->clnt;
 
@@ -1605,7 +1605,7 @@ p9_client_write(struct p9_fid *fid, char *data, const char __user *udata,
 	struct p9_req_t *req;
 
 	p9_debug(P9_DEBUG_9P, ">>> TWRITE fid %d offset %llu count %d\n",
-				fid->fid, (long long unsigned) offset, count);
+				fid->fid, (unsigned long long) offset, count);
 	err = 0;
 	clnt = fid->clnt;
 
@@ -2040,7 +2040,7 @@ int p9_client_readdir(struct p9_fid *fid, char *data, u32 count, u64 offset)
 	char *dataptr;
 
 	p9_debug(P9_DEBUG_9P, ">>> TREADDIR fid %d offset %llu count %d\n",
-				fid->fid, (long long unsigned) offset, count);
+				fid->fid, (unsigned long long) offset, count);
 
 	err = 0;
 	clnt = fid->clnt;
diff --git a/net/9p/trans_fd.c b/net/9p/trans_fd.c
index fccae26..6449bae 100644
--- a/net/9p/trans_fd.c
+++ b/net/9p/trans_fd.c
@@ -513,7 +513,7 @@ error:
 	clear_bit(Wworksched, &m->wsched);
 }
 
-static int p9_pollwake(wait_queue_t *wait, unsigned mode, int sync, void *key)
+static int p9_pollwake(wait_queue_t *wait, unsigned int mode, int sync, void *key)
 {
 	struct p9_poll_wait *pwait =
 		container_of(wait, struct p9_poll_wait, wait);
diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index 353fccf..4819d315 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -73,7 +73,7 @@ struct br2684_vcc {
 #ifdef CONFIG_ATM_BR2684_IPFILTER
 	struct br2684_filter filter;
 #endif /* CONFIG_ATM_BR2684_IPFILTER */
-	unsigned copies_needed, copies_failed;
+	unsigned int copies_needed, copies_failed;
 };
 
 struct br2684_dev {
diff --git a/net/atm/mpoa_proc.c b/net/atm/mpoa_proc.c
index 53e5002..5bdd300 100644
--- a/net/atm/mpoa_proc.c
+++ b/net/atm/mpoa_proc.c
@@ -207,7 +207,7 @@ static ssize_t proc_mpc_write(struct file *file, const char __user *buff,
 			      size_t nbytes, loff_t *ppos)
 {
 	char *page, *p;
-	unsigned len;
+	unsigned int len;
 
 	if (nbytes == 0)
 		return 0;
diff --git a/net/atm/signaling.c b/net/atm/signaling.c
index 509c8ac..86767ca 100644
--- a/net/atm/signaling.c
+++ b/net/atm/signaling.c
@@ -166,7 +166,7 @@ void sigd_enq2(struct atm_vcc *vcc, enum atmsvc_msg_type type,
 {
 	struct sk_buff *skb;
 	struct atmsvc_msg *msg;
-	static unsigned session = 0;
+	static unsigned int session = 0;
 
 	pr_debug("%d (0x%p)\n", (int)type, vcc);
 	while (!(skb = alloc_skb(sizeof(struct atmsvc_msg), GFP_KERNEL)))
diff --git a/net/ax25/ax25_ip.c b/net/ax25/ax25_ip.c
index 846ae4e..67de6b3 100644
--- a/net/ax25/ax25_ip.c
+++ b/net/ax25/ax25_ip.c
@@ -48,7 +48,7 @@
 
 int ax25_hard_header(struct sk_buff *skb, struct net_device *dev,
 		     unsigned short type, const void *daddr,
-		     const void *saddr, unsigned len)
+		     const void *saddr, unsigned int len)
 {
 	unsigned char *buff;
 
@@ -219,7 +219,7 @@ put:
 
 int ax25_hard_header(struct sk_buff *skb, struct net_device *dev,
 		     unsigned short type, const void *daddr,
-		     const void *saddr, unsigned len)
+		     const void *saddr, unsigned int len)
 {
 	return -AX25_HEADER_LEN;
 }
diff --git a/net/batman-adv/bat_sysfs.c b/net/batman-adv/bat_sysfs.c
index c6efd68..2c81688 100644
--- a/net/batman-adv/bat_sysfs.c
+++ b/net/batman-adv/bat_sysfs.c
@@ -149,7 +149,7 @@ static int store_bool_attr(char *buff, size_t count,
 		 atomic_read(attr) == 1 ? "enabled" : "disabled",
 		 enabled == 1 ? "enabled" : "disabled");
 
-	atomic_set(attr, (unsigned)enabled);
+	atomic_set(attr, (unsigned int)enabled);
 	return count;
 }
 
@@ -268,7 +268,7 @@ static ssize_t store_vis_mode(struct kobject *kobj, struct attribute *attr,
 		 "client" : "server", vis_mode_tmp == VIS_TYPE_CLIENT_UPDATE ?
 		 "client" : "server");
 
-	atomic_set(&bat_priv->vis_mode, (unsigned)vis_mode_tmp);
+	atomic_set(&bat_priv->vis_mode, (unsigned int)vis_mode_tmp);
 	return count;
 }
 
@@ -354,7 +354,7 @@ static ssize_t store_gw_mode(struct kobject *kobj, struct attribute *attr,
 		 curr_gw_mode_str, buff);
 
 	gw_deselect(bat_priv);
-	atomic_set(&bat_priv->gw_mode, (unsigned)gw_mode_tmp);
+	atomic_set(&bat_priv->gw_mode, (unsigned int)gw_mode_tmp);
 	return count;
 }
 
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 61f6534..aab8470 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -34,7 +34,7 @@ static inline int should_deliver(const struct net_bridge_port *p,
 		p->state == BR_STATE_FORWARDING);
 }
 
-static inline unsigned packet_length(const struct sk_buff *skb)
+static inline unsigned int packet_length(const struct sk_buff *skb)
 {
 	return skb->len - (skb->protocol == htons(ETH_P_8021Q) ? VLAN_HLEN : 0);
 }
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 27ca25e..020e463 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -512,8 +512,8 @@ static struct net_bridge_mdb_entry *br_multicast_get_group(
 	struct net_bridge_mdb_htable *mdb;
 	struct net_bridge_mdb_entry *mp;
 	struct hlist_node *p;
-	unsigned count = 0;
-	unsigned max;
+	unsigned int count = 0;
+	unsigned int max;
 	int elasticity;
 	int err;
 
@@ -1281,8 +1281,8 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
 	struct sk_buff *skb2 = skb;
 	const struct iphdr *iph;
 	struct igmphdr *ih;
-	unsigned len;
-	unsigned offset;
+	unsigned int len;
+	unsigned int offset;
 	int err;
 
 	/* We treat OOM as packet loss for now. */
@@ -1382,7 +1382,7 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
 	u8 icmp6_type;
 	u8 nexthdr;
 	__be16 frag_off;
-	unsigned len;
+	unsigned int len;
 	int offset;
 	int err;
 
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 346b368..df38108 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -88,7 +88,7 @@ void br_ifinfo_notify(int event, struct net_bridge_port *port)
 	int err = -ENOBUFS;
 
 	br_debug(port->br, "port %u(%s) event %d\n",
-		 (unsigned)port->port_no, port->dev->name, event);
+		 (unsigned int)port->port_no, port->dev->name, event);
 
 	skb = nlmsg_new(br_nlmsg_size(), GFP_ATOMIC);
 	if (skb == NULL)
diff --git a/net/bridge/br_private_stp.h b/net/bridge/br_private_stp.h
index 05ed9bc..0c0fe36 100644
--- a/net/bridge/br_private_stp.h
+++ b/net/bridge/br_private_stp.h
@@ -29,10 +29,9 @@
 #define BR_MIN_PATH_COST	1
 #define BR_MAX_PATH_COST	65535
 
-struct br_config_bpdu
-{
-	unsigned	topology_change:1;
-	unsigned	topology_change_ack:1;
+struct br_config_bpdu {
+	unsigned int	topology_change:1;
+	unsigned int	topology_change_ack:1;
 	bridge_id	root;
 	int		root_path_cost;
 	bridge_id	bridge_id;
diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index 8c836d9..af9a120 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -32,7 +32,7 @@ static const char *const br_port_state_names[] = {
 void br_log_state(const struct net_bridge_port *p)
 {
 	br_info(p->br, "port %u(%s) entered %s state\n",
-		(unsigned) p->port_no, p->dev->name,
+		(unsigned int) p->port_no, p->dev->name,
 		br_port_state_names[p->state]);
 }
 
@@ -478,7 +478,7 @@ void br_received_tcn_bpdu(struct net_bridge_port *p)
 {
 	if (br_is_designated_port(p)) {
 		br_info(p->br, "port %u(%s) received tcn bpdu\n",
-			(unsigned) p->port_no, p->dev->name);
+			(unsigned int) p->port_no, p->dev->name);
 
 		br_topology_change_detection(p->br);
 		br_topology_change_acknowledge(p);
diff --git a/net/bridge/br_stp_timer.c b/net/bridge/br_stp_timer.c
index 58de2a0..a6747e6 100644
--- a/net/bridge/br_stp_timer.c
+++ b/net/bridge/br_stp_timer.c
@@ -56,7 +56,7 @@ static void br_message_age_timer_expired(unsigned long arg)
 		return;
 
 	br_info(br, "port %u(%s) neighbor %.2x%.2x.%pM lost\n",
-		(unsigned) p->port_no, p->dev->name,
+		(unsigned int) p->port_no, p->dev->name,
 		id->prio[0], id->prio[1], &id->addr);
 
 	/*
@@ -84,7 +84,7 @@ static void br_forward_delay_timer_expired(unsigned long arg)
 	struct net_bridge *br = p->br;
 
 	br_debug(br, "port %u(%s) forward delay timer\n",
-		 (unsigned) p->port_no, p->dev->name);
+		 (unsigned int) p->port_no, p->dev->name);
 	spin_lock(&br->lock);
 	if (p->state == BR_STATE_LISTENING) {
 		p->state = BR_STATE_LEARNING;
@@ -131,7 +131,7 @@ static void br_hold_timer_expired(unsigned long arg)
 	struct net_bridge_port *p = (struct net_bridge_port *) arg;
 
 	br_debug(p->br, "port %u(%s) hold timer expired\n",
-		 (unsigned) p->port_no, p->dev->name);
+		 (unsigned int) p->port_no, p->dev->name);
 
 	spin_lock(&p->br->lock);
 	if (p->config_pending)
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index c236c0e..766fd7f 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -297,7 +297,7 @@ static ssize_t store_group_addr(struct device *d,
 				const char *buf, size_t len)
 {
 	struct net_bridge *br = to_bridge(d);
-	unsigned new_addr[6];
+	unsigned int new_addr[6];
 	int i;
 
 	if (!capable(CAP_NET_ADMIN))
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index ce47ee9..0dccdb3 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -130,7 +130,7 @@ static int caif_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	struct caifsock *cf_sk = container_of(sk, struct caifsock, sk);
 
 	if (atomic_read(&sk->sk_rmem_alloc) + skb->truesize >=
-		(unsigned)sk->sk_rcvbuf && rx_flow_is_on(cf_sk)) {
+		(unsigned int)sk->sk_rcvbuf && rx_flow_is_on(cf_sk)) {
 		if (net_ratelimit())
 			pr_debug("sending flow OFF (queue len = %d %d)\n",
 					atomic_read(&cf_sk->sk.sk_rmem_alloc),
diff --git a/net/ceph/auth_x.h b/net/ceph/auth_x.h
index e02da7a..f459e93 100644
--- a/net/ceph/auth_x.h
+++ b/net/ceph/auth_x.h
@@ -13,7 +13,7 @@
  */
 struct ceph_x_ticket_handler {
 	struct rb_node node;
-	unsigned service;
+	unsigned int service;
 
 	struct ceph_crypto_key session_key;
 	struct ceph_timespec validity;
@@ -27,7 +27,7 @@ struct ceph_x_ticket_handler {
 
 struct ceph_x_authorizer {
 	struct ceph_buffer *buf;
-	unsigned service;
+	unsigned int service;
 	u64 nonce;
 	char reply_buf[128];  /* big enough for encrypted blob */
 };
@@ -38,7 +38,7 @@ struct ceph_x_info {
 	bool starting;
 	u64 server_challenge;
 
-	unsigned have_keys;
+	unsigned int have_keys;
 	struct rb_root ticket_handlers;
 
 	struct ceph_x_authorizer auth_authorizer;
diff --git a/net/ceph/ceph_common.c b/net/ceph/ceph_common.c
index cc91319..a776f75 100644
--- a/net/ceph/ceph_common.c
+++ b/net/ceph/ceph_common.c
@@ -441,8 +441,8 @@ EXPORT_SYMBOL(ceph_client_id);
  * create a fresh client instance
  */
 struct ceph_client *ceph_create_client(struct ceph_options *opt, void *private,
-				       unsigned supported_features,
-				       unsigned required_features)
+				       unsigned int supported_features,
+				       unsigned int required_features)
 {
 	struct ceph_client *client;
 	struct ceph_entity_addr *myaddr = NULL;
diff --git a/net/ceph/ceph_hash.c b/net/ceph/ceph_hash.c
index 0a1b53b..67bb1f1 100644
--- a/net/ceph/ceph_hash.c
+++ b/net/ceph/ceph_hash.c
@@ -20,7 +20,7 @@
 		c = c - a;  c = c - b;  c = c ^ (b >> 15);	\
 	} while (0)
 
-unsigned ceph_str_hash_rjenkins(const char *str, unsigned length)
+unsigned int ceph_str_hash_rjenkins(const char *str, unsigned int length)
 {
 	const unsigned char *k = (const unsigned char *)str;
 	__u32 a, b, c;  /* the internal state */
@@ -81,7 +81,7 @@ unsigned ceph_str_hash_rjenkins(const char *str, unsigned length)
 /*
  * linux dcache hash
  */
-unsigned ceph_str_hash_linux(const char *str, unsigned length)
+unsigned int ceph_str_hash_linux(const char *str, unsigned int length)
 {
 	unsigned long hash = 0;
 	unsigned char c;
@@ -94,7 +94,7 @@ unsigned ceph_str_hash_linux(const char *str, unsigned length)
 }
 
 
-unsigned ceph_str_hash(int type, const char *s, unsigned len)
+unsigned int ceph_str_hash(int type, const char *s, unsigned int len)
 {
 	switch (type) {
 	case CEPH_STR_HASH_LINUX:
diff --git a/net/ceph/crush/mapper.c b/net/ceph/crush/mapper.c
index b79747c..854ac53 100644
--- a/net/ceph/crush/mapper.c
+++ b/net/ceph/crush/mapper.c
@@ -68,8 +68,8 @@ int crush_find_rule(struct crush_map *map, int ruleset, int type, int size)
 static int bucket_perm_choose(struct crush_bucket *bucket,
 			      int x, int r)
 {
-	unsigned pr = r % bucket->size;
-	unsigned i, s;
+	unsigned int pr = r % bucket->size;
+	unsigned int i, s;
 
 	/* start a new permutation if @x has changed */
 	if (bucket->perm_x != x || bucket->perm_n == 0) {
@@ -100,13 +100,13 @@ static int bucket_perm_choose(struct crush_bucket *bucket,
 	for (i = 0; i < bucket->perm_n; i++)
 		dprintk(" perm_choose have %d: %d\n", i, bucket->perm[i]);
 	while (bucket->perm_n <= pr) {
-		unsigned p = bucket->perm_n;
+		unsigned int p = bucket->perm_n;
 		/* no point in swapping the final entry */
 		if (p < bucket->size - 1) {
 			i = crush_hash32_3(bucket->hash, x, bucket->id, p) %
 				(bucket->size - p);
 			if (i) {
-				unsigned t = bucket->perm[p + i];
+				unsigned int t = bucket->perm[p + i];
 				bucket->perm[p + i] = bucket->perm[p];
 				bucket->perm[p] = t;
 			}
diff --git a/net/ceph/debugfs.c b/net/ceph/debugfs.c
index 27d4ea3..54b531a 100644
--- a/net/ceph/debugfs.c
+++ b/net/ceph/debugfs.c
@@ -94,9 +94,9 @@ static int monc_show(struct seq_file *s, void *p)
 	mutex_lock(&monc->mutex);
 
 	if (monc->have_mdsmap)
-		seq_printf(s, "have mdsmap %u\n", (unsigned)monc->have_mdsmap);
+		seq_printf(s, "have mdsmap %u\n", (unsigned int)monc->have_mdsmap);
 	if (monc->have_osdmap)
-		seq_printf(s, "have osdmap %u\n", (unsigned)monc->have_osdmap);
+		seq_printf(s, "have osdmap %u\n", (unsigned int)monc->have_osdmap);
 	if (monc->want_next_osdmap)
 		seq_printf(s, "want next osdmap\n");
 
@@ -146,7 +146,7 @@ static int osdc_show(struct seq_file *s, void *pp)
 
 		if (req->r_reassert_version.epoch)
 			seq_printf(s, "\t%u'%llu",
-			   (unsigned)le32_to_cpu(req->r_reassert_version.epoch),
+			   (unsigned int)le32_to_cpu(req->r_reassert_version.epoch),
 			   le64_to_cpu(req->r_reassert_version.version));
 		else
 			seq_printf(s, "\t");
diff --git a/net/ceph/messenger.c b/net/ceph/messenger.c
index f0993af..36fa6bf 100644
--- a/net/ceph/messenger.c
+++ b/net/ceph/messenger.c
@@ -699,7 +699,7 @@ static int prepare_write_connect(struct ceph_messenger *msgr,
 				 struct ceph_connection *con,
 				 int include_banner)
 {
-	unsigned global_seq = get_global_seq(con->msgr, 0);
+	unsigned int global_seq = get_global_seq(con->msgr, 0);
 	int proto;
 
 	switch (con->peer_name.type) {
@@ -816,7 +816,7 @@ static void iter_bio_next(struct bio **bio_iter, int *seg)
 static int write_partial_msg_pages(struct ceph_connection *con)
 {
 	struct ceph_msg *msg = con->out_msg;
-	unsigned data_len = le32_to_cpu(msg->hdr.data_len);
+	unsigned int data_len = le32_to_cpu(msg->hdr.data_len);
 	size_t len;
 	bool do_datacrc = !con->msgr->nocrc;
 	int ret;
@@ -1554,7 +1554,7 @@ static struct ceph_msg *ceph_alloc_msg(struct ceph_connection *con,
 
 static int read_partial_message_pages(struct ceph_connection *con,
 				      struct page **pages,
-				      unsigned data_len, bool do_datacrc)
+				      unsigned int data_len, bool do_datacrc)
 {
 	void *p;
 	int ret;
@@ -1587,7 +1587,7 @@ static int read_partial_message_pages(struct ceph_connection *con,
 #ifdef CONFIG_BLOCK
 static int read_partial_message_bio(struct ceph_connection *con,
 				    struct bio **bio_iter, int *bio_seg,
-				    unsigned data_len, bool do_datacrc)
+				    unsigned int data_len, bool do_datacrc)
 {
 	struct bio_vec *bv = bio_iovec_idx(*bio_iter, *bio_seg);
 	void *p;
@@ -1629,7 +1629,7 @@ static int read_partial_message(struct ceph_connection *con)
 	struct ceph_msg *m = con->in_msg;
 	int ret;
 	int to, left;
-	unsigned front_len, middle_len, data_len;
+	unsigned int front_len, middle_len, data_len;
 	bool do_datacrc = !con->msgr->nocrc;
 	int skip;
 	u64 seq;
@@ -2345,9 +2345,9 @@ void ceph_con_revoke_message(struct ceph_connection *con, struct ceph_msg *msg)
 {
 	mutex_lock(&con->mutex);
 	if (con->in_msg && con->in_msg == msg) {
-		unsigned front_len = le32_to_cpu(con->in_hdr.front_len);
-		unsigned middle_len = le32_to_cpu(con->in_hdr.middle_len);
-		unsigned data_len = le32_to_cpu(con->in_hdr.data_len);
+		unsigned int front_len = le32_to_cpu(con->in_hdr.front_len);
+		unsigned int middle_len = le32_to_cpu(con->in_hdr.middle_len);
+		unsigned int data_len = le32_to_cpu(con->in_hdr.data_len);
 
 		/* skip rest of message */
 		dout("con_revoke_pages %p msg %p revoked\n", con, msg);
diff --git a/net/ceph/mon_client.c b/net/ceph/mon_client.c
index 1845cde..10d6008 100644
--- a/net/ceph/mon_client.c
+++ b/net/ceph/mon_client.c
@@ -168,7 +168,7 @@ static bool __sub_expired(struct ceph_mon_client *monc)
  */
 static void __schedule_delayed(struct ceph_mon_client *monc)
 {
-	unsigned delay;
+	unsigned int delay;
 
 	if (monc->cur_mon < 0 || __sub_expired(monc))
 		delay = 10 * HZ;
@@ -184,7 +184,7 @@ static void __schedule_delayed(struct ceph_mon_client *monc)
 static void __send_subscribe(struct ceph_mon_client *monc)
 {
 	dout("__send_subscribe sub_sent=%u exp=%u want_osd=%d\n",
-	     (unsigned)monc->sub_sent, __sub_expired(monc),
+	     (unsigned int)monc->sub_sent, __sub_expired(monc),
 	     monc->want_next_osdmap);
 	if ((__sub_expired(monc) && !monc->sub_sent) ||
 	    monc->want_next_osdmap == 1) {
@@ -201,7 +201,7 @@ static void __send_subscribe(struct ceph_mon_client *monc)
 
 		if (monc->want_next_osdmap) {
 			dout("__send_subscribe to 'osdmap' %u\n",
-			     (unsigned)monc->have_osdmap);
+			     (unsigned int)monc->have_osdmap);
 			ceph_encode_string(&p, end, "osdmap", 6);
 			i = p;
 			i->have = cpu_to_le64(monc->have_osdmap);
@@ -211,7 +211,7 @@ static void __send_subscribe(struct ceph_mon_client *monc)
 		}
 		if (monc->want_mdsmap) {
 			dout("__send_subscribe to 'mdsmap' %u+\n",
-			     (unsigned)monc->have_mdsmap);
+			     (unsigned int)monc->have_mdsmap);
 			ceph_encode_string(&p, end, "mdsmap", 6);
 			i = p;
 			i->have = cpu_to_le64(monc->have_mdsmap);
@@ -236,7 +236,7 @@ static void __send_subscribe(struct ceph_mon_client *monc)
 static void handle_subscribe_ack(struct ceph_mon_client *monc,
 				 struct ceph_msg *msg)
 {
-	unsigned seconds;
+	unsigned int seconds;
 	struct ceph_mon_subscribe_ack *h = msg->front.iov_base;
 
 	if (msg->front.iov_len < sizeof(*h))
diff --git a/net/ceph/osd_client.c b/net/ceph/osd_client.c
index 5e25405..1b0ef3c 100644
--- a/net/ceph/osd_client.c
+++ b/net/ceph/osd_client.c
@@ -1214,7 +1214,7 @@ static void handle_reply(struct ceph_osd_client *osdc, struct ceph_msg *msg,
 	}
 
 	if (!req->r_got_reply) {
-		unsigned bytes;
+		unsigned int bytes;
 
 		req->r_result = le32_to_cpu(rhead->result);
 		bytes = le32_to_cpu(msg->hdr.data_len);
diff --git a/net/ceph/osdmap.c b/net/ceph/osdmap.c
index 29ad46e..56e561a 100644
--- a/net/ceph/osdmap.c
+++ b/net/ceph/osdmap.c
@@ -38,7 +38,7 @@ done:
 
 /* maps */
 
-static int calc_bits_of(unsigned t)
+static int calc_bits_of(unsigned int t)
 {
 	int b = 0;
 	while (t) {
@@ -154,7 +154,7 @@ static struct crush_map *crush_decode(void *pbyval, void *end)
 	magic = ceph_decode_32(p);
 	if (magic != CRUSH_MAGIC) {
 		pr_err("crush_decode magic %x != current %x\n",
-		       (unsigned)magic, (unsigned)CRUSH_MAGIC);
+		       (unsigned int)magic, (unsigned int)CRUSH_MAGIC);
 		goto bad;
 	}
 	c->max_buckets = ceph_decode_32(p);
@@ -460,7 +460,7 @@ static void __remove_pg_pool(struct rb_root *root, struct ceph_pg_pool_info *pi)
 
 static int __decode_pool(void **p, void *end, struct ceph_pg_pool_info *pi)
 {
-	unsigned n, m;
+	unsigned int n, m;
 
 	ceph_decode_copy(p, &pi->v, sizeof(pi->v));
 	calc_pg_masks(pi);
@@ -970,7 +970,7 @@ void ceph_calc_file_object_mapping(struct ceph_file_layout *layout,
 	objsetno = stripeno / su_per_object;
 
 	*ono = objsetno * sc + stripepos;
-	dout("objset %u * sc %u = ono %u\n", objsetno, sc, (unsigned)*ono);
+	dout("objset %u * sc %u = ono %u\n", objsetno, sc, (unsigned int)*ono);
 
 	/* *oxoff = *off % layout->fl_stripe_unit;  # offset in su */
 	t = off;
@@ -998,12 +998,12 @@ int ceph_calc_object_layout(struct ceph_object_layout *ol,
 			    struct ceph_file_layout *fl,
 			    struct ceph_osdmap *osdmap)
 {
-	unsigned num, num_mask;
+	unsigned int num, num_mask;
 	struct ceph_pg pgid;
 	s32 preferred = (s32)le32_to_cpu(fl->fl_pg_preferred);
 	int poolid = le32_to_cpu(fl->fl_pg_pool);
 	struct ceph_pg_pool_info *pool;
-	unsigned ps;
+	unsigned int ps;
 
 	BUG_ON(!osdmap);
 
@@ -1045,7 +1045,7 @@ static int *calc_pg_raw(struct ceph_osdmap *osdmap, struct ceph_pg pgid,
 	struct ceph_pg_mapping *pg;
 	struct ceph_pg_pool_info *pool;
 	int ruleno;
-	unsigned poolid, ps, pps, t;
+	unsigned int poolid, ps, pps, t;
 	int preferred;
 
 	poolid = le32_to_cpu(pgid.pool);
diff --git a/net/compat.c b/net/compat.c
index e055708..e240441 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -741,13 +741,13 @@ static unsigned char nas[21] = {
 };
 #undef AL
 
-asmlinkage long compat_sys_sendmsg(int fd, struct compat_msghdr __user *msg, unsigned flags)
+asmlinkage long compat_sys_sendmsg(int fd, struct compat_msghdr __user *msg, unsigned int flags)
 {
 	return sys_sendmsg(fd, (struct msghdr __user *)msg, flags | MSG_CMSG_COMPAT);
 }
 
 asmlinkage long compat_sys_sendmmsg(int fd, struct compat_mmsghdr __user *mmsg,
-				    unsigned vlen, unsigned int flags)
+				    unsigned int vlen, unsigned int flags)
 {
 	return __sys_sendmmsg(fd, (struct mmsghdr __user *)mmsg, vlen,
 			      flags | MSG_CMSG_COMPAT);
@@ -758,20 +758,20 @@ asmlinkage long compat_sys_recvmsg(int fd, struct compat_msghdr __user *msg, uns
 	return sys_recvmsg(fd, (struct msghdr __user *)msg, flags | MSG_CMSG_COMPAT);
 }
 
-asmlinkage long compat_sys_recv(int fd, void __user *buf, size_t len, unsigned flags)
+asmlinkage long compat_sys_recv(int fd, void __user *buf, size_t len, unsigned int flags)
 {
 	return sys_recv(fd, buf, len, flags | MSG_CMSG_COMPAT);
 }
 
 asmlinkage long compat_sys_recvfrom(int fd, void __user *buf, size_t len,
-				    unsigned flags, struct sockaddr __user *addr,
+				    unsigned int flags, struct sockaddr __user *addr,
 				    int __user *addrlen)
 {
 	return sys_recvfrom(fd, buf, len, flags | MSG_CMSG_COMPAT, addr, addrlen);
 }
 
 asmlinkage long compat_sys_recvmmsg(int fd, struct compat_mmsghdr __user *mmsg,
-				    unsigned vlen, unsigned int flags,
+				    unsigned int vlen, unsigned int flags,
 				    struct compat_timespec __user *timeout)
 {
 	int datagrams;
diff --git a/net/core/datagram.c b/net/core/datagram.c
index e4fbfd6..ae6acf6 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -65,7 +65,7 @@ static inline int connection_based(struct sock *sk)
 	return sk->sk_type == SOCK_SEQPACKET || sk->sk_type == SOCK_STREAM;
 }
 
-static int receiver_wake_function(wait_queue_t *wait, unsigned mode, int sync,
+static int receiver_wake_function(wait_queue_t *wait, unsigned int mode, int sync,
 				  void *key)
 {
 	unsigned long bits = (unsigned long)key;
@@ -158,7 +158,7 @@ out_noerr:
  *	quite explicitly by POSIX 1003.1g, don't change them without having
  *	the standard around please.
  */
-struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned flags,
+struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
 				    int *peeked, int *off, int *err)
 {
 	struct sk_buff *skb;
@@ -216,7 +216,7 @@ no_packet:
 }
 EXPORT_SYMBOL(__skb_recv_datagram);
 
-struct sk_buff *skb_recv_datagram(struct sock *sk, unsigned flags,
+struct sk_buff *skb_recv_datagram(struct sock *sk, unsigned int flags,
 				  int noblock, int *err)
 {
 	int peeked, off = 0;
diff --git a/net/core/dev.c b/net/core/dev.c
index 9bb8f87..c938127 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -208,7 +208,8 @@ static inline void dev_base_seq_inc(struct net *net)
 
 static inline struct hlist_head *dev_name_hash(struct net *net, const char *name)
 {
-	unsigned hash = full_name_hash(name, strnlen(name, IFNAMSIZ));
+	unsigned int hash = full_name_hash(name, strnlen(name, IFNAMSIZ));
+
 	return &net->dev_name_head[hash_32(hash, NETDEV_HASHBITS)];
 }
 
@@ -4618,9 +4619,9 @@ void dev_set_rx_mode(struct net_device *dev)
  *
  *	Get the combination of flag bits exported through APIs to userspace.
  */
-unsigned dev_get_flags(const struct net_device *dev)
+unsigned int dev_get_flags(const struct net_device *dev)
 {
-	unsigned flags;
+	unsigned int flags;
 
 	flags = (dev->flags & ~(IFF_PROMISC |
 				IFF_ALLMULTI |
diff --git a/net/core/filter.c b/net/core/filter.c
index 95d05a6..47a5f05 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -531,7 +531,7 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
 			 * Compare this with conditional jumps below,
 			 * where offsets are limited. --ANK (981016)
 			 */
-			if (ftest->k >= (unsigned)(flen-pc-1))
+			if (ftest->k >= (unsigned int)(flen-pc-1))
 				return -EINVAL;
 			break;
 		case BPF_S_JMP_JEQ_K:
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 2d3e6fc..434eed8 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -890,7 +890,7 @@ static void neigh_timer_handler(unsigned long arg)
 {
 	unsigned long now, next;
 	struct neighbour *neigh = (struct neighbour *)arg;
-	unsigned state;
+	unsigned int state;
 	int notify = 0;
 
 	write_lock(&neigh->lock);
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 97d0f24..fdf9e61 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -231,7 +231,7 @@ NETDEVICE_SHOW(flags, fmt_hex);
 
 static int change_flags(struct net_device *net, unsigned long new_flags)
 {
-	return dev_change_flags(net, (unsigned) new_flags);
+	return dev_change_flags(net, (unsigned int) new_flags);
 }
 
 static ssize_t store_flags(struct device *dev, struct device_attribute *attr,
@@ -581,7 +581,7 @@ static ssize_t store_rps_map(struct netdev_rx_queue *queue,
 		return err;
 	}
 
-	map = kzalloc(max_t(unsigned,
+	map = kzalloc(max_t(unsigned int,
 	    RPS_MAP_SIZE(cpumask_weight(mask)), L1_CACHE_BYTES),
 	    GFP_KERNEL);
 	if (!map) {
@@ -902,7 +902,7 @@ static ssize_t bql_set_hold_time(struct netdev_queue *queue,
 				 const char *buf, size_t len)
 {
 	struct dql *dql = &queue->dql;
-	unsigned value;
+	unsigned int value;
 	int err;
 
 	err = kstrtouint(buf, 10, &value);
@@ -1106,7 +1106,7 @@ static ssize_t store_xps_map(struct netdev_queue *queue,
 		return err;
 	}
 
-	new_dev_maps = kzalloc(max_t(unsigned,
+	new_dev_maps = kzalloc(max_t(unsigned int,
 	    XPS_DEV_MAPS_SIZE, L1_CACHE_BYTES), GFP_KERNEL);
 	if (!new_dev_maps) {
 		free_cpumask_var(mask);
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 4d8ce93..ffb5d38 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -320,7 +320,7 @@ struct pktgen_dev {
 				(see RFC 3260, sec. 4) */
 
 	/* MPLS */
-	unsigned nr_labels;	/* Depth of stack, 0 = no MPLS */
+	unsigned int nr_labels;	/* Depth of stack, 0 = no MPLS */
 	__be32 labels[MAX_MPLS_LABELS];
 
 	/* VLAN/SVLAN (802.1Q/Q-in-Q) */
@@ -373,10 +373,10 @@ struct pktgen_dev {
 				  */
 	char odevname[32];
 	struct flow_state *flows;
-	unsigned cflows;	/* Concurrent flows (config) */
-	unsigned lflow;		/* Flow length  (config) */
-	unsigned nflows;	/* accumulated flows (stats) */
-	unsigned curfl;		/* current sequenced flow (state)*/
+	unsigned int cflows;	/* Concurrent flows (config) */
+	unsigned int lflow;		/* Flow length  (config) */
+	unsigned int nflows;	/* accumulated flows (stats) */
+	unsigned int curfl;		/* current sequenced flow (state)*/
 
 	u16 queue_map_min;
 	u16 queue_map_max;
@@ -592,7 +592,7 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
 		   pkt_dev->src_mac_count, pkt_dev->dst_mac_count);
 
 	if (pkt_dev->nr_labels) {
-		unsigned i;
+		unsigned int i;
 		seq_printf(seq, "     mpls: ");
 		for (i = 0; i < pkt_dev->nr_labels; i++)
 			seq_printf(seq, "%08x%s", ntohl(pkt_dev->labels[i]),
@@ -812,7 +812,7 @@ done_str:
 
 static ssize_t get_labels(const char __user *buffer, struct pktgen_dev *pkt_dev)
 {
-	unsigned n = 0;
+	unsigned int n = 0;
 	char c;
 	ssize_t i = 0;
 	int len;
@@ -1510,7 +1510,7 @@ static ssize_t pktgen_if_write(struct file *file,
 	}
 
 	if (!strcmp(name, "mpls")) {
-		unsigned n, cnt;
+		unsigned int n, cnt;
 
 		len = get_labels(&user_buffer[i], pkt_dev);
 		if (len < 0)
@@ -2324,7 +2324,7 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 	}
 
 	if (pkt_dev->flags & F_MPLS_RND) {
-		unsigned i;
+		unsigned int i;
 		for (i = 0; i < pkt_dev->nr_labels; i++)
 			if (pkt_dev->labels[i] & MPLS_STACK_BOTTOM)
 				pkt_dev->labels[i] = MPLS_STACK_BOTTOM |
@@ -2550,7 +2550,7 @@ err:
 
 static void mpls_push(__be32 *mpls, struct pktgen_dev *pkt_dev)
 {
-	unsigned i;
+	unsigned int i;
 	for (i = 0; i < pkt_dev->nr_labels; i++)
 		*mpls++ = pkt_dev->labels[i] & ~MPLS_STACK_BOTTOM;
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 4a0d8cf..2ff6fe4 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -552,7 +552,7 @@ void __rta_fill(struct sk_buff *skb, int attrtype, int attrlen, const void *data
 }
 EXPORT_SYMBOL(__rta_fill);
 
-int rtnetlink_send(struct sk_buff *skb, struct net *net, u32 pid, unsigned group, int echo)
+int rtnetlink_send(struct sk_buff *skb, struct net *net, u32 pid, unsigned int group, int echo)
 {
 	struct sock *rtnl = net->rtnl;
 	int err = 0;
@@ -1953,7 +1953,7 @@ static int rtnl_dump_all(struct sk_buff *skb, struct netlink_callback *cb)
 	return skb->len;
 }
 
-void rtmsg_ifinfo(int type, struct net_device *dev, unsigned change)
+void rtmsg_ifinfo(int type, struct net_device *dev, unsigned int change)
 {
 	struct net *net = dev_net(dev);
 	struct sk_buff *skb;
@@ -2048,7 +2048,7 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		struct rtattr *attr = (void *)nlh + NLMSG_ALIGN(min_len);
 
 		while (RTA_OK(attr, attrlen)) {
-			unsigned flavor = attr->rta_type;
+			unsigned int flavor = attr->rta_type;
 			if (flavor) {
 				if (flavor > rta_max[sz_idx])
 					return -EINVAL;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 35b3a68..8f0d68d 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3166,7 +3166,7 @@ int sock_queue_err_skb(struct sock *sk, struct sk_buff *skb)
 	int len = skb->len;
 
 	if (atomic_read(&sk->sk_rmem_alloc) + skb->truesize >=
-	    (unsigned)sk->sk_rcvbuf)
+	    (unsigned int)sk->sk_rcvbuf)
 		return -ENOMEM;
 
 	skb_orphan(skb);
diff --git a/net/core/sock.c b/net/core/sock.c
index b2e14c0..c7e60ea 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1534,7 +1534,7 @@ struct sk_buff *sock_rmalloc(struct sock *sk, unsigned long size, int force,
  */
 void *sock_kmalloc(struct sock *sk, int size, gfp_t priority)
 {
-	if ((unsigned)size <= sysctl_optmem_max &&
+	if ((unsigned int)size <= sysctl_optmem_max &&
 	    atomic_read(&sk->sk_omem_alloc) + size < sysctl_optmem_max) {
 		void *mem;
 		/* First do the add, to avoid the race if kmalloc
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 70bfaf2..8c67bed 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -100,7 +100,7 @@ static void ccid3_update_send_interval(struct ccid3_hc_tx_sock *hc)
 
 	DCCP_BUG_ON(hc->tx_t_ipi == 0);
 	ccid3_pr_debug("t_ipi=%u, s=%u, X=%u\n", hc->tx_t_ipi,
-		       hc->tx_s, (unsigned)(hc->tx_x >> 6));
+		       hc->tx_s, (unsigned int)(hc->tx_x >> 6));
 }
 
 static u32 ccid3_hc_tx_idle_rtt(struct ccid3_hc_tx_sock *hc, ktime_t now)
@@ -153,9 +153,9 @@ static void ccid3_hc_tx_update_x(struct sock *sk, ktime_t *stamp)
 
 	if (hc->tx_x != old_x) {
 		ccid3_pr_debug("X_prev=%u, X_now=%u, X_calc=%u, "
-			       "X_recv=%u\n", (unsigned)(old_x >> 6),
-			       (unsigned)(hc->tx_x >> 6), hc->tx_x_calc,
-			       (unsigned)(hc->tx_x_recv >> 6));
+			       "X_recv=%u\n", (unsigned int)(old_x >> 6),
+			       (unsigned int)(hc->tx_x >> 6), hc->tx_x_calc,
+			       (unsigned int)(hc->tx_x_recv >> 6));
 
 		ccid3_update_send_interval(hc);
 	}
@@ -425,8 +425,8 @@ done_computing_x:
 			       "p=%u, X_calc=%u, X_recv=%u, X=%u\n",
 			       dccp_role(sk), sk, hc->tx_rtt, r_sample,
 			       hc->tx_s, hc->tx_p, hc->tx_x_calc,
-			       (unsigned)(hc->tx_x_recv >> 6),
-			       (unsigned)(hc->tx_x >> 6));
+			       (unsigned int)(hc->tx_x_recv >> 6),
+			       (unsigned int)(hc->tx_x >> 6));
 
 	/* unschedule no feedback timer */
 	sk_stop_timer(sk, &hc->tx_no_feedback_timer);
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 29d6bb6..9040be0 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -75,7 +75,7 @@ extern void dccp_time_wait(struct sock *sk, int state, int timeo);
 				     * state, about 60 seconds */
 
 /* RFC 1122, 4.2.3.1 initial RTO value */
-#define DCCP_TIMEOUT_INIT ((unsigned)(3 * HZ))
+#define DCCP_TIMEOUT_INIT ((unsigned int)(3 * HZ))
 
 /*
  * The maximum back-off value for retransmissions. This is needed for
@@ -84,7 +84,7 @@ extern void dccp_time_wait(struct sock *sk, int state, int timeo);
  *  - feature-negotiation retransmission (sec. 6.6.3),
  *  - Acks in client-PARTOPEN state (sec. 8.1.5).
  */
-#define DCCP_RTO_MAX ((unsigned)(64 * HZ))
+#define DCCP_RTO_MAX ((unsigned int)(64 * HZ))
 
 /*
  * RTT sampling: sanity bounds and fallback RTT value from RFC 4340, section 3.4
@@ -287,9 +287,9 @@ extern struct sock *dccp_check_req(struct sock *sk, struct sk_buff *skb,
 extern int dccp_child_process(struct sock *parent, struct sock *child,
 			      struct sk_buff *skb);
 extern int dccp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
-				  struct dccp_hdr *dh, unsigned len);
+				  struct dccp_hdr *dh, unsigned int len);
 extern int dccp_rcv_established(struct sock *sk, struct sk_buff *skb,
-				const struct dccp_hdr *dh, const unsigned len);
+				const struct dccp_hdr *dh, const unsigned int len);
 
 extern int dccp_init_sock(struct sock *sk, const __u8 ctl_sock_initialized);
 extern void dccp_destroy_sock(struct sock *sk);
diff --git a/net/dccp/input.c b/net/dccp/input.c
index 51d5fe5..bc93a33 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -285,7 +285,7 @@ static int dccp_check_seqno(struct sock *sk, struct sk_buff *skb)
 }
 
 static int __dccp_rcv_established(struct sock *sk, struct sk_buff *skb,
-				  const struct dccp_hdr *dh, const unsigned len)
+				  const struct dccp_hdr *dh, const unsigned int len)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 
@@ -366,7 +366,7 @@ discard:
 }
 
 int dccp_rcv_established(struct sock *sk, struct sk_buff *skb,
-			 const struct dccp_hdr *dh, const unsigned len)
+			 const struct dccp_hdr *dh, const unsigned int len)
 {
 	if (dccp_check_seqno(sk, skb))
 		goto discard;
@@ -388,7 +388,7 @@ EXPORT_SYMBOL_GPL(dccp_rcv_established);
 static int dccp_rcv_request_sent_state_process(struct sock *sk,
 					       struct sk_buff *skb,
 					       const struct dccp_hdr *dh,
-					       const unsigned len)
+					       const unsigned int len)
 {
 	/*
 	 *  Step 4: Prepare sequence numbers in REQUEST
@@ -521,7 +521,7 @@ unable_to_proceed:
 static int dccp_rcv_respond_partopen_state_process(struct sock *sk,
 						   struct sk_buff *skb,
 						   const struct dccp_hdr *dh,
-						   const unsigned len)
+						   const unsigned int len)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	u32 sample = dp->dccps_options_received.dccpor_timestamp_echo;
@@ -572,7 +572,7 @@ static int dccp_rcv_respond_partopen_state_process(struct sock *sk,
 }
 
 int dccp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
-			   struct dccp_hdr *dh, unsigned len)
+			   struct dccp_hdr *dh, unsigned int len)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct dccp_skb_cb *dcb = DCCP_SKB_CB(skb);
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 4136987..2ba1a28 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -250,7 +250,7 @@ static void dn_unhash_sock_bh(struct sock *sk)
 static struct hlist_head *listen_hash(struct sockaddr_dn *addr)
 {
 	int i;
-	unsigned hash = addr->sdn_objnum;
+	unsigned int hash = addr->sdn_objnum;
 
 	if (hash == 0) {
 		hash = addr->sdn_objnamel;
@@ -1844,9 +1844,9 @@ static inline int dn_queue_too_long(struct dn_scp *scp, struct sk_buff_head *que
  * inclusion (or not) of the two 16 bit acknowledgement fields so it doesn't
  * make much practical difference.
  */
-unsigned dn_mss_from_pmtu(struct net_device *dev, int mtu)
+unsigned int dn_mss_from_pmtu(struct net_device *dev, int mtu)
 {
-	unsigned mss = 230 - DN_MAX_NSP_DATA_HEADER;
+	unsigned int mss = 230 - DN_MAX_NSP_DATA_HEADER;
 	if (dev) {
 		struct dn_dev *dn_db = rcu_dereference_raw(dev->dn_ptr);
 		mtu -= LL_RESERVED_SPACE(dev);
diff --git a/net/decnet/dn_fib.c b/net/decnet/dn_fib.c
index 9e885f1..65a8cd7 100644
--- a/net/decnet/dn_fib.c
+++ b/net/decnet/dn_fib.c
@@ -302,11 +302,12 @@ struct dn_fib_info *dn_fib_create_info(const struct rtmsg *r, struct dn_kern_rta
 		struct rtattr *attr = RTA_DATA(rta->rta_mx);
 
 		while(RTA_OK(attr, attrlen)) {
-			unsigned flavour = attr->rta_type;
+			unsigned int flavour = attr->rta_type;
+
 			if (flavour) {
 				if (flavour > RTAX_MAX)
 					goto err_inval;
-				fi->fib_metrics[flavour-1] = *(unsigned*)RTA_DATA(attr);
+				fi->fib_metrics[flavour-1] = *(unsigned int *)RTA_DATA(attr);
 			}
 			attr = RTA_NEXT(attr, attrlen);
 		}
diff --git a/net/decnet/dn_nsp_in.c b/net/decnet/dn_nsp_in.c
index f6544b2..58084f3 100644
--- a/net/decnet/dn_nsp_in.c
+++ b/net/decnet/dn_nsp_in.c
@@ -588,7 +588,7 @@ static __inline__ int dn_queue_skb(struct sock *sk, struct sk_buff *skb, int sig
 	   number of warnings when compiling with -W --ANK
 	 */
 	if (atomic_read(&sk->sk_rmem_alloc) + skb->truesize >=
-	    (unsigned)sk->sk_rcvbuf) {
+	    (unsigned int)sk->sk_rcvbuf) {
 		err = -ENOMEM;
 		goto out;
 	}
diff --git a/net/decnet/dn_nsp_out.c b/net/decnet/dn_nsp_out.c
index e446e85..b952f88 100644
--- a/net/decnet/dn_nsp_out.c
+++ b/net/decnet/dn_nsp_out.c
@@ -209,7 +209,7 @@ static void dn_nsp_rtt(struct sock *sk, long rtt)
  *
  * Returns: The number of times the packet has been sent previously
  */
-static inline unsigned dn_nsp_clone_and_send(struct sk_buff *skb,
+static inline unsigned int dn_nsp_clone_and_send(struct sk_buff *skb,
 					     gfp_t gfp)
 {
 	struct dn_skb_cb *cb = DN_SKB_CB(skb);
@@ -240,7 +240,7 @@ void dn_nsp_output(struct sock *sk)
 {
 	struct dn_scp *scp = DN_SK(sk);
 	struct sk_buff *skb;
-	unsigned reduce_win = 0;
+	unsigned int reduce_win = 0;
 
 	/*
 	 * First we check for otherdata/linkservice messages
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 80a3de4..7e1f878 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -122,7 +122,7 @@ static int dn_route_input(struct sk_buff *);
 static void dn_run_flush(unsigned long dummy);
 
 static struct dn_rt_hash_bucket *dn_rt_hash_table;
-static unsigned dn_rt_hash_mask;
+static unsigned int dn_rt_hash_mask;
 
 static struct timer_list dn_route_timer;
 static DEFINE_TIMER(dn_rt_flush_timer, dn_run_flush, 0, 0);
@@ -149,13 +149,13 @@ static void dn_dst_destroy(struct dst_entry *dst)
 	dst_destroy_metrics_generic(dst);
 }
 
-static __inline__ unsigned dn_hash(__le16 src, __le16 dst)
+static __inline__ unsigned int dn_hash(__le16 src, __le16 dst)
 {
 	__u16 tmp = (__u16 __force)(src ^ dst);
 	tmp ^= (tmp >> 3);
 	tmp ^= (tmp >> 5);
 	tmp ^= (tmp >> 10);
-	return dn_rt_hash_mask & (unsigned)tmp;
+	return dn_rt_hash_mask & (unsigned int)tmp;
 }
 
 static inline void dnrt_free(struct dn_route *rt)
@@ -297,7 +297,7 @@ static inline int compare_keys(struct flowidn *fl1, struct flowidn *fl2)
 		(fl1->flowidn_iif ^ fl2->flowidn_iif)) == 0;
 }
 
-static int dn_insert_route(struct dn_route *rt, unsigned hash, struct dn_route **rp)
+static int dn_insert_route(struct dn_route *rt, unsigned int hash, struct dn_route **rp)
 {
 	struct dn_route *rth;
 	struct dn_route __rcu **rthp;
@@ -934,8 +934,8 @@ static int dn_route_output_slow(struct dst_entry **pprt, const struct flowidn *o
 	struct dn_route *rt = NULL;
 	struct net_device *dev_out = NULL, *dev;
 	struct neighbour *neigh = NULL;
-	unsigned hash;
-	unsigned flags = 0;
+	unsigned int hash;
+	unsigned int flags = 0;
 	struct dn_fib_res res = { .fi = NULL, .type = RTN_UNICAST };
 	int err;
 	int free_res = 0;
@@ -1209,7 +1209,7 @@ e_neighbour:
  */
 static int __dn_route_output_key(struct dst_entry **pprt, const struct flowidn *flp, int flags)
 {
-	unsigned hash = dn_hash(flp->saddr, flp->daddr);
+	unsigned int hash = dn_hash(flp->saddr, flp->daddr);
 	struct dn_route *rt = NULL;
 
 	if (!(flags & MSG_TRYHARD)) {
@@ -1275,7 +1275,7 @@ static int dn_route_input_slow(struct sk_buff *skb)
 	struct net_device *out_dev = NULL;
 	struct dn_dev *dn_db;
 	struct neighbour *neigh = NULL;
-	unsigned hash;
+	unsigned int hash;
 	int flags = 0;
 	__le16 gateway = 0;
 	__le16 local_src = 0;
@@ -1490,7 +1490,7 @@ static int dn_route_input(struct sk_buff *skb)
 {
 	struct dn_route *rt;
 	struct dn_skb_cb *cb = DN_SKB_CB(skb);
-	unsigned hash = dn_hash(cb->src, cb->dst);
+	unsigned int hash = dn_hash(cb->src, cb->dst);
 
 	if (skb_dst(skb))
 		return 0;
diff --git a/net/decnet/dn_rules.c b/net/decnet/dn_rules.c
index 7399e3d..e65f2c8 100644
--- a/net/decnet/dn_rules.c
+++ b/net/decnet/dn_rules.c
@@ -177,11 +177,11 @@ static int dn_fib_rule_compare(struct fib_rule *rule, struct fib_rule_hdr *frh,
 	return 1;
 }
 
-unsigned dnet_addr_type(__le16 addr)
+unsigned int dnet_addr_type(__le16 addr)
 {
 	struct flowidn fld = { .daddr = addr };
 	struct dn_fib_res res;
-	unsigned ret = RTN_UNICAST;
+	unsigned int ret = RTN_UNICAST;
 	struct dn_fib_table *tb = dn_fib_get_table(RT_TABLE_LOCAL, 0);
 
 	res.r = NULL;
diff --git a/net/dns_resolver/dns_key.c b/net/dns_resolver/dns_key.c
index c73bba3..6f70ea9 100644
--- a/net/dns_resolver/dns_key.c
+++ b/net/dns_resolver/dns_key.c
@@ -38,7 +38,7 @@ MODULE_DESCRIPTION("DNS Resolver");
 MODULE_AUTHOR("Wang Lei");
 MODULE_LICENSE("GPL");
 
-unsigned dns_resolver_debug;
+unsigned int dns_resolver_debug;
 module_param_named(debug, dns_resolver_debug, uint, S_IWUSR | S_IRUGO);
 MODULE_PARM_DESC(debug, "DNS Resolver debugging mask");
 
diff --git a/net/dns_resolver/internal.h b/net/dns_resolver/internal.h
index 189ca9e..17c7886 100644
--- a/net/dns_resolver/internal.h
+++ b/net/dns_resolver/internal.h
@@ -31,7 +31,7 @@ extern const struct cred *dns_resolver_cache;
 /*
  * debug tracing
  */
-extern unsigned dns_resolver_debug;
+extern unsigned int dns_resolver_debug;
 
 #define	kdebug(FMT, ...)				\
 do {							\
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index bf10a31..5889a6c 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -77,7 +77,7 @@ __setup("ether=", netdev_boot_setup);
  */
 int eth_header(struct sk_buff *skb, struct net_device *dev,
 	       unsigned short type,
-	       const void *daddr, const void *saddr, unsigned len)
+	       const void *daddr, const void *saddr, unsigned int len)
 {
 	struct ethhdr *eth = (struct ethhdr *)skb_push(skb, ETH_HLEN);
 
diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 3685158..58c8895 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -371,7 +371,7 @@ err:
 static int lowpan_header_create(struct sk_buff *skb,
 			   struct net_device *dev,
 			   unsigned short type, const void *_daddr,
-			   const void *_saddr, unsigned len)
+			   const void *_saddr, unsigned int len)
 {
 	u8 tmp, iphc0, iphc1, *hc06_ptr;
 	struct ipv6hdr *hdr;
diff --git a/net/ieee802154/dgram.c b/net/ieee802154/dgram.c
index 1b09eaa..6fbb2ad 100644
--- a/net/ieee802154/dgram.c
+++ b/net/ieee802154/dgram.c
@@ -44,8 +44,8 @@ struct dgram_sock {
 	struct ieee802154_addr src_addr;
 	struct ieee802154_addr dst_addr;
 
-	unsigned bound:1;
-	unsigned want_ack:1;
+	unsigned int bound:1;
+	unsigned int want_ack:1;
 };
 
 static inline struct dgram_sock *dgram_sk(const struct sock *sk)
@@ -206,7 +206,7 @@ static int dgram_sendmsg(struct kiocb *iocb, struct sock *sk,
 		struct msghdr *msg, size_t size)
 {
 	struct net_device *dev;
-	unsigned mtu;
+	unsigned int mtu;
 	struct sk_buff *skb;
 	struct dgram_sock *ro = dgram_sk(sk);
 	int hlen, tlen;
diff --git a/net/ieee802154/raw.c b/net/ieee802154/raw.c
index f96bae8..50e8239 100644
--- a/net/ieee802154/raw.c
+++ b/net/ieee802154/raw.c
@@ -106,7 +106,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		       size_t size)
 {
 	struct net_device *dev;
-	unsigned mtu;
+	unsigned int mtu;
 	struct sk_buff *skb;
 	int hlen, tlen;
 	int err;
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 18d9b81..373b56b 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1059,7 +1059,7 @@ static int arp_req_set(struct net *net, struct arpreq *r,
 	neigh = __neigh_lookup_errno(&arp_tbl, &ip, dev);
 	err = PTR_ERR(neigh);
 	if (!IS_ERR(neigh)) {
-		unsigned state = NUD_STALE;
+		unsigned int state = NUD_STALE;
 		if (r->arp_flags & ATF_PERM)
 			state = NUD_PERMANENT;
 		err = neigh_update(neigh, (r->arp_flags & ATF_COM) ?
@@ -1071,7 +1071,7 @@ static int arp_req_set(struct net *net, struct arpreq *r,
 	return err;
 }
 
-static unsigned arp_state_to_flags(struct neighbour *neigh)
+static unsigned int arp_state_to_flags(struct neighbour *neigh)
 {
 	if (neigh->nud_state&NUD_PERMANENT)
 		return ATF_PERM | ATF_COM;
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 7ba2196..8a01bfb 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1125,7 +1125,7 @@ skip:
 	}
 }
 
-static inline bool inetdev_valid_mtu(unsigned mtu)
+static inline bool inetdev_valid_mtu(unsigned int mtu)
 {
 	return mtu >= 68;
 }
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index cbe3a68..3854411 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -136,13 +136,13 @@ static void fib_flush(struct net *net)
  * Find address type as if only "dev" was present in the system. If
  * on_dev is NULL then all interfaces are taken into consideration.
  */
-static inline unsigned __inet_dev_addr_type(struct net *net,
-					    const struct net_device *dev,
-					    __be32 addr)
+static inline unsigned int __inet_dev_addr_type(struct net *net,
+						const struct net_device *dev,
+						__be32 addr)
 {
 	struct flowi4		fl4 = { .daddr = addr };
 	struct fib_result	res;
-	unsigned ret = RTN_BROADCAST;
+	unsigned int ret = RTN_BROADCAST;
 	struct fib_table *local_table;
 
 	if (ipv4_is_zeronet(addr) || ipv4_is_lbcast(addr))
@@ -740,7 +740,7 @@ void fib_del_ifaddr(struct in_ifaddr *ifa, struct in_ifaddr *iprim)
 #define BRD_OK		2
 #define BRD0_OK		4
 #define BRD1_OK		8
-	unsigned ok = 0;
+	unsigned int ok = 0;
 	int subnet = 0;		/* Primary network */
 	int gone = 1;		/* Address is missing */
 	int same_prefsrc = 0;	/* Another primary with same IP */
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 14409f1..7d972f6 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -42,7 +42,8 @@ EXPORT_SYMBOL(sysctl_local_reserved_ports);
 
 void inet_get_local_port_range(int *low, int *high)
 {
-	unsigned seq;
+	unsigned int seq;
+
 	do {
 		seq = read_seqbegin(&sysctl_local_ports.lock);
 
diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index 89168c6..543ef62 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -263,7 +263,7 @@ rescan:
 void inet_twdr_hangman(unsigned long data)
 {
 	struct inet_timewait_death_row *twdr;
-	int unsigned need_timer;
+	unsigned int need_timer;
 
 	twdr = (struct inet_timewait_death_row *)data;
 	spin_lock(&twdr->death_lock);
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index a0d0d9d..a1f6447 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -413,7 +413,7 @@ int ip_options_compile(struct net *net,
 					opt->is_changed = 1;
 				}
 			} else {
-				unsigned overflow = optptr[3]>>4;
+				unsigned int overflow = optptr[3]>>4;
 				if (overflow == 15) {
 					pp_ptr = optptr + 3;
 					goto error;
@@ -473,20 +473,22 @@ EXPORT_SYMBOL(ip_options_compile);
  *	Undo all the changes done by ip_options_compile().
  */
 
-void ip_options_undo(struct ip_options * opt)
+void ip_options_undo(struct ip_options *opt)
 {
 	if (opt->srr) {
-		unsigned  char * optptr = opt->__data+opt->srr-sizeof(struct  iphdr);
+		unsigned char *optptr = opt->__data+opt->srr-sizeof(struct iphdr);
 		memmove(optptr+7, optptr+3, optptr[1]-7);
 		memcpy(optptr+3, &opt->faddr, 4);
 	}
 	if (opt->rr_needaddr) {
-		unsigned  char * optptr = opt->__data+opt->rr-sizeof(struct  iphdr);
+		unsigned char *optptr = opt->__data+opt->rr-sizeof(struct iphdr);
+
 		optptr[2] -= 4;
 		memset(&optptr[optptr[2]-1], 0, 4);
 	}
 	if (opt->ts) {
-		unsigned  char * optptr = opt->__data+opt->ts-sizeof(struct  iphdr);
+		unsigned char *optptr = opt->__data+opt->ts-sizeof(struct iphdr);
+
 		if (opt->ts_needtime) {
 			optptr[2] -= 4;
 			memset(&optptr[optptr[2]-1], 0, 4);
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 2fd0fba..955e8a7 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -147,7 +147,7 @@ static void ip_cmsg_recv_dstaddr(struct msghdr *msg, struct sk_buff *skb)
 void ip_cmsg_recv(struct msghdr *msg, struct sk_buff *skb)
 {
 	struct inet_sock *inet = inet_sk(skb->sk);
-	unsigned flags = inet->cmsg_flags;
+	unsigned int flags = inet->cmsg_flags;
 
 	/* Ordered by supposed usage frequency */
 	if (flags & 1)
@@ -1094,7 +1094,7 @@ EXPORT_SYMBOL(compat_ip_setsockopt);
  */
 
 static int do_ip_getsockopt(struct sock *sk, int level, int optname,
-			    char __user *optval, int __user *optlen, unsigned flags)
+			    char __user *optval, int __user *optlen, unsigned int flags)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	int val;
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 92ac7e7..f267280 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -1198,7 +1198,7 @@ static int __init ic_dynamic(void)
 	d = ic_first_dev;
 	retries = CONF_SEND_RETRIES;
 	get_random_bytes(&timeout, sizeof(timeout));
-	timeout = CONF_BASE_TIMEOUT + (timeout % (unsigned) CONF_TIMEOUT_RANDOM);
+	timeout = CONF_BASE_TIMEOUT + (timeout % (unsigned int) CONF_TIMEOUT_RANDOM);
 	for (;;) {
 		/* Track the device we are configuring */
 		ic_dev_xid = d->xid;
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index 4f47e06..3cd8c58 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -12,7 +12,7 @@
 #include <net/netfilter/nf_queue.h>
 
 /* route_me_harder function, used by iptable_nat, iptable_mangle + ip_queue */
-int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
+int ip_route_me_harder(struct sk_buff *skb, unsigned int addr_type)
 {
 	struct net *net = dev_net(skb_dst(skb)->dev);
 	const struct iphdr *iph = ip_hdr(skb);
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index fd7a3f6..a393527 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -303,7 +303,7 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 			if (v < 0) {
 				/* Pop from stack? */
 				if (v != XT_RETURN) {
-					verdict = (unsigned)(-v) - 1;
+					verdict = (unsigned int)(-v) - 1;
 					break;
 				}
 				e = back;
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 24e556e..585b80f 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -377,7 +377,7 @@ ipt_do_table(struct sk_buff *skb,
 			if (v < 0) {
 				/* Pop from stack? */
 				if (v != XT_RETURN) {
-					verdict = (unsigned)(-v) - 1;
+					verdict = (unsigned int)(-v) - 1;
 					break;
 				}
 				if (*stackptr <= origptr) {
diff --git a/net/ipv4/netfilter/nf_nat_sip.c b/net/ipv4/netfilter/nf_nat_sip.c
index 57932c4..ea4a238 100644
--- a/net/ipv4/netfilter/nf_nat_sip.c
+++ b/net/ipv4/netfilter/nf_nat_sip.c
@@ -283,7 +283,7 @@ static unsigned int ip_nat_sip_expect(struct sk_buff *skb, unsigned int dataoff,
 	__be32 newip;
 	u_int16_t port;
 	char buffer[sizeof("nnn.nnn.nnn.nnn:nnnnn")];
-	unsigned buflen;
+	unsigned int buflen;
 
 	/* Connection will come from reply */
 	if (ct->tuplehash[dir].tuple.src.u3.ip == ct->tuplehash[!dir].tuple.dst.u3.ip)
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 50009c7..485c6ac 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -51,15 +51,16 @@ static struct ping_table ping_table;
 
 static u16 ping_port_rover;
 
-static inline int ping_hashfn(struct net *net, unsigned num, unsigned mask)
+static inline int ping_hashfn(struct net *net, unsigned int num, unsigned int mask)
 {
 	int res = (num + net_hash_mix(net)) & mask;
+
 	pr_debug("hash(%d) = %d\n", num, res);
 	return res;
 }
 
 static inline struct hlist_nulls_head *ping_hashslot(struct ping_table *table,
-					     struct net *net, unsigned num)
+					     struct net *net, unsigned int num)
 {
 	return &table->hash[ping_hashfn(net, num, PING_HTABLE_MASK)];
 }
@@ -188,7 +189,8 @@ static void inet_get_ping_group_range_net(struct net *net, gid_t *low,
 					  gid_t *high)
 {
 	gid_t *data = net->ipv4.sysctl_ping_group_range;
-	unsigned seq;
+	unsigned int seq;
+
 	do {
 		seq = read_seqbegin(&sysctl_local_ports.lock);
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index e4d18f2..cdde4fb 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -296,7 +296,7 @@ static inline void rt_hash_lock_init(void)
 #endif
 
 static struct rt_hash_bucket 	*rt_hash_table __read_mostly;
-static unsigned			rt_hash_mask __read_mostly;
+static unsigned int		rt_hash_mask __read_mostly;
 static unsigned int		rt_hash_log  __read_mostly;
 
 static DEFINE_PER_CPU(struct rt_cache_stat, rt_cache_stat);
@@ -1143,7 +1143,7 @@ static int rt_bind_neighbour(struct rtable *rt)
 	return 0;
 }
 
-static struct rtable *rt_intern_hash(unsigned hash, struct rtable *rt,
+static struct rtable *rt_intern_hash(unsigned int hash, struct rtable *rt,
 				     struct sk_buff *skb, int ifindex)
 {
 	struct rtable	*rth, *cand;
@@ -1384,7 +1384,7 @@ void __ip_select_ident(struct iphdr *iph, struct dst_entry *dst, int more)
 }
 EXPORT_SYMBOL(__ip_select_ident);
 
-static void rt_del(unsigned hash, struct rtable *rt)
+static void rt_del(unsigned int hash, struct rtable *rt)
 {
 	struct rtable __rcu **rthp;
 	struct rtable *aux;
@@ -1538,7 +1538,7 @@ static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst)
 			ip_rt_put(rt);
 			ret = NULL;
 		} else if (rt->rt_flags & RTCF_REDIRECTED) {
-			unsigned hash = rt_hash(rt->rt_key_dst, rt->rt_key_src,
+			unsigned int hash = rt_hash(rt->rt_key_dst, rt->rt_key_src,
 						rt->rt_oif,
 						rt_genid(dev_net(dst->dev)));
 			rt_del(hash, rt);
@@ -2217,7 +2217,7 @@ static int ip_mkroute_input(struct sk_buff *skb,
 {
 	struct rtable* rth = NULL;
 	int err;
-	unsigned hash;
+	unsigned int hash;
 
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	if (res->fi && res->fi->fib_nhs > 1)
@@ -2255,10 +2255,10 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	struct fib_result res;
 	struct in_device *in_dev = __in_dev_get_rcu(dev);
 	struct flowi4	fl4;
-	unsigned	flags = 0;
+	unsigned int	flags = 0;
 	u32		itag = 0;
 	struct rtable * rth;
-	unsigned	hash;
+	unsigned int	hash;
 	__be32		spec_dst;
 	int		err = -EINVAL;
 	struct net    * net = dev_net(dev);
@@ -2434,7 +2434,7 @@ int ip_route_input_common(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 			   u8 tos, struct net_device *dev, bool noref)
 {
 	struct rtable * rth;
-	unsigned	hash;
+	unsigned int	hash;
 	int iif = dev->ifindex;
 	struct net *net;
 	int res;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 7a7724d..34a6286 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -78,7 +78,7 @@ static int ipv4_local_port_range(ctl_table *table, int write,
 static void inet_get_ping_group_range_table(struct ctl_table *table, gid_t *low, gid_t *high)
 {
 	gid_t *data = table->data;
-	unsigned seq;
+	unsigned int seq;
 	do {
 		seq = read_seqbegin(&sysctl_local_ports.lock);
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 8bb6ade..c53e8a8 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2675,7 +2675,7 @@ struct sk_buff *tcp_tso_segment(struct sk_buff *skb,
 {
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
 	struct tcphdr *th;
-	unsigned thlen;
+	unsigned int thlen;
 	unsigned int seq;
 	__be32 delta;
 	unsigned int oldlen;
@@ -3033,9 +3033,9 @@ int tcp_md5_hash_skb_data(struct tcp_md5sig_pool *hp,
 	struct scatterlist sg;
 	const struct tcphdr *tp = tcp_hdr(skb);
 	struct hash_desc *desc = &hp->md5_desc;
-	unsigned i;
-	const unsigned head_data_len = skb_headlen(skb) > header_len ?
-				       skb_headlen(skb) - header_len : 0;
+	unsigned int i;
+	const unsigned int head_data_len = skb_headlen(skb) > header_len ?
+					   skb_headlen(skb) - header_len : 0;
 	const struct skb_shared_info *shi = skb_shinfo(skb);
 	struct sk_buff *frag_iter;
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 3dc94fe..99448f0 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -175,7 +175,7 @@ static void tcp_measure_rcv_mss(struct sock *sk, const struct sk_buff *skb)
 static void tcp_incr_quickack(struct sock *sk)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
-	unsigned quickacks = tcp_sk(sk)->rcv_wnd / (2 * icsk->icsk_ack.rcv_mss);
+	unsigned int quickacks = tcp_sk(sk)->rcv_wnd / (2 * icsk->icsk_ack.rcv_mss);
 
 	if (quickacks == 0)
 		quickacks = 2;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 376b2cf..de8790c 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -563,13 +563,13 @@ static void tcp_options_write(__be32 *ptr, struct tcp_sock *tp,
 /* Compute TCP options for SYN packets. This is not the final
  * network wire format yet.
  */
-static unsigned tcp_syn_options(struct sock *sk, struct sk_buff *skb,
+static unsigned int tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 				struct tcp_out_options *opts,
 				struct tcp_md5sig_key **md5)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_cookie_values *cvp = tp->cookie_values;
-	unsigned remaining = MAX_TCP_OPTION_SPACE;
+	unsigned int remaining = MAX_TCP_OPTION_SPACE;
 	u8 cookie_size = (!tp->rx_opt.cookie_out_never && cvp != NULL) ?
 			 tcp_cookie_size_check(cvp->cookie_desired) :
 			 0;
@@ -663,15 +663,15 @@ static unsigned tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 }
 
 /* Set up TCP options for SYN-ACKs. */
-static unsigned tcp_synack_options(struct sock *sk,
+static unsigned int tcp_synack_options(struct sock *sk,
 				   struct request_sock *req,
-				   unsigned mss, struct sk_buff *skb,
+				   unsigned int mss, struct sk_buff *skb,
 				   struct tcp_out_options *opts,
 				   struct tcp_md5sig_key **md5,
 				   struct tcp_extend_values *xvp)
 {
 	struct inet_request_sock *ireq = inet_rsk(req);
-	unsigned remaining = MAX_TCP_OPTION_SPACE;
+	unsigned int remaining = MAX_TCP_OPTION_SPACE;
 	u8 cookie_plus = (xvp != NULL && !xvp->cookie_out_never) ?
 			 xvp->cookie_plus :
 			 0;
@@ -742,13 +742,13 @@ static unsigned tcp_synack_options(struct sock *sk,
 /* Compute TCP options for ESTABLISHED sockets. This is not the
  * final wire format yet.
  */
-static unsigned tcp_established_options(struct sock *sk, struct sk_buff *skb,
+static unsigned int tcp_established_options(struct sock *sk, struct sk_buff *skb,
 					struct tcp_out_options *opts,
 					struct tcp_md5sig_key **md5)
 {
 	struct tcp_skb_cb *tcb = skb ? TCP_SKB_CB(skb) : NULL;
 	struct tcp_sock *tp = tcp_sk(sk);
-	unsigned size = 0;
+	unsigned int size = 0;
 	unsigned int eff_sacks;
 
 #ifdef CONFIG_TCP_MD5SIG
@@ -770,9 +770,9 @@ static unsigned tcp_established_options(struct sock *sk, struct sk_buff *skb,
 
 	eff_sacks = tp->rx_opt.num_sacks + tp->rx_opt.dsack;
 	if (unlikely(eff_sacks)) {
-		const unsigned remaining = MAX_TCP_OPTION_SPACE - size;
+		const unsigned int remaining = MAX_TCP_OPTION_SPACE - size;
 		opts->num_sack_blocks =
-			min_t(unsigned, eff_sacks,
+			min_t(unsigned int, eff_sacks,
 			      (remaining - TCPOLEN_SACK_BASE_ALIGNED) /
 			      TCPOLEN_SACK_PERBLOCK);
 		size += TCPOLEN_SACK_BASE_ALIGNED +
@@ -801,7 +801,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	struct tcp_sock *tp;
 	struct tcp_skb_cb *tcb;
 	struct tcp_out_options opts;
-	unsigned tcp_options_size, tcp_header_size;
+	unsigned int tcp_options_size, tcp_header_size;
 	struct tcp_md5sig_key *md5;
 	struct tcphdr *th;
 	int err;
@@ -1258,7 +1258,7 @@ unsigned int tcp_current_mss(struct sock *sk)
 	const struct tcp_sock *tp = tcp_sk(sk);
 	const struct dst_entry *dst = __sk_dst_get(sk);
 	u32 mss_now;
-	unsigned header_len;
+	unsigned int header_len;
 	struct tcp_out_options opts;
 	struct tcp_md5sig_key *md5;
 
@@ -1389,7 +1389,7 @@ static inline int tcp_minshall_check(const struct tcp_sock *tp)
  */
 static inline int tcp_nagle_check(const struct tcp_sock *tp,
 				  const struct sk_buff *skb,
-				  unsigned mss_now, int nonagle)
+				  unsigned int mss_now, int nonagle)
 {
 	return skb->len < mss_now &&
 		((nonagle & TCP_NAGLE_CORK) ||
diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
index a981cdc..85118ae 100644
--- a/net/ipv4/tcp_probe.c
+++ b/net/ipv4/tcp_probe.c
@@ -91,7 +91,7 @@ static inline int tcp_probe_avail(void)
  * Note: arguments must match tcp_rcv_established()!
  */
 static int jtcp_rcv_established(struct sock *sk, struct sk_buff *skb,
-			       struct tcphdr *th, unsigned len)
+			       struct tcphdr *th, unsigned int len)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 	const struct inet_sock *inet = inet_sk(sk);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index ad1e0dd..0e7f9a0 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -207,7 +207,7 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 
 	if (!snum) {
 		int low, high, remaining;
-		unsigned rand;
+		unsigned int rand;
 		unsigned short first, last;
 		DECLARE_BITMAP(bitmap, PORTS_PER_CHAIN);
 
diff --git a/net/ipv6/addrconf_core.c b/net/ipv6/addrconf_core.c
index 7981bde..d051e5f 100644
--- a/net/ipv6/addrconf_core.c
+++ b/net/ipv6/addrconf_core.c
@@ -8,7 +8,7 @@
 
 #define IPV6_ADDR_SCOPE_TYPE(scope)	((scope) << 16)
 
-static inline unsigned ipv6_addr_scope2type(unsigned scope)
+static inline unsigned int ipv6_addr_scope2type(unsigned int scope)
 {
 	switch (scope) {
 	case IPV6_ADDR_SCOPE_NODELOCAL:
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index f6210d6..7fba35a 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -515,7 +515,7 @@ int datagram_recv_ctl(struct sock *sk, struct msghdr *msg, struct sk_buff *skb)
 		u8 nexthdr = ipv6_hdr(skb)->nexthdr;
 
 		while (off <= opt->lastopt) {
-			unsigned len;
+			unsigned int len;
 			u8 *ptr = nh + off;
 
 			switch (nexthdr) {
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index b7867a1..1dd6329 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -705,9 +705,9 @@ static int ip6fl_seq_show(struct seq_file *seq, void *v)
 		struct ip6_flowlabel *fl = v;
 		seq_printf(seq,
 			   "%05X %-1d %-6d %-6d %-6ld %-8ld %pi6 %-4d\n",
-			   (unsigned)ntohl(fl->label),
+			   (unsigned int)ntohl(fl->label),
 			   fl->share,
-			   (unsigned)fl->owner,
+			   (int)fl->owner,
 			   atomic_read(&fl->users),
 			   fl->linger/HZ,
 			   (long)(fl->expires - jiffies)/HZ,
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index aa21da6..e25b0fd 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -198,7 +198,7 @@ ip6_tnl_bucket(struct ip6_tnl_net *ip6n, const struct ip6_tnl_parm *p)
 {
 	const struct in6_addr *remote = &p->raddr;
 	const struct in6_addr *local = &p->laddr;
-	unsigned h = 0;
+	unsigned int h = 0;
 	int prio = 0;
 
 	if (!ipv6_addr_any(remote) || !ipv6_addr_any(local)) {
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index ca1af07..ba6d13d 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -942,7 +942,7 @@ static int ipv6_getsockopt_sticky(struct sock *sk, struct ipv6_txoptions *opt,
 }
 
 static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
-		    char __user *optval, int __user *optlen, unsigned flags)
+		    char __user *optval, int __user *optlen, unsigned int flags)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	int len;
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 9d4e155..d4e350f 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -396,7 +396,7 @@ ip6t_do_table(struct sk_buff *skb,
 			if (v < 0) {
 				/* Pop from stack? */
 				if (v != XT_RETURN) {
-					verdict = (unsigned)(-v) - 1;
+					verdict = (unsigned int)(-v) - 1;
 					break;
 				}
 				if (*stackptr <= origptr)
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 8c5df6f..f910cce 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -82,7 +82,7 @@ static void		ip6_rt_update_pmtu(struct dst_entry *dst, u32 mtu);
 static struct rt6_info *rt6_add_route_info(struct net *net,
 					   const struct in6_addr *prefix, int prefixlen,
 					   const struct in6_addr *gwaddr, int ifindex,
-					   unsigned pref);
+					   unsigned int pref);
 static struct rt6_info *rt6_get_route_info(struct net *net,
 					   const struct in6_addr *prefix, int prefixlen,
 					   const struct in6_addr *gwaddr, int ifindex);
@@ -1870,7 +1870,7 @@ out:
 static struct rt6_info *rt6_add_route_info(struct net *net,
 					   const struct in6_addr *prefix, int prefixlen,
 					   const struct in6_addr *gwaddr, int ifindex,
-					   unsigned pref)
+					   unsigned int pref)
 {
 	struct fib6_config cfg = {
 		.fc_table	= RT6_TABLE_INFO,
@@ -2200,10 +2200,9 @@ void rt6_ifdown(struct net *net, struct net_device *dev)
 	icmp6_clean_all(fib6_ifdown, &adn);
 }
 
-struct rt6_mtu_change_arg
-{
+struct rt6_mtu_change_arg {
 	struct net_device *dev;
-	unsigned mtu;
+	unsigned int mtu;
 };
 
 static int rt6_mtu_change_route(struct rt6_info *rt, void *p_arg)
@@ -2245,7 +2244,7 @@ static int rt6_mtu_change_route(struct rt6_info *rt, void *p_arg)
 	return 0;
 }
 
-void rt6_mtu_change(struct net_device *dev, unsigned mtu)
+void rt6_mtu_change(struct net_device *dev, unsigned int mtu)
 {
 	struct rt6_mtu_change_arg arg = {
 		.dev = dev,
diff --git a/net/ipv6/xfrm6_tunnel.c b/net/ipv6/xfrm6_tunnel.c
index 4fe1db12..ee5a706 100644
--- a/net/ipv6/xfrm6_tunnel.c
+++ b/net/ipv6/xfrm6_tunnel.c
@@ -68,9 +68,9 @@ static DEFINE_SPINLOCK(xfrm6_tunnel_spi_lock);
 
 static struct kmem_cache *xfrm6_tunnel_spi_kmem __read_mostly;
 
-static inline unsigned xfrm6_tunnel_spi_hash_byaddr(const xfrm_address_t *addr)
+static inline unsigned int xfrm6_tunnel_spi_hash_byaddr(const xfrm_address_t *addr)
 {
-	unsigned h;
+	unsigned int h;
 
 	h = (__force u32)(addr->a6[0] ^ addr->a6[1] ^ addr->a6[2] ^ addr->a6[3]);
 	h ^= h >> 16;
@@ -80,7 +80,7 @@ static inline unsigned xfrm6_tunnel_spi_hash_byaddr(const xfrm_address_t *addr)
 	return h;
 }
 
-static inline unsigned xfrm6_tunnel_spi_hash_byspi(u32 spi)
+static inline unsigned int xfrm6_tunnel_spi_hash_byspi(u32 spi)
 {
 	return spi % XFRM6_TUNNEL_SPI_BYSPI_HSIZE;
 }
diff --git a/net/irda/ircomm/ircomm_tty_ioctl.c b/net/irda/ircomm/ircomm_tty_ioctl.c
index 77c5e64..d0667d6 100644
--- a/net/irda/ircomm/ircomm_tty_ioctl.c
+++ b/net/irda/ircomm/ircomm_tty_ioctl.c
@@ -54,7 +54,7 @@
  */
 static void ircomm_tty_change_speed(struct ircomm_tty_cb *self)
 {
-	unsigned cflag, cval;
+	unsigned int cflag, cval;
 	int baud;
 
 	IRDA_DEBUG(2, "%s()\n", __func__ );
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 7e5d927..34e4185 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1714,7 +1714,7 @@ static int key_notify_sa_flush(const struct km_event *c)
 static int pfkey_flush(struct sock *sk, struct sk_buff *skb, const struct sadb_msg *hdr, void * const *ext_hdrs)
 {
 	struct net *net = sock_net(sk);
-	unsigned proto;
+	unsigned int proto;
 	struct km_event c;
 	struct xfrm_audit audit_info;
 	int err, err2;
@@ -3547,7 +3547,7 @@ static int pfkey_sendmsg(struct kiocb *kiocb,
 		goto out;
 
 	err = -EMSGSIZE;
-	if ((unsigned)len > sk->sk_sndbuf - 32)
+	if ((unsigned int)len > sk->sk_sndbuf - 32)
 		goto out;
 
 	err = -ENOBUFS;
diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
index a16a48e..09e4a38 100644
--- a/net/l2tp/l2tp_core.h
+++ b/net/l2tp/l2tp_core.h
@@ -54,15 +54,15 @@ struct l2tp_tunnel;
  */
 struct l2tp_session_cfg {
 	enum l2tp_pwtype	pw_type;
-	unsigned		data_seq:2;	/* data sequencing level
+	unsigned int		data_seq:2;	/* data sequencing level
 						 * 0 => none, 1 => IP only,
 						 * 2 => all
 						 */
-	unsigned		recv_seq:1;	/* expect receive packets with
+	unsigned int		recv_seq:1;	/* expect receive packets with
 						 * sequence numbers? */
-	unsigned		send_seq:1;	/* send packets with sequence
+	unsigned int		send_seq:1;	/* send packets with sequence
 						 * numbers? */
-	unsigned		lns_mode:1;	/* behave as LNS? LAC enables
+	unsigned int		lns_mode:1;	/* behave as LNS? LAC enables
 						 * sequence numbers under
 						 * control of LNS. */
 	int			debug;		/* bitmask of debug message
@@ -107,15 +107,15 @@ struct l2tp_session {
 
 	char			name[32];	/* for logging */
 	char			ifname[IFNAMSIZ];
-	unsigned		data_seq:2;	/* data sequencing level
+	unsigned int		data_seq:2;	/* data sequencing level
 						 * 0 => none, 1 => IP only,
 						 * 2 => all
 						 */
-	unsigned		recv_seq:1;	/* expect receive packets with
+	unsigned int		recv_seq:1;	/* expect receive packets with
 						 * sequence numbers? */
-	unsigned		send_seq:1;	/* send packets with sequence
+	unsigned int		send_seq:1;	/* send packets with sequence
 						 * numbers? */
-	unsigned		lns_mode:1;	/* behave as LNS? LAC enables
+	unsigned int		lns_mode:1;	/* behave as LNS? LAC enables
 						 * sequence numbers under
 						 * control of LNS. */
 	int			debug;		/* bitmask of debug message
diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index b9bef2c..17bc85d 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -518,7 +518,7 @@ static int llc_ui_listen(struct socket *sock, int backlog)
 	if (sock_flag(sk, SOCK_ZAPPED))
 		goto out;
 	rc = 0;
-	if (!(unsigned)backlog)	/* BSDism */
+	if (!(unsigned int)backlog)	/* BSDism */
 		backlog = 1;
 	sk->sk_max_ack_backlog = backlog;
 	if (sk->sk_state != TCP_LISTEN) {
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index eb66b97..819c342 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -1618,7 +1618,7 @@ static struct nfnetlink_subsystem ip_set_netlink_subsys __read_mostly = {
 static int
 ip_set_sockfn_get(struct sock *sk, int optval, void __user *user, int *len)
 {
-	unsigned *op;
+	unsigned int *op;
 	void *data;
 	int copylen = *len, ret = 0;
 
@@ -1626,7 +1626,7 @@ ip_set_sockfn_get(struct sock *sk, int optval, void __user *user, int *len)
 		return -EPERM;
 	if (optval != SO_IP_SET)
 		return -EBADF;
-	if (*len < sizeof(unsigned))
+	if (*len < sizeof(unsigned int))
 		return -EINVAL;
 
 	data = vmalloc(*len);
@@ -1636,7 +1636,7 @@ ip_set_sockfn_get(struct sock *sk, int optval, void __user *user, int *len)
 		ret = -EFAULT;
 		goto done;
 	}
-	op = (unsigned *) data;
+	op = (unsigned int *) data;
 
 	if (*op < IP_SET_OP_VERSION) {
 		/* Check the version at the beginning of operations */
diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
index 5285617..64f9e8f 100644
--- a/net/netfilter/ipvs/ip_vs_app.c
+++ b/net/netfilter/ipvs/ip_vs_app.c
@@ -313,7 +313,7 @@ vs_fix_ack_seq(const struct ip_vs_seq *vseq, struct tcphdr *th)
  *	Assumes already checked proto==IPPROTO_TCP and diff!=0.
  */
 static inline void vs_seq_update(struct ip_vs_conn *cp, struct ip_vs_seq *vseq,
-				 unsigned flag, __u32 seq, int diff)
+				 unsigned int flag, __u32 seq, int diff)
 {
 	/* spinlock is to keep updating cp->flags atomic */
 	spin_lock(&cp->lock);
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 29fa5ba..4a09b78 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -86,42 +86,42 @@ struct ip_vs_aligned_lock
 static struct ip_vs_aligned_lock
 __ip_vs_conntbl_lock_array[CT_LOCKARRAY_SIZE] __cacheline_aligned;
 
-static inline void ct_read_lock(unsigned key)
+static inline void ct_read_lock(unsigned int key)
 {
 	read_lock(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
 }
 
-static inline void ct_read_unlock(unsigned key)
+static inline void ct_read_unlock(unsigned int key)
 {
 	read_unlock(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
 }
 
-static inline void ct_write_lock(unsigned key)
+static inline void ct_write_lock(unsigned int key)
 {
 	write_lock(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
 }
 
-static inline void ct_write_unlock(unsigned key)
+static inline void ct_write_unlock(unsigned int key)
 {
 	write_unlock(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
 }
 
-static inline void ct_read_lock_bh(unsigned key)
+static inline void ct_read_lock_bh(unsigned int key)
 {
 	read_lock_bh(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
 }
 
-static inline void ct_read_unlock_bh(unsigned key)
+static inline void ct_read_unlock_bh(unsigned int key)
 {
 	read_unlock_bh(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
 }
 
-static inline void ct_write_lock_bh(unsigned key)
+static inline void ct_write_lock_bh(unsigned int key)
 {
 	write_lock_bh(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
 }
 
-static inline void ct_write_unlock_bh(unsigned key)
+static inline void ct_write_unlock_bh(unsigned int key)
 {
 	write_unlock_bh(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
 }
@@ -130,7 +130,7 @@ static inline void ct_write_unlock_bh(unsigned key)
 /*
  *	Returns hash value for IPVS connection entry
  */
-static unsigned int ip_vs_conn_hashkey(struct net *net, int af, unsigned proto,
+static unsigned int ip_vs_conn_hashkey(struct net *net, int af, unsigned int proto,
 				       const union nf_inet_addr *addr,
 				       __be16 port)
 {
@@ -188,7 +188,7 @@ static unsigned int ip_vs_conn_hashkey_conn(const struct ip_vs_conn *cp)
  */
 static inline int ip_vs_conn_hash(struct ip_vs_conn *cp)
 {
-	unsigned hash;
+	unsigned int hash;
 	int ret;
 
 	if (cp->flags & IP_VS_CONN_F_ONE_PACKET)
@@ -224,7 +224,7 @@ static inline int ip_vs_conn_hash(struct ip_vs_conn *cp)
  */
 static inline int ip_vs_conn_unhash(struct ip_vs_conn *cp)
 {
-	unsigned hash;
+	unsigned int hash;
 	int ret;
 
 	/* unhash it and decrease its reference counter */
@@ -257,7 +257,7 @@ static inline int ip_vs_conn_unhash(struct ip_vs_conn *cp)
 static inline struct ip_vs_conn *
 __ip_vs_conn_in_get(const struct ip_vs_conn_param *p)
 {
-	unsigned hash;
+	unsigned int hash;
 	struct ip_vs_conn *cp;
 	struct hlist_node *n;
 
@@ -344,7 +344,7 @@ EXPORT_SYMBOL_GPL(ip_vs_conn_in_get_proto);
 /* Get reference to connection template */
 struct ip_vs_conn *ip_vs_ct_in_get(const struct ip_vs_conn_param *p)
 {
-	unsigned hash;
+	unsigned int hash;
 	struct ip_vs_conn *cp;
 	struct hlist_node *n;
 
@@ -394,7 +394,7 @@ struct ip_vs_conn *ip_vs_ct_in_get(const struct ip_vs_conn_param *p)
  *	p->vaddr, p->vport: pkt dest address (foreign host) */
 struct ip_vs_conn *ip_vs_conn_out_get(const struct ip_vs_conn_param *p)
 {
-	unsigned hash;
+	unsigned int hash;
 	struct ip_vs_conn *cp, *ret=NULL;
 	struct hlist_node *n;
 
@@ -824,7 +824,7 @@ void ip_vs_conn_expire_now(struct ip_vs_conn *cp)
  */
 struct ip_vs_conn *
 ip_vs_conn_new(const struct ip_vs_conn_param *p,
-	       const union nf_inet_addr *daddr, __be16 dport, unsigned flags,
+	       const union nf_inet_addr *daddr, __be16 dport, unsigned int flags,
 	       struct ip_vs_dest *dest, __u32 fwmark)
 {
 	struct ip_vs_conn *cp;
@@ -1057,7 +1057,7 @@ static const struct file_operations ip_vs_conn_fops = {
 	.release = seq_release_net,
 };
 
-static const char *ip_vs_origin_name(unsigned flags)
+static const char *ip_vs_origin_name(unsigned int flags)
 {
 	if (flags & IP_VS_CONN_F_SYNC)
 		return "SYNC";
@@ -1169,7 +1169,7 @@ void ip_vs_random_dropentry(struct net *net)
 	 * Randomly scan 1/32 of the whole table every second
 	 */
 	for (idx = 0; idx < (ip_vs_conn_tab_size>>5); idx++) {
-		unsigned hash = net_random() & ip_vs_conn_tab_mask;
+		unsigned int hash = net_random() & ip_vs_conn_tab_mask;
 		struct hlist_node *n;
 
 		/*
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 2555816..b5a5c73 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -80,7 +80,7 @@ static atomic_t ipvs_netns_cnt = ATOMIC_INIT(0);
 #define icmp_id(icmph)          (((icmph)->un).echo.id)
 #define icmpv6_id(icmph)        (icmph->icmp6_dataun.u_echo.identifier)
 
-const char *ip_vs_proto_name(unsigned proto)
+const char *ip_vs_proto_name(unsigned int proto)
 {
 	static char buf[20];
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 964d426..b8d0df7 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -265,11 +265,11 @@ static struct list_head ip_vs_svc_fwm_table[IP_VS_SVC_TAB_SIZE];
 /*
  *	Returns hash value for virtual service
  */
-static inline unsigned
-ip_vs_svc_hashkey(struct net *net, int af, unsigned proto,
+static inline unsigned int
+ip_vs_svc_hashkey(struct net *net, int af, unsigned int proto,
 		  const union nf_inet_addr *addr, __be16 port)
 {
-	register unsigned porth = ntohs(port);
+	register unsigned int porth = ntohs(port);
 	__be32 addr_fold = addr->ip;
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -286,7 +286,7 @@ ip_vs_svc_hashkey(struct net *net, int af, unsigned proto,
 /*
  *	Returns hash value of fwmark for virtual service lookup
  */
-static inline unsigned ip_vs_svc_fwm_hashkey(struct net *net, __u32 fwmark)
+static inline unsigned int ip_vs_svc_fwm_hashkey(struct net *net, __u32 fwmark)
 {
 	return (((size_t)net>>8) ^ fwmark) & IP_VS_SVC_TAB_MASK;
 }
@@ -298,7 +298,7 @@ static inline unsigned ip_vs_svc_fwm_hashkey(struct net *net, __u32 fwmark)
  */
 static int ip_vs_svc_hash(struct ip_vs_service *svc)
 {
-	unsigned hash;
+	unsigned int hash;
 
 	if (svc->flags & IP_VS_SVC_F_HASHED) {
 		pr_err("%s(): request for already hashed, called from %pF\n",
@@ -361,7 +361,7 @@ static inline struct ip_vs_service *
 __ip_vs_service_find(struct net *net, int af, __u16 protocol,
 		     const union nf_inet_addr *vaddr, __be16 vport)
 {
-	unsigned hash;
+	unsigned int hash;
 	struct ip_vs_service *svc;
 
 	/* Check for "full" addressed entries */
@@ -388,7 +388,7 @@ __ip_vs_service_find(struct net *net, int af, __u16 protocol,
 static inline struct ip_vs_service *
 __ip_vs_svc_fwm_find(struct net *net, int af, __u32 fwmark)
 {
-	unsigned hash;
+	unsigned int hash;
 	struct ip_vs_service *svc;
 
 	/* Check for fwmark addressed entries */
@@ -489,11 +489,11 @@ __ip_vs_unbind_svc(struct ip_vs_dest *dest)
 /*
  *	Returns hash value for real service
  */
-static inline unsigned ip_vs_rs_hashkey(int af,
+static inline unsigned int ip_vs_rs_hashkey(int af,
 					    const union nf_inet_addr *addr,
 					    __be16 port)
 {
-	register unsigned porth = ntohs(port);
+	register unsigned int porth = ntohs(port);
 	__be32 addr_fold = addr->ip;
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -512,7 +512,7 @@ static inline unsigned ip_vs_rs_hashkey(int af,
  */
 static int ip_vs_rs_hash(struct netns_ipvs *ipvs, struct ip_vs_dest *dest)
 {
-	unsigned hash;
+	unsigned int hash;
 
 	if (!list_empty(&dest->d_list)) {
 		return 0;
@@ -555,7 +555,7 @@ ip_vs_lookup_real_service(struct net *net, int af, __u16 protocol,
 			  __be16 dport)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
-	unsigned hash;
+	unsigned int hash;
 	struct ip_vs_dest *dest;
 
 	/*
@@ -842,7 +842,7 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
 	       struct ip_vs_dest **dest_p)
 {
 	struct ip_vs_dest *dest;
-	unsigned atype;
+	unsigned int atype;
 
 	EnterFunction(2);
 
@@ -1867,7 +1867,7 @@ struct ip_vs_iter {
  *	Write the contents of the VS rule table to a PROCfs file.
  *	(It is kept just for backward compatibility)
  */
-static inline const char *ip_vs_fwd_name(unsigned flags)
+static inline const char *ip_vs_fwd_name(unsigned int flags)
 {
 	switch (flags & IP_VS_CONN_F_FWD_MASK) {
 	case IP_VS_CONN_F_LOCALNODE:
diff --git a/net/netfilter/ipvs/ip_vs_dh.c b/net/netfilter/ipvs/ip_vs_dh.c
index 1c269e5..1a53a7a 100644
--- a/net/netfilter/ipvs/ip_vs_dh.c
+++ b/net/netfilter/ipvs/ip_vs_dh.c
@@ -68,7 +68,7 @@ struct ip_vs_dh_bucket {
 /*
  *	Returns hash value for IPVS DH entry
  */
-static inline unsigned ip_vs_dh_hashkey(int af, const union nf_inet_addr *addr)
+static inline unsigned int ip_vs_dh_hashkey(int af, const union nf_inet_addr *addr)
 {
 	__be32 addr_fold = addr->ip;
 
diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 538d74e..debb8c7 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -177,7 +177,7 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 	__be16 port;
 	struct ip_vs_conn *n_cp;
 	char buf[24];		/* xxx.xxx.xxx.xxx,ppp,ppp\000 */
-	unsigned buf_len;
+	unsigned int buf_len;
 	int ret = 0;
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct;
diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 0f16283..27c24f1 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -142,7 +142,7 @@ static inline void ip_vs_lblc_free(struct ip_vs_lblc_entry *en)
 /*
  *	Returns hash value for IPVS LBLC entry
  */
-static inline unsigned
+static inline unsigned int
 ip_vs_lblc_hashkey(int af, const union nf_inet_addr *addr)
 {
 	__be32 addr_fold = addr->ip;
@@ -163,7 +163,7 @@ ip_vs_lblc_hashkey(int af, const union nf_inet_addr *addr)
 static void
 ip_vs_lblc_hash(struct ip_vs_lblc_table *tbl, struct ip_vs_lblc_entry *en)
 {
-	unsigned hash = ip_vs_lblc_hashkey(en->af, &en->addr);
+	unsigned int hash = ip_vs_lblc_hashkey(en->af, &en->addr);
 
 	list_add(&en->list, &tbl->bucket[hash]);
 	atomic_inc(&tbl->entries);
@@ -178,7 +178,7 @@ static inline struct ip_vs_lblc_entry *
 ip_vs_lblc_get(int af, struct ip_vs_lblc_table *tbl,
 	       const union nf_inet_addr *addr)
 {
-	unsigned hash = ip_vs_lblc_hashkey(af, addr);
+	unsigned int hash = ip_vs_lblc_hashkey(af, addr);
 	struct ip_vs_lblc_entry *en;
 
 	list_for_each_entry(en, &tbl->bucket[hash], list)
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index eec797f..7498756 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -311,7 +311,7 @@ static inline void ip_vs_lblcr_free(struct ip_vs_lblcr_entry *en)
 /*
  *	Returns hash value for IPVS LBLCR entry
  */
-static inline unsigned
+static inline unsigned int
 ip_vs_lblcr_hashkey(int af, const union nf_inet_addr *addr)
 {
 	__be32 addr_fold = addr->ip;
@@ -332,7 +332,7 @@ ip_vs_lblcr_hashkey(int af, const union nf_inet_addr *addr)
 static void
 ip_vs_lblcr_hash(struct ip_vs_lblcr_table *tbl, struct ip_vs_lblcr_entry *en)
 {
-	unsigned hash = ip_vs_lblcr_hashkey(en->af, &en->addr);
+	unsigned int hash = ip_vs_lblcr_hashkey(en->af, &en->addr);
 
 	list_add(&en->list, &tbl->bucket[hash]);
 	atomic_inc(&tbl->entries);
@@ -347,7 +347,7 @@ static inline struct ip_vs_lblcr_entry *
 ip_vs_lblcr_get(int af, struct ip_vs_lblcr_table *tbl,
 		const union nf_inet_addr *addr)
 {
-	unsigned hash = ip_vs_lblcr_hashkey(af, addr);
+	unsigned int hash = ip_vs_lblcr_hashkey(af, addr);
 	struct ip_vs_lblcr_entry *en;
 
 	list_for_each_entry(en, &tbl->bucket[hash], list)
diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index f843a88..6eda11d 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -48,7 +48,7 @@ static struct ip_vs_protocol *ip_vs_proto_table[IP_VS_PROTO_TAB_SIZE];
  */
 static int __used __init register_ip_vs_protocol(struct ip_vs_protocol *pp)
 {
-	unsigned hash = IP_VS_PROTO_HASH(pp->protocol);
+	unsigned int hash = IP_VS_PROTO_HASH(pp->protocol);
 
 	pp->next = ip_vs_proto_table[hash];
 	ip_vs_proto_table[hash] = pp;
@@ -69,7 +69,7 @@ static int
 register_ip_vs_proto_netns(struct net *net, struct ip_vs_protocol *pp)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
-	unsigned hash = IP_VS_PROTO_HASH(pp->protocol);
+	unsigned int hash = IP_VS_PROTO_HASH(pp->protocol);
 	struct ip_vs_proto_data *pd =
 			kzalloc(sizeof(struct ip_vs_proto_data), GFP_ATOMIC);
 
@@ -94,7 +94,7 @@ register_ip_vs_proto_netns(struct net *net, struct ip_vs_protocol *pp)
 static int unregister_ip_vs_protocol(struct ip_vs_protocol *pp)
 {
 	struct ip_vs_protocol **pp_p;
-	unsigned hash = IP_VS_PROTO_HASH(pp->protocol);
+	unsigned int hash = IP_VS_PROTO_HASH(pp->protocol);
 
 	pp_p = &ip_vs_proto_table[hash];
 	for (; *pp_p; pp_p = &(*pp_p)->next) {
@@ -117,7 +117,7 @@ unregister_ip_vs_proto_netns(struct net *net, struct ip_vs_proto_data *pd)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_proto_data **pd_p;
-	unsigned hash = IP_VS_PROTO_HASH(pd->pp->protocol);
+	unsigned int hash = IP_VS_PROTO_HASH(pd->pp->protocol);
 
 	pd_p = &ipvs->proto_data_table[hash];
 	for (; *pd_p; pd_p = &(*pd_p)->next) {
@@ -139,7 +139,7 @@ unregister_ip_vs_proto_netns(struct net *net, struct ip_vs_proto_data *pd)
 struct ip_vs_protocol * ip_vs_proto_get(unsigned short proto)
 {
 	struct ip_vs_protocol *pp;
-	unsigned hash = IP_VS_PROTO_HASH(proto);
+	unsigned int hash = IP_VS_PROTO_HASH(proto);
 
 	for (pp = ip_vs_proto_table[hash]; pp; pp = pp->next) {
 		if (pp->protocol == proto)
@@ -157,7 +157,7 @@ struct ip_vs_proto_data *
 __ipvs_proto_data_get(struct netns_ipvs *ipvs, unsigned short proto)
 {
 	struct ip_vs_proto_data *pd;
-	unsigned hash = IP_VS_PROTO_HASH(proto);
+	unsigned int hash = IP_VS_PROTO_HASH(proto);
 
 	for (pd = ipvs->proto_data_table[hash]; pd; pd = pd->next) {
 		if (pd->pp->protocol == proto)
diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
index 069e8d4..91e97ee 100644
--- a/net/netfilter/ipvs/ip_vs_sh.c
+++ b/net/netfilter/ipvs/ip_vs_sh.c
@@ -70,7 +70,7 @@ struct ip_vs_sh_bucket {
 /*
  *	Returns hash value for IPVS SH entry
  */
-static inline unsigned ip_vs_sh_hashkey(int af, const union nf_inet_addr *addr)
+static inline unsigned int ip_vs_sh_hashkey(int af, const union nf_inet_addr *addr)
 {
 	__be32 addr_fold = addr->ip;
 
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 8a0d6d6..f4e0b6c 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -839,7 +839,7 @@ static void ip_vs_process_message_v0(struct net *net, const char *buffer,
 
 	p = (char *)buffer + sizeof(struct ip_vs_sync_mesg_v0);
 	for (i=0; i<m->nr_conns; i++) {
-		unsigned flags, state;
+		unsigned int flags, state;
 
 		if (p + SIMPLE_CONN_SIZE > buffer+buflen) {
 			IP_VS_ERR_RL("BACKUP v0, bogus conn\n");
@@ -1109,7 +1109,7 @@ static void ip_vs_process_message(struct net *net, __u8 *buffer,
 
 		for (i=0; i<nr_conns; i++) {
 			union ip_vs_sync_conn *s;
-			unsigned size;
+			unsigned int size;
 			int retc;
 
 			p = msg_end;
diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index 722291f..471b054 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -1230,7 +1230,7 @@ static struct nf_conntrack_expect *find_expect(struct nf_conn *ct,
 
 /****************************************************************************/
 static int set_expect_timeout(struct nf_conntrack_expect *exp,
-			      unsigned timeout)
+			      unsigned int timeout)
 {
 	if (!exp || !del_timer(&exp->timeout))
 		return 0;
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index e6ddde1..3e797d1 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -103,7 +103,7 @@ int nfnetlink_has_listeners(struct net *net, unsigned int group)
 EXPORT_SYMBOL_GPL(nfnetlink_has_listeners);
 
 int nfnetlink_send(struct sk_buff *skb, struct net *net, u32 pid,
-		   unsigned group, int echo, gfp_t flags)
+		   unsigned int group, int echo, gfp_t flags)
 {
 	return nlmsg_notify(net->nfnl, skb, pid, group, echo, flags);
 }
diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index d2ff15a..fc0d6db 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -314,7 +314,7 @@ static int recent_mt_check(const struct xt_mtchk_param *par)
 #ifdef CONFIG_PROC_FS
 	struct proc_dir_entry *pde;
 #endif
-	unsigned i;
+	unsigned int i;
 	int ret = -EINVAL;
 
 	if (unlikely(!hash_rnd_inited)) {
diff --git a/net/netrom/nr_dev.c b/net/netrom/nr_dev.c
index 1c51d7a..743262b 100644
--- a/net/netrom/nr_dev.c
+++ b/net/netrom/nr_dev.c
@@ -97,7 +97,7 @@ static int nr_rebuild_header(struct sk_buff *skb)
 
 static int nr_header(struct sk_buff *skb, struct net_device *dev,
 		     unsigned short type,
-		     const void *daddr, const void *saddr, unsigned len)
+		     const void *daddr, const void *saddr, unsigned int len)
 {
 	unsigned char *buff = skb_push(skb, NR_NETWORK_LEN + NR_TRANSPORT_LEN);
 
diff --git a/net/nfc/core.c b/net/nfc/core.c
index 295d129..32a7b61 100644
--- a/net/nfc/core.c
+++ b/net/nfc/core.c
@@ -475,12 +475,12 @@ EXPORT_SYMBOL(nfc_class);
 static int match_idx(struct device *d, void *data)
 {
 	struct nfc_dev *dev = to_nfc_dev(d);
-	unsigned *idx = data;
+	unsigned int *idx = data;
 
 	return dev->idx == *idx;
 }
 
-struct nfc_dev *nfc_get_device(unsigned idx)
+struct nfc_dev *nfc_get_device(unsigned int idx)
 {
 	struct device *d;
 
diff --git a/net/nfc/nfc.h b/net/nfc/nfc.h
index ec8794c..061a830 100644
--- a/net/nfc/nfc.h
+++ b/net/nfc/nfc.h
@@ -127,7 +127,7 @@ int nfc_genl_dep_link_up_event(struct nfc_dev *dev, u32 target_idx,
 			       u8 comm_mode, u8 rf_mode);
 int nfc_genl_dep_link_down_event(struct nfc_dev *dev);
 
-struct nfc_dev *nfc_get_device(unsigned idx);
+struct nfc_dev *nfc_get_device(unsigned int idx);
 
 static inline void nfc_put_device(struct nfc_dev *dev)
 {
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index c1068ae..5920bda 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -140,9 +140,9 @@ int ovs_netdev_get_ifindex(const struct vport *vport)
 	return netdev_vport->dev->ifindex;
 }
 
-static unsigned packet_length(const struct sk_buff *skb)
+static unsigned int packet_length(const struct sk_buff *skb)
 {
-	unsigned length = skb->len - ETH_HLEN;
+	unsigned int length = skb->len - ETH_HLEN;
 
 	if (skb->protocol == htons(ETH_P_8021Q))
 		length -= VLAN_HLEN;
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 4f2c0df..d2b5f65 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1764,7 +1764,7 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 		macoff = netoff = TPACKET_ALIGN(po->tp_hdrlen) + 16 +
 				  po->tp_reserve;
 	} else {
-		unsigned maclen = skb_network_offset(skb);
+		unsigned int maclen = skb_network_offset(skb);
 		netoff = TPACKET_ALIGN(po->tp_hdrlen +
 				       (maclen < 16 ? 16 : maclen)) +
 			po->tp_reserve;
diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index d65f699..779ce4f 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -129,7 +129,7 @@ static const struct net_proto_family phonet_proto_family = {
 /* Phonet device header operations */
 static int pn_header_create(struct sk_buff *skb, struct net_device *dev,
 				unsigned short type, const void *daddr,
-				const void *saddr, unsigned len)
+				const void *saddr, unsigned int len)
 {
 	u8 *media = skb_push(skb, 1);
 
diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index 9726fe6..9dd4f92 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -273,7 +273,7 @@ static int pipe_rcv_status(struct sock *sk, struct sk_buff *skb)
 	hdr = pnp_hdr(skb);
 	if (hdr->data[0] != PN_PEP_TYPE_COMMON) {
 		LIMIT_NETDEBUG(KERN_DEBUG"Phonet unknown PEP type: %u\n",
-				(unsigned)hdr->data[0]);
+				(unsigned int)hdr->data[0]);
 		return -EOPNOTSUPP;
 	}
 
@@ -305,7 +305,7 @@ static int pipe_rcv_status(struct sock *sk, struct sk_buff *skb)
 
 	default:
 		LIMIT_NETDEBUG(KERN_DEBUG"Phonet unknown PEP indication: %u\n",
-				(unsigned)hdr->data[1]);
+				(unsigned int)hdr->data[1]);
 		return -EOPNOTSUPP;
 	}
 	if (wake)
@@ -478,9 +478,9 @@ static void pipe_destruct(struct sock *sk)
 	skb_queue_purge(&pn->ctrlreq_queue);
 }
 
-static u8 pipe_negotiate_fc(const u8 *fcs, unsigned n)
+static u8 pipe_negotiate_fc(const u8 *fcs, unsigned int n)
 {
-	unsigned i;
+	unsigned int i;
 	u8 final_fc = PN_NO_FLOW_CONTROL;
 
 	for (i = 0; i < n; i++) {
diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
index da564ef..36f75a9 100644
--- a/net/phonet/pn_dev.c
+++ b/net/phonet/pn_dev.c
@@ -268,7 +268,7 @@ static int phonet_device_autoconf(struct net_device *dev)
 static void phonet_route_autodel(struct net_device *dev)
 {
 	struct phonet_net *pnn = phonet_pernet(dev_net(dev));
-	unsigned i;
+	unsigned int i;
 	DECLARE_BITMAP(deleted, 64);
 
 	/* Remove left-over Phonet routes */
diff --git a/net/phonet/socket.c b/net/phonet/socket.c
index 4c7eff3..89cfa9c 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -58,7 +58,7 @@ static struct  {
 
 void __init pn_sock_init(void)
 {
-	unsigned i;
+	unsigned int i;
 
 	for (i = 0; i < PN_HASHSIZE; i++)
 		INIT_HLIST_HEAD(pnsocks.hlist + i);
@@ -116,7 +116,7 @@ struct sock *pn_find_sock_by_sa(struct net *net, const struct sockaddr_pn *spn)
 void pn_deliver_sock_broadcast(struct net *net, struct sk_buff *skb)
 {
 	struct hlist_head *hlist = pnsocks.hlist;
-	unsigned h;
+	unsigned int h;
 
 	rcu_read_lock();
 	for (h = 0; h < PN_HASHSIZE; h++) {
@@ -545,7 +545,7 @@ static struct sock *pn_sock_get_idx(struct seq_file *seq, loff_t pos)
 	struct hlist_head *hlist = pnsocks.hlist;
 	struct hlist_node *node;
 	struct sock *sknode;
-	unsigned h;
+	unsigned int h;
 
 	for (h = 0; h < PN_HASHSIZE; h++) {
 		sk_for_each_rcu(sknode, node, hlist) {
@@ -710,7 +710,7 @@ int pn_sock_unbind_res(struct sock *sk, u8 res)
 
 void pn_sock_unbind_all_res(struct sock *sk)
 {
-	unsigned res, match = 0;
+	unsigned int res, match = 0;
 
 	mutex_lock(&resource_mutex);
 	for (res = 0; res < 256; res++) {
@@ -732,7 +732,7 @@ void pn_sock_unbind_all_res(struct sock *sk)
 static struct sock **pn_res_get_idx(struct seq_file *seq, loff_t pos)
 {
 	struct net *net = seq_file_net(seq);
-	unsigned i;
+	unsigned int i;
 
 	if (!net_eq(net, &init_net))
 		return NULL;
@@ -750,7 +750,7 @@ static struct sock **pn_res_get_idx(struct seq_file *seq, loff_t pos)
 static struct sock **pn_res_get_next(struct seq_file *seq, struct sock **sk)
 {
 	struct net *net = seq_file_net(seq);
-	unsigned i;
+	unsigned int i;
 
 	BUG_ON(!net_eq(net, &init_net));
 
diff --git a/net/phonet/sysctl.c b/net/phonet/sysctl.c
index 740bf20..8bed767 100644
--- a/net/phonet/sysctl.c
+++ b/net/phonet/sysctl.c
@@ -50,7 +50,8 @@ static void set_local_port_range(int range[2])
 
 void phonet_get_local_port_range(int *min, int *max)
 {
-	unsigned seq;
+	unsigned int seq;
+
 	do {
 		seq = read_seqbegin(&local_port_range_lock);
 		if (min)
diff --git a/net/rose/rose_dev.c b/net/rose/rose_dev.c
index 906cc05..28dbdb9 100644
--- a/net/rose/rose_dev.c
+++ b/net/rose/rose_dev.c
@@ -37,7 +37,7 @@
 
 static int rose_header(struct sk_buff *skb, struct net_device *dev,
 		       unsigned short type,
-		       const void *daddr, const void *saddr, unsigned len)
+		       const void *daddr, const void *saddr, unsigned int len)
 {
 	unsigned char *buff = skb_push(skb, ROSE_MIN_LEN + 2);
 
diff --git a/net/rose/rose_subr.c b/net/rose/rose_subr.c
index 47f1fdb..7ca5774 100644
--- a/net/rose/rose_subr.c
+++ b/net/rose/rose_subr.c
@@ -399,7 +399,7 @@ int rose_parse_facilities(unsigned char *p, unsigned packet_len,
 
 	facilities_len = *p++;
 
-	if (facilities_len == 0 || (unsigned)facilities_len > packet_len)
+	if (facilities_len == 0 || (unsigned int)facilities_len > packet_len)
 		return 0;
 
 	while (facilities_len >= 3 && *p == 0x00) {
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 74c064c..05996d0 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -26,7 +26,7 @@ MODULE_AUTHOR("Red Hat, Inc.");
 MODULE_LICENSE("GPL");
 MODULE_ALIAS_NETPROTO(PF_RXRPC);
 
-unsigned rxrpc_debug; // = RXRPC_DEBUG_KPROTO;
+unsigned int rxrpc_debug; // = RXRPC_DEBUG_KPROTO;
 module_param_named(debug, rxrpc_debug, uint, S_IWUSR | S_IRUGO);
 MODULE_PARM_DESC(debug, "RxRPC debugging mask");
 
@@ -513,7 +513,7 @@ static int rxrpc_setsockopt(struct socket *sock, int level, int optname,
 			    char __user *optval, unsigned int optlen)
 {
 	struct rxrpc_sock *rx = rxrpc_sk(sock->sk);
-	unsigned min_sec_level;
+	unsigned int min_sec_level;
 	int ret;
 
 	_enter(",%d,%d,,%d", level, optname, optlen);
@@ -555,13 +555,13 @@ static int rxrpc_setsockopt(struct socket *sock, int level, int optname,
 
 		case RXRPC_MIN_SECURITY_LEVEL:
 			ret = -EINVAL;
-			if (optlen != sizeof(unsigned))
+			if (optlen != sizeof(unsigned int))
 				goto error;
 			ret = -EISCONN;
 			if (rx->sk.sk_state != RXRPC_UNCONNECTED)
 				goto error;
 			ret = get_user(min_sec_level,
-				       (unsigned __user *) optval);
+				       (unsigned int __user *) optval);
 			if (ret < 0)
 				goto error;
 			ret = -EINVAL;
diff --git a/net/rxrpc/ar-ack.c b/net/rxrpc/ar-ack.c
index c3126e8..e4d9cbc 100644
--- a/net/rxrpc/ar-ack.c
+++ b/net/rxrpc/ar-ack.c
@@ -19,7 +19,7 @@
 #include <net/af_rxrpc.h>
 #include "ar-internal.h"
 
-static unsigned rxrpc_ack_defer = 1;
+static unsigned int rxrpc_ack_defer = 1;
 
 static const char *const rxrpc_acks[] = {
 	"---", "REQ", "DUP", "OOS", "WIN", "MEM", "PNG", "PNR", "DLY", "IDL",
@@ -548,11 +548,11 @@ static void rxrpc_zap_tx_window(struct rxrpc_call *call)
  * process the extra information that may be appended to an ACK packet
  */
 static void rxrpc_extract_ackinfo(struct rxrpc_call *call, struct sk_buff *skb,
-				  unsigned latest, int nAcks)
+				  unsigned int latest, int nAcks)
 {
 	struct rxrpc_ackinfo ackinfo;
 	struct rxrpc_peer *peer;
-	unsigned mtu;
+	unsigned int mtu;
 
 	if (skb_copy_bits(skb, nAcks + 3, &ackinfo, sizeof(ackinfo)) < 0) {
 		_leave(" [no ackinfo]");
diff --git a/net/rxrpc/ar-call.c b/net/rxrpc/ar-call.c
index bf656c2..a3bbb36 100644
--- a/net/rxrpc/ar-call.c
+++ b/net/rxrpc/ar-call.c
@@ -38,8 +38,8 @@ const char *const rxrpc_call_states[] = {
 struct kmem_cache *rxrpc_call_jar;
 LIST_HEAD(rxrpc_calls);
 DEFINE_RWLOCK(rxrpc_call_lock);
-static unsigned rxrpc_call_max_lifetime = 60;
-static unsigned rxrpc_dead_call_timeout = 2;
+static unsigned int rxrpc_call_max_lifetime = 60;
+static unsigned int rxrpc_dead_call_timeout = 2;
 
 static void rxrpc_destroy_call(struct work_struct *work);
 static void rxrpc_call_life_expired(unsigned long _call);
diff --git a/net/rxrpc/ar-input.c b/net/rxrpc/ar-input.c
index 1a2b0633..529572f 100644
--- a/net/rxrpc/ar-input.c
+++ b/net/rxrpc/ar-input.c
@@ -76,7 +76,7 @@ int rxrpc_queue_rcv_skb(struct rxrpc_call *call, struct sk_buff *skb,
 		 * --ANK */
 //		ret = -ENOBUFS;
 //		if (atomic_read(&sk->sk_rmem_alloc) + skb->truesize >=
-//		    (unsigned) sk->sk_rcvbuf)
+//		    (unsigned int) sk->sk_rcvbuf)
 //			goto out;
 
 		ret = sk_filter(sk, skb);
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 8e22bd3..a693aca 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -83,7 +83,7 @@ struct rxrpc_skb_priv {
 	struct rxrpc_call	*call;		/* call with which associated */
 	unsigned long		resend_at;	/* time in jiffies at which to resend */
 	union {
-		unsigned	offset;		/* offset into buffer of next read */
+		unsigned int	offset;		/* offset into buffer of next read */
 		int		remain;		/* amount of space remaining for next write */
 		u32		error;		/* network error code */
 		bool		need_resend;	/* T if needs resending */
@@ -176,9 +176,9 @@ struct rxrpc_peer {
 	struct list_head	error_targets;	/* targets for net error distribution */
 	spinlock_t		lock;		/* access lock */
 	atomic_t		usage;
-	unsigned		if_mtu;		/* interface MTU for this peer */
-	unsigned		mtu;		/* network MTU for this peer */
-	unsigned		maxdata;	/* data size (MTU - hdrsize) */
+	unsigned int		if_mtu;		/* interface MTU for this peer */
+	unsigned int		mtu;		/* network MTU for this peer */
+	unsigned int		maxdata;	/* data size (MTU - hdrsize) */
 	unsigned short		hdrsize;	/* header size (IP + UDP + RxRPC) */
 	int			debug_id;	/* debug ID for printks */
 	int			net_error;	/* network error distributed */
@@ -187,8 +187,8 @@ struct rxrpc_peer {
 	/* calculated RTT cache */
 #define RXRPC_RTT_CACHE_SIZE 32
 	suseconds_t		rtt;		/* current RTT estimate (in uS) */
-	unsigned		rtt_point;	/* next entry at which to insert */
-	unsigned		rtt_usage;	/* amount of cache actually used */
+	unsigned int		rtt_point;	/* next entry at which to insert */
+	unsigned int		rtt_usage;	/* amount of cache actually used */
 	suseconds_t		rtt_cache[RXRPC_RTT_CACHE_SIZE]; /* calculated RTT cache */
 };
 
@@ -271,7 +271,7 @@ struct rxrpc_connection {
 	} state;
 	int			error;		/* error code for local abort */
 	int			debug_id;	/* debug ID for printks */
-	unsigned		call_counter;	/* call ID counter */
+	unsigned int		call_counter;	/* call ID counter */
 	atomic_t		serial;		/* packet serial number counter */
 	atomic_t		hi_serial;	/* highest serial number received */
 	u8			avail_calls;	/* number of calls available */
@@ -592,7 +592,7 @@ extern struct rxrpc_transport *rxrpc_find_transport(struct rxrpc_local *,
 /*
  * debug tracing
  */
-extern unsigned rxrpc_debug;
+extern unsigned int rxrpc_debug;
 
 #define dbgprintk(FMT,...) \
 	printk("[%-6.6s] "FMT"\n", current->comm ,##__VA_ARGS__)
diff --git a/net/rxrpc/ar-key.c b/net/rxrpc/ar-key.c
index ae3a035..8b1f9f4 100644
--- a/net/rxrpc/ar-key.c
+++ b/net/rxrpc/ar-key.c
@@ -82,7 +82,7 @@ static int rxrpc_vet_description_s(const char *desc)
  * - the caller guarantees we have at least 4 words
  */
 static int rxrpc_instantiate_xdr_rxkad(struct key *key, const __be32 *xdr,
-				       unsigned toklen)
+				       unsigned int toklen)
 {
 	struct rxrpc_key_token *token, **pptoken;
 	size_t plen;
@@ -210,10 +210,10 @@ static void rxrpc_rxk5_free(struct rxk5_key *rxk5)
  */
 static int rxrpc_krb5_decode_principal(struct krb5_principal *princ,
 				       const __be32 **_xdr,
-				       unsigned *_toklen)
+				       unsigned int *_toklen)
 {
 	const __be32 *xdr = *_xdr;
-	unsigned toklen = *_toklen, n_parts, loop, tmp;
+	unsigned int toklen = *_toklen, n_parts, loop, tmp;
 
 	/* there must be at least one name, and at least #names+1 length
 	 * words */
@@ -286,10 +286,10 @@ static int rxrpc_krb5_decode_principal(struct krb5_principal *princ,
 static int rxrpc_krb5_decode_tagged_data(struct krb5_tagged_data *td,
 					 size_t max_data_size,
 					 const __be32 **_xdr,
-					 unsigned *_toklen)
+					 unsigned int *_toklen)
 {
 	const __be32 *xdr = *_xdr;
-	unsigned toklen = *_toklen, len;
+	unsigned int toklen = *_toklen, len;
 
 	/* there must be at least one tag and one length word */
 	if (toklen <= 8)
@@ -330,11 +330,11 @@ static int rxrpc_krb5_decode_tagged_array(struct krb5_tagged_data **_td,
 					  u8 max_n_elem,
 					  size_t max_elem_size,
 					  const __be32 **_xdr,
-					  unsigned *_toklen)
+					  unsigned int *_toklen)
 {
 	struct krb5_tagged_data *td;
 	const __be32 *xdr = *_xdr;
-	unsigned toklen = *_toklen, n_elem, loop;
+	unsigned int toklen = *_toklen, n_elem, loop;
 	int ret;
 
 	/* there must be at least one count */
@@ -380,10 +380,10 @@ static int rxrpc_krb5_decode_tagged_array(struct krb5_tagged_data **_td,
  * extract a krb5 ticket
  */
 static int rxrpc_krb5_decode_ticket(u8 **_ticket, u16 *_tktlen,
-				    const __be32 **_xdr, unsigned *_toklen)
+				    const __be32 **_xdr, unsigned int *_toklen)
 {
 	const __be32 *xdr = *_xdr;
-	unsigned toklen = *_toklen, len;
+	unsigned int toklen = *_toklen, len;
 
 	/* there must be at least one length word */
 	if (toklen <= 4)
@@ -419,7 +419,7 @@ static int rxrpc_krb5_decode_ticket(u8 **_ticket, u16 *_tktlen,
  * - the caller guarantees we have at least 4 words
  */
 static int rxrpc_instantiate_xdr_rxk5(struct key *key, const __be32 *xdr,
-				      unsigned toklen)
+				      unsigned int toklen)
 {
 	struct rxrpc_key_token *token, **pptoken;
 	struct rxk5_key *rxk5;
@@ -549,7 +549,7 @@ static int rxrpc_instantiate_xdr(struct key *key, const void *data, size_t datal
 {
 	const __be32 *xdr = data, *token;
 	const char *cp;
-	unsigned len, tmp, loop, ntoken, toklen, sec_ix;
+	unsigned int len, tmp, loop, ntoken, toklen, sec_ix;
 	int ret;
 
 	_enter(",{%x,%x,%x,%x},%zu",
diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index 7635107..f226709 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -31,7 +31,7 @@
 #define REALM_SZ			40	/* size of principal's auth domain */
 #define SNAME_SZ			40	/* size of service name */
 
-unsigned rxrpc_debug;
+unsigned int rxrpc_debug;
 module_param_named(debug, rxrpc_debug, uint, S_IWUSR | S_IRUGO);
 MODULE_PARM_DESC(debug, "rxkad debugging mask");
 
@@ -207,7 +207,7 @@ static int rxkad_secure_packet_encrypt(const struct rxrpc_call *call,
 	struct rxrpc_crypt iv;
 	struct scatterlist sg[16];
 	struct sk_buff *trailer;
-	unsigned len;
+	unsigned int len;
 	u16 check;
 	int nsg;
 
@@ -826,7 +826,7 @@ static int rxkad_decrypt_ticket(struct rxrpc_connection *conn,
 	struct rxrpc_crypt iv, key;
 	struct scatterlist sg[1];
 	struct in_addr addr;
-	unsigned life;
+	unsigned int life;
 	time_t issue, now;
 	bool little_endian;
 	int ret;
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index acd2edb..5bc9ab1 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -1408,7 +1408,7 @@ static inline int sctp_peer_needs_update(struct sctp_association *asoc)
 }
 
 /* Increase asoc's rwnd by len and send any window update SACK if needed. */
-void sctp_assoc_rwnd_increase(struct sctp_association *asoc, unsigned len)
+void sctp_assoc_rwnd_increase(struct sctp_association *asoc, unsigned int len)
 {
 	struct sctp_chunk *sack;
 	struct timer_list *timer;
@@ -1465,7 +1465,7 @@ void sctp_assoc_rwnd_increase(struct sctp_association *asoc, unsigned len)
 }
 
 /* Decrease asoc's rwnd by len. */
-void sctp_assoc_rwnd_decrease(struct sctp_association *asoc, unsigned len)
+void sctp_assoc_rwnd_decrease(struct sctp_association *asoc, unsigned int len)
 {
 	int rx_count;
 	int over = 0;
diff --git a/net/sctp/output.c b/net/sctp/output.c
index 817174e..69534c5 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -663,8 +663,8 @@ static sctp_xmit_t sctp_packet_can_append_data(struct sctp_packet *packet,
 	 */
 	if (!sctp_sk(asoc->base.sk)->nodelay && sctp_packet_empty(packet) &&
 	    inflight && sctp_state(asoc, ESTABLISHED)) {
-		unsigned max = transport->pathmtu - packet->overhead;
-		unsigned len = chunk->skb->len + q->out_qlen;
+		unsigned int max = transport->pathmtu - packet->overhead;
+		unsigned int len = chunk->skb->len + q->out_qlen;
 
 		/* Check whether this chunk and all the rest of pending
 		 * data will fit or delay in hopes of bundling a full
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index cfeb1d4..a0fa19f 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -1147,7 +1147,7 @@ int sctp_outq_sack(struct sctp_outq *q, struct sctp_sackhdr *sack)
 	__u32 sack_ctsn, ctsn, tsn;
 	__u32 highest_tsn, highest_new_tsn;
 	__u32 sack_a_rwnd;
-	unsigned outstanding;
+	unsigned int outstanding;
 	struct sctp_transport *primary = asoc->peer.primary_path;
 	int count_of_newacks = 0;
 	int gap_ack_blocks;
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 1ff51c9..fbb374c 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -524,7 +524,7 @@ static void sctp_do_8_2_transport_strike(struct sctp_association *asoc,
 /* Worker routine to handle INIT command failure.  */
 static void sctp_cmd_init_failed(sctp_cmd_seq_t *commands,
 				 struct sctp_association *asoc,
-				 unsigned error)
+				 unsigned int error)
 {
 	struct sctp_ulpevent *event;
 
@@ -550,7 +550,7 @@ static void sctp_cmd_assoc_failed(sctp_cmd_seq_t *commands,
 				  sctp_event_t event_type,
 				  sctp_subtype_t subtype,
 				  struct sctp_chunk *chunk,
-				  unsigned error)
+				  unsigned int error)
 {
 	struct sctp_ulpevent *event;
 
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 891f5db..a147b4d 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -2410,7 +2410,7 @@ static sctp_disposition_t __sctp_sf_do_9_1_abort(const struct sctp_endpoint *ep,
 					sctp_cmd_seq_t *commands)
 {
 	struct sctp_chunk *chunk = arg;
-	unsigned len;
+	unsigned int len;
 	__be16 error = SCTP_ERROR_NO_ERROR;
 
 	/* See if we have an error cause code in the chunk.  */
@@ -2446,7 +2446,7 @@ sctp_disposition_t sctp_sf_cookie_wait_abort(const struct sctp_endpoint *ep,
 				     sctp_cmd_seq_t *commands)
 {
 	struct sctp_chunk *chunk = arg;
-	unsigned len;
+	unsigned int len;
 	__be16 error = SCTP_ERROR_NO_ERROR;
 
 	if (!sctp_vtag_verify_either(chunk, asoc))
diff --git a/net/socket.c b/net/socket.c
index 851edcd..d6c1af9 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1479,7 +1479,7 @@ SYSCALL_DEFINE2(listen, int, fd, int, backlog)
 	sock = sockfd_lookup_light(fd, &err, &fput_needed);
 	if (sock) {
 		somaxconn = sock_net(sock->sk)->core.sysctl_somaxconn;
-		if ((unsigned)backlog > somaxconn)
+		if ((unsigned int)backlog > somaxconn)
 			backlog = somaxconn;
 
 		err = security_socket_listen(sock, backlog);
@@ -1691,7 +1691,7 @@ SYSCALL_DEFINE3(getpeername, int, fd, struct sockaddr __user *, usockaddr,
  */
 
 SYSCALL_DEFINE6(sendto, int, fd, void __user *, buff, size_t, len,
-		unsigned, flags, struct sockaddr __user *, addr,
+		unsigned int, flags, struct sockaddr __user *, addr,
 		int, addr_len)
 {
 	struct socket *sock;
@@ -1738,7 +1738,7 @@ out:
  */
 
 SYSCALL_DEFINE4(send, int, fd, void __user *, buff, size_t, len,
-		unsigned, flags)
+		unsigned int, flags)
 {
 	return sys_sendto(fd, buff, len, flags, NULL, 0);
 }
@@ -1750,7 +1750,7 @@ SYSCALL_DEFINE4(send, int, fd, void __user *, buff, size_t, len,
  */
 
 SYSCALL_DEFINE6(recvfrom, int, fd, void __user *, ubuf, size_t, size,
-		unsigned, flags, struct sockaddr __user *, addr,
+		unsigned int, flags, struct sockaddr __user *, addr,
 		int __user *, addr_len)
 {
 	struct socket *sock;
@@ -1795,7 +1795,7 @@ out:
  */
 
 asmlinkage long sys_recv(int fd, void __user *ubuf, size_t size,
-			 unsigned flags)
+			 unsigned int flags)
 {
 	return sys_recvfrom(fd, ubuf, size, flags, NULL, NULL);
 }
@@ -1897,7 +1897,7 @@ struct used_address {
 };
 
 static int __sys_sendmsg(struct socket *sock, struct msghdr __user *msg,
-			 struct msghdr *msg_sys, unsigned flags,
+			 struct msghdr *msg_sys, unsigned int flags,
 			 struct used_address *used_address)
 {
 	struct compat_msghdr __user *msg_compat =
@@ -2014,7 +2014,7 @@ out:
  *	BSD sendmsg interface
  */
 
-SYSCALL_DEFINE3(sendmsg, int, fd, struct msghdr __user *, msg, unsigned, flags)
+SYSCALL_DEFINE3(sendmsg, int, fd, struct msghdr __user *, msg, unsigned int, flags)
 {
 	int fput_needed, err;
 	struct msghdr msg_sys;
@@ -2096,7 +2096,7 @@ SYSCALL_DEFINE4(sendmmsg, int, fd, struct mmsghdr __user *, mmsg,
 }
 
 static int __sys_recvmsg(struct socket *sock, struct msghdr __user *msg,
-			 struct msghdr *msg_sys, unsigned flags, int nosec)
+			 struct msghdr *msg_sys, unsigned int flags, int nosec)
 {
 	struct compat_msghdr __user *msg_compat =
 	    (struct compat_msghdr __user *)msg;
@@ -3223,7 +3223,7 @@ static int compat_sock_ioctl_trans(struct file *file, struct socket *sock,
 	return -ENOIOCTLCMD;
 }
 
-static long compat_sock_ioctl(struct file *file, unsigned cmd,
+static long compat_sock_ioctl(struct file *file, unsigned int cmd,
 			      unsigned long arg)
 {
 	struct socket *sock = file->private_data;
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index 8eff8c3..d3611f1 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -624,7 +624,7 @@ gss_import_v2_context(const void *p, const void *end, struct krb5_ctx *ctx,
 	ctx->seq_send = ctx->seq_send64;
 	if (ctx->seq_send64 != ctx->seq_send) {
 		dprintk("%s: seq_send64 %lx, seq_send %x overflow?\n", __func__,
-			(long unsigned)ctx->seq_send64, ctx->seq_send);
+			(unsigned long)ctx->seq_send64, ctx->seq_send);
 		p = ERR_PTR(-EINVAL);
 		goto out_err;
 	}
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index de0b0f3..47ad266 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -1273,7 +1273,7 @@ static void *c_start(struct seq_file *m, loff_t *pos)
 	__acquires(cd->hash_lock)
 {
 	loff_t n = *pos;
-	unsigned hash, entry;
+	unsigned int hash, entry;
 	struct cache_head *ch;
 	struct cache_detail *cd = ((struct handle*)m->private)->cd;
 
diff --git a/net/sunrpc/timer.c b/net/sunrpc/timer.c
index dd82434..08881d0 100644
--- a/net/sunrpc/timer.c
+++ b/net/sunrpc/timer.c
@@ -34,7 +34,7 @@
 void rpc_init_rtt(struct rpc_rtt *rt, unsigned long timeo)
 {
 	unsigned long init = 0;
-	unsigned i;
+	unsigned int i;
 
 	rt->timeo = timeo;
 
@@ -57,7 +57,7 @@ EXPORT_SYMBOL_GPL(rpc_init_rtt);
  * NB: When computing the smoothed RTT and standard deviation,
  *     be careful not to produce negative intermediate results.
  */
-void rpc_update_rtt(struct rpc_rtt *rt, unsigned timer, long m)
+void rpc_update_rtt(struct rpc_rtt *rt, unsigned int timer, long m)
 {
 	long *srtt, *sdrtt;
 
@@ -106,7 +106,7 @@ EXPORT_SYMBOL_GPL(rpc_update_rtt);
  * read, write, commit     - A+4D
  * other                   - timeo
  */
-unsigned long rpc_calc_rto(struct rpc_rtt *rt, unsigned timer)
+unsigned long rpc_calc_rto(struct rpc_rtt *rt, unsigned int timer)
 {
 	unsigned long res;
 
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index b97a3dd..fddcccf 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -1204,7 +1204,7 @@ xdr_process_buf(struct xdr_buf *buf, unsigned int offset, unsigned int len,
 		int (*actor)(struct scatterlist *, void *), void *data)
 {
 	int i, ret = 0;
-	unsigned page_len, thislen, page_offset;
+	unsigned int page_len, thislen, page_offset;
 	struct scatterlist      sg[1];
 
 	sg_init_table(sg, 1);
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 0cbcd1a..6fe2dce 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -783,7 +783,7 @@ static void xprt_update_rtt(struct rpc_task *task)
 {
 	struct rpc_rqst *req = task->tk_rqstp;
 	struct rpc_rtt *rtt = task->tk_client->cl_rtt;
-	unsigned timer = task->tk_msg.rpc_proc->p_timer;
+	unsigned int timer = task->tk_msg.rpc_proc->p_timer;
 	long m = usecs_to_jiffies(ktime_to_us(req->rq_rtt));
 
 	if (timer) {
diff --git a/net/tipc/link.c b/net/tipc/link.c
index b4b9b30..33cecd6 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -612,7 +612,7 @@ static void link_activate(struct tipc_link *l_ptr)
  * @event: state machine event to process
  */
 
-static void link_state_event(struct tipc_link *l_ptr, unsigned event)
+static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 {
 	struct tipc_link *other;
 	u32 cont_intv = l_ptr->continuity_interval;
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 29e957f..bcb3314 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -535,7 +535,7 @@ static int send_msg(struct kiocb *iocb, struct socket *sock,
 		     (dest->family != AF_TIPC)))
 		return -EINVAL;
 	if ((total_len > TIPC_MAX_USER_MSG_SIZE) ||
-	    (m->msg_iovlen > (unsigned)INT_MAX))
+	    (m->msg_iovlen > (unsigned int)INT_MAX))
 		return -EMSGSIZE;
 
 	if (iocb)
@@ -647,7 +647,7 @@ static int send_packet(struct kiocb *iocb, struct socket *sock,
 		return send_msg(iocb, sock, m, total_len);
 
 	if ((total_len > TIPC_MAX_USER_MSG_SIZE) ||
-	    (m->msg_iovlen > (unsigned)INT_MAX))
+	    (m->msg_iovlen > (unsigned int)INT_MAX))
 		return -EMSGSIZE;
 
 	if (iocb)
@@ -734,8 +734,8 @@ static int send_stream(struct kiocb *iocb, struct socket *sock,
 		goto exit;
 	}
 
-	if ((total_len > (unsigned)INT_MAX) ||
-	    (m->msg_iovlen > (unsigned)INT_MAX)) {
+	if ((total_len > (unsigned int)INT_MAX) ||
+	    (m->msg_iovlen > (unsigned int)INT_MAX)) {
 		res = -EMSGSIZE;
 		goto exit;
 	}
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index eadb902..641f2e4 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -149,9 +149,10 @@ static inline void unix_set_secdata(struct scm_cookie *scm, struct sk_buff *skb)
  *    each socket state is protected by separate spin lock.
  */
 
-static inline unsigned unix_hash_fold(__wsum n)
+static inline unsigned int unix_hash_fold(__wsum n)
 {
-	unsigned hash = (__force unsigned)n;
+	unsigned int hash = (__force unsigned int)n;
+
 	hash ^= hash>>16;
 	hash ^= hash>>8;
 	return hash&(UNIX_HASH_SIZE-1);
@@ -200,7 +201,7 @@ static inline void unix_release_addr(struct unix_address *addr)
  *		- if started by zero, it is abstract name.
  */
 
-static int unix_mkname(struct sockaddr_un *sunaddr, int len, unsigned *hashp)
+static int unix_mkname(struct sockaddr_un *sunaddr, int len, unsigned int *hashp)
 {
 	if (len <= sizeof(short) || len > sizeof(*sunaddr))
 		return -EINVAL;
@@ -250,7 +251,7 @@ static inline void unix_insert_socket(struct hlist_head *list, struct sock *sk)
 
 static struct sock *__unix_find_socket_byname(struct net *net,
 					      struct sockaddr_un *sunname,
-					      int len, int type, unsigned hash)
+					      int len, int type, unsigned int hash)
 {
 	struct sock *s;
 	struct hlist_node *node;
@@ -273,7 +274,7 @@ found:
 static inline struct sock *unix_find_socket_byname(struct net *net,
 						   struct sockaddr_un *sunname,
 						   int len, int type,
-						   unsigned hash)
+						   unsigned int hash)
 {
 	struct sock *s;
 
@@ -760,7 +761,7 @@ out:	mutex_unlock(&u->readlock);
 
 static struct sock *unix_find_other(struct net *net,
 				    struct sockaddr_un *sunname, int len,
-				    int type, unsigned hash, int *error)
+				    int type, unsigned int hash, int *error)
 {
 	struct sock *u;
 	struct path path;
@@ -824,7 +825,7 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	struct dentry *dentry = NULL;
 	struct path path;
 	int err;
-	unsigned hash;
+	unsigned int hash;
 	struct unix_address *addr;
 	struct hlist_head *list;
 
@@ -964,7 +965,7 @@ static int unix_dgram_connect(struct socket *sock, struct sockaddr *addr,
 	struct net *net = sock_net(sk);
 	struct sockaddr_un *sunaddr = (struct sockaddr_un *)addr;
 	struct sock *other;
-	unsigned hash;
+	unsigned int hash;
 	int err;
 
 	if (addr->sa_family != AF_UNSPEC) {
@@ -1062,7 +1063,7 @@ static int unix_stream_connect(struct socket *sock, struct sockaddr *uaddr,
 	struct sock *newsk = NULL;
 	struct sock *other = NULL;
 	struct sk_buff *skb = NULL;
-	unsigned hash;
+	unsigned int hash;
 	int st;
 	int err;
 	long timeo;
@@ -1437,7 +1438,7 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	struct sock *other = NULL;
 	int namelen = 0; /* fake GCC */
 	int err;
-	unsigned hash;
+	unsigned int hash;
 	struct sk_buff *skb;
 	long timeo;
 	struct scm_cookie tmp_scm;
diff --git a/net/wimax/stack.c b/net/wimax/stack.c
index 3c65eae..a6470ac 100644
--- a/net/wimax/stack.c
+++ b/net/wimax/stack.c
@@ -187,7 +187,7 @@ out:
 
 static
 void __check_new_state(enum wimax_st old_state, enum wimax_st new_state,
-		       unsigned allowed_states_bm)
+		       unsigned int allowed_states_bm)
 {
 	if (WARN_ON(((1 << new_state) & allowed_states_bm) == 0)) {
 		printk(KERN_ERR "SW BUG! Forbidden state change %u -> %u\n",
@@ -425,7 +425,8 @@ static
 size_t wimax_addr_scnprint(char *addr_str, size_t addr_str_size,
 			   unsigned char *addr, size_t addr_len)
 {
-	unsigned cnt, total;
+	unsigned int cnt, total;
+
 	for (total = cnt = 0; cnt < addr_len; cnt++)
 		total += scnprintf(addr_str + total, addr_str_size - total,
 				   "%02x%c", addr[cnt],
diff --git a/net/wireless/wext-core.c b/net/wireless/wext-core.c
index 22adfeb..b0eb7aa 100644
--- a/net/wireless/wext-core.c
+++ b/net/wireless/wext-core.c
@@ -256,7 +256,7 @@ static const struct iw_ioctl_description standard_ioctl[] = {
 		.max_tokens	= sizeof(struct iw_pmksa),
 	},
 };
-static const unsigned standard_ioctl_num = ARRAY_SIZE(standard_ioctl);
+static const unsigned int standard_ioctl_num = ARRAY_SIZE(standard_ioctl);
 
 /*
  * Meta-data about all the additional standard Wireless Extension events
@@ -306,7 +306,7 @@ static const struct iw_ioctl_description standard_event[] = {
 		.max_tokens	= sizeof(struct iw_pmkid_cand),
 	},
 };
-static const unsigned standard_event_num = ARRAY_SIZE(standard_event);
+static const unsigned int standard_event_num = ARRAY_SIZE(standard_event);
 
 /* Size (in bytes) of various events */
 static const int event_type_size[] = {
@@ -429,7 +429,7 @@ void wireless_send_event(struct net_device *	dev,
 	int hdr_len;				/* Size of the event header */
 	int wrqu_off = 0;			/* Offset in wrqu */
 	/* Don't "optimise" the following variable, it will crash */
-	unsigned	cmd_index;		/* *MUST* be unsigned */
+	unsigned int	cmd_index;		/* *MUST* be unsigned */
 	struct sk_buff *skb;
 	struct nlmsghdr *nlh;
 	struct nlattr *nla;
diff --git a/net/x25/x25_facilities.c b/net/x25/x25_facilities.c
index 36384a1..66c63873 100644
--- a/net/x25/x25_facilities.c
+++ b/net/x25/x25_facilities.c
@@ -231,7 +231,7 @@ int x25_create_facilities(unsigned char *buffer,
 	}
 
 	if (dte_facs->calling_len && (facil_mask & X25_MASK_CALLING_AE)) {
-		unsigned bytecount = (dte_facs->calling_len + 1) >> 1;
+		unsigned int bytecount = (dte_facs->calling_len + 1) >> 1;
 		*p++ = X25_FAC_CALLING_AE;
 		*p++ = 1 + bytecount;
 		*p++ = dte_facs->calling_len;
@@ -240,7 +240,7 @@ int x25_create_facilities(unsigned char *buffer,
 	}
 
 	if (dte_facs->called_len && (facil_mask & X25_MASK_CALLED_AE)) {
-		unsigned bytecount = (dte_facs->called_len % 2) ?
+		unsigned int bytecount = (dte_facs->called_len % 2) ?
 		dte_facs->called_len / 2 + 1 :
 		dte_facs->called_len / 2;
 		*p++ = X25_FAC_CALLED_AE;
diff --git a/net/xfrm/xfrm_hash.h b/net/xfrm/xfrm_hash.h
index 7199d78..716502a 100644
--- a/net/xfrm/xfrm_hash.h
+++ b/net/xfrm/xfrm_hash.h
@@ -45,10 +45,10 @@ static inline unsigned int __xfrm_dst_hash(const xfrm_address_t *daddr,
 	return (h ^ (h >> 16)) & hmask;
 }
 
-static inline unsigned __xfrm_src_hash(const xfrm_address_t *daddr,
-				       const xfrm_address_t *saddr,
-				       unsigned short family,
-				       unsigned int hmask)
+static inline unsigned int __xfrm_src_hash(const xfrm_address_t *daddr,
+					   const xfrm_address_t *saddr,
+					   unsigned short family,
+					   unsigned int hmask)
 {
 	unsigned int h = family;
 	switch (family) {
