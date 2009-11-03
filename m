From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: cleanup include/net
Date: Tue, 03 Nov 2009 14:26:03 +0100
Message-ID: <4AF02F6B.6040405@gmail.com>
References: <m1ws28ey3k.fsf@fess.ebiederm.org>	<20091103.020555.156050455.davem@davemloft.net>	<4AF0031B.4060708@gmail.com> <20091103.024424.146854177.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:44099 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816AbZKCN0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 08:26:05 -0500
In-Reply-To: <20091103.024424.146854177.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Would you accept one boring cleanup patch in include/net like follow=
ing ?
>=20
> Absolutely.

Good, here it is.

[PATCH net-next-2.6] net: cleanup include/net

This cleanup patch puts struct/union/enum opening braces,
in first line to ease grep games.

struct something
{

becomes :

struct something {

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/ah.h                             |    3 -
 include/net/dn_dev.h                         |   12 ++----
 include/net/dn_fib.h                         |    3 -
 include/net/dn_nsp.h                         |   24 ++++---------
 include/net/dst.h                            |    3 -
 include/net/fib_rules.h                      |    9 +---
 include/net/gen_stats.h                      |    3 -
 include/net/genetlink.h                      |   12 ++----
 include/net/if_inet6.h                       |   24 ++++---------
 include/net/inetpeer.h                       |    3 -
 include/net/ip.h                             |   15 ++------
 include/net/ip6_fib.h                        |   15 ++------
 include/net/ip6_route.h                      |    3 -
 include/net/ip_vs.h                          |    6 +--
 include/net/ipip.h                           |    9 +---
 include/net/ipv6.h                           |   12 ++----
 include/net/iw_handler.h                     |   12 ++----
 include/net/neighbour.h                      |   18 +++------
 include/net/netfilter/nf_conntrack_ecache.h  |    3 -
 include/net/netfilter/nf_conntrack_expect.h  |    6 +--
 include/net/netfilter/nf_conntrack_extend.h  |    6 +--
 include/net/netfilter/nf_conntrack_helper.h  |    3 -
 include/net/netfilter/nf_conntrack_l3proto.h |    3 -
 include/net/netfilter/nf_conntrack_l4proto.h |    3 -
 include/net/netfilter/nf_conntrack_tuple.h   |   12 ++----
 include/net/netfilter/nf_nat.h               |   15 ++------
 include/net/netfilter/nf_nat_protocol.h      |    3 -
 include/net/pkt_cls.h                        |   24 ++++---------
 include/net/pkt_sched.h                      |    3 -
 include/net/protocol.h                       |    3 -
 include/net/red.h                            |    6 +--
 include/net/route.h                          |   12 ++----
 include/net/sch_generic.h                    |   30 +++++-----------
 include/net/scm.h                            |    9 +---
 include/net/sctp/sctp.h                      |    3 -
 include/net/tcp.h                            |    3 -
 include/net/xfrm.h                           |   31 ++++++-----------
 37 files changed, 122 insertions(+), 242 deletions(-)

diff --git a/include/net/ah.h b/include/net/ah.h
index 7573a71..f0129f7 100644
--- a/include/net/ah.h
+++ b/include/net/ah.h
@@ -8,8 +8,7 @@
=20
 struct crypto_ahash;
=20
-struct ah_data
-{
+struct ah_data {
 	int			icv_full_len;
 	int			icv_trunc_len;
=20
diff --git a/include/net/dn_dev.h b/include/net/dn_dev.h
index cee4682..28966ca 100644
--- a/include/net/dn_dev.h
+++ b/include/net/dn_dev.h
@@ -97,16 +97,14 @@ struct dn_dev {
 	unsigned long uptime;     /* Time device went up in jiffies */
 };
=20
-struct dn_short_packet
-{
+struct dn_short_packet {
 	__u8    msgflg;
 	__le16 dstnode;
 	__le16 srcnode;
 	__u8   forward;
 } __attribute__((packed));
=20
-struct dn_long_packet
-{
+struct dn_long_packet {
 	__u8   msgflg;
 	__u8   d_area;
 	__u8   d_subarea;
@@ -122,8 +120,7 @@ struct dn_long_packet
=20
 /*------------------------- DRP - Routing messages -------------------=
--*/
=20
-struct endnode_hello_message
-{
+struct endnode_hello_message {
 	__u8   msgflg;
 	__u8   tiver[3];
 	__u8   id[6];
@@ -138,8 +135,7 @@ struct endnode_hello_message
 	__u8   data[2];
 } __attribute__((packed));
=20
-struct rtnode_hello_message
-{
+struct rtnode_hello_message {
 	__u8   msgflg;
 	__u8   tiver[3];
 	__u8   id[6];
diff --git a/include/net/dn_fib.h b/include/net/dn_fib.h
index c378be7..52da6c3 100644
--- a/include/net/dn_fib.h
+++ b/include/net/dn_fib.h
@@ -4,8 +4,7 @@
 /* WARNING: The ordering of these elements must match ordering
  *          of RTA_* rtnetlink attribute numbers.
  */
-struct dn_kern_rta
-{
+struct dn_kern_rta {
         void            *rta_dst;
         void            *rta_src;
         int             *rta_iif;
diff --git a/include/net/dn_nsp.h b/include/net/dn_nsp.h
index 96e816b..17d43d2 100644
--- a/include/net/dn_nsp.h
+++ b/include/net/dn_nsp.h
@@ -70,30 +70,26 @@ extern struct sk_buff *dn_alloc_send_skb(struct soc=
k *sk, size_t *size, int nobl
=20
 /* Data Messages    (data segment/interrupt/link service)             =
  */
=20
-struct nsp_data_seg_msg
-{
+struct nsp_data_seg_msg {
 	__u8   msgflg;
 	__le16 dstaddr;
 	__le16 srcaddr;
 } __attribute__((packed));
=20
-struct nsp_data_opt_msg
-{
+struct nsp_data_opt_msg {
 	__le16 acknum;
 	__le16 segnum;
 	__le16 lsflgs;
 } __attribute__((packed));
=20
-struct nsp_data_opt_msg1
-{
+struct nsp_data_opt_msg1 {
 	__le16 acknum;
 	__le16 segnum;
 } __attribute__((packed));
=20
=20
 /* Acknowledgment Message (data/other data)                           =
  */
-struct nsp_data_ack_msg
-{
+struct nsp_data_ack_msg {
 	__u8   msgflg;
 	__le16 dstaddr;
 	__le16 srcaddr;
@@ -101,16 +97,14 @@ struct nsp_data_ack_msg
 } __attribute__((packed));
=20
 /* Connect Acknowledgment Message */
-struct  nsp_conn_ack_msg
-{
+struct  nsp_conn_ack_msg {
 	__u8 msgflg;
 	__le16 dstaddr;
 } __attribute__((packed));
=20
=20
 /* Connect Initiate/Retransmit Initiate/Connect Confirm */
-struct  nsp_conn_init_msg
-{
+struct  nsp_conn_init_msg {
 	__u8   msgflg;
 #define NSP_CI      0x18            /* Connect Initiate     */
 #define NSP_RCI     0x68            /* Retrans. Conn Init   */
@@ -126,8 +120,7 @@ struct  nsp_conn_init_msg
 } __attribute__((packed));
=20
 /* Disconnect Initiate/Disconnect Confirm */
-struct  nsp_disconn_init_msg
-{
+struct  nsp_disconn_init_msg {
 	__u8   msgflg;
 	__le16 dstaddr;
 	__le16 srcaddr;
@@ -136,8 +129,7 @@ struct  nsp_disconn_init_msg
=20
=20
=20
-struct  srcobj_fmt
-{
+struct  srcobj_fmt {
 	__u8   format;
 	__u8   task;
 	__le16 grpcode;
diff --git a/include/net/dst.h b/include/net/dst.h
index 6377ab2..39c4a59 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -36,8 +36,7 @@
=20
 struct sk_buff;
=20
-struct dst_entry
-{
+struct dst_entry {
 	struct rcu_head		rcu_head;
 	struct dst_entry	*child;
 	struct net_device       *dev;
diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index ca4b2e8..2cd707b 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -7,8 +7,7 @@
 #include <net/flow.h>
 #include <net/rtnetlink.h>
=20
-struct fib_rule
-{
+struct fib_rule {
 	struct list_head	list;
 	atomic_t		refcnt;
 	int			ifindex;
@@ -25,15 +24,13 @@ struct fib_rule
 	struct net *		fr_net;
 };
=20
-struct fib_lookup_arg
-{
+struct fib_lookup_arg {
 	void			*lookup_ptr;
 	void			*result;
 	struct fib_rule		*rule;
 };
=20
-struct fib_rules_ops
-{
+struct fib_rules_ops {
 	int			family;
 	struct list_head	list;
 	int			rule_size;
diff --git a/include/net/gen_stats.h b/include/net/gen_stats.h
index eb87a14..fa15771 100644
--- a/include/net/gen_stats.h
+++ b/include/net/gen_stats.h
@@ -6,8 +6,7 @@
 #include <linux/rtnetlink.h>
 #include <linux/pkt_sched.h>
=20
-struct gnet_dump
-{
+struct gnet_dump {
 	spinlock_t *      lock;
 	struct sk_buff *  skb;
 	struct nlattr *   tail;
diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index 2a1c068..eb551ba 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -13,8 +13,7 @@
  * @list: list entry for linking
  * @family: pointer to family, need not be set before registering
  */
-struct genl_multicast_group
-{
+struct genl_multicast_group {
 	struct genl_family	*family;	/* private */
 	struct list_head	list;		/* private */
 	char			name[GENL_NAMSIZ];
@@ -35,8 +34,7 @@ struct genl_multicast_group
  * @family_list: family list
  * @mcast_groups: multicast groups list
  */
-struct genl_family
-{
+struct genl_family {
 	unsigned int		id;
 	unsigned int		hdrsize;
 	char			name[GENL_NAMSIZ];
@@ -58,8 +56,7 @@ struct genl_family
  * @userhdr: user specific header
  * @attrs: netlink attributes
  */
-struct genl_info
-{
+struct genl_info {
 	u32			snd_seq;
 	u32			snd_pid;
 	struct nlmsghdr *	nlhdr;
@@ -102,8 +99,7 @@ static inline void genl_info_net_set(struct genl_inf=
o *info, struct net *net)
  * @done: completion callback for dumps
  * @ops_list: operations list
  */
-struct genl_ops
-{
+struct genl_ops {
 	u8			cmd;
 	unsigned int		flags;
 	const struct nla_policy	*policy;
diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index 38b7813..e9d69d1 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -32,8 +32,7 @@
=20
 #ifdef __KERNEL__
=20
-struct inet6_ifaddr=20
-{
+struct inet6_ifaddr {
 	struct in6_addr		addr;
 	__u32			prefix_len;
 =09
@@ -67,8 +66,7 @@ struct inet6_ifaddr
 	int			dead;
 };
=20
-struct ip6_sf_socklist
-{
+struct ip6_sf_socklist {
 	unsigned int		sl_max;
 	unsigned int		sl_count;
 	struct in6_addr		sl_addr[0];
@@ -79,8 +77,7 @@ struct ip6_sf_socklist
=20
 #define IP6_SFBLOCK	10	/* allocate this many at once */
=20
-struct ipv6_mc_socklist
-{
+struct ipv6_mc_socklist {
 	struct in6_addr		addr;
 	int			ifindex;
 	struct ipv6_mc_socklist *next;
@@ -89,8 +86,7 @@ struct ipv6_mc_socklist
 	struct ip6_sf_socklist	*sflist;
 };
=20
-struct ip6_sf_list
-{
+struct ip6_sf_list {
 	struct ip6_sf_list	*sf_next;
 	struct in6_addr		sf_addr;
 	unsigned long		sf_count[2];	/* include/exclude counts */
@@ -105,8 +101,7 @@ struct ip6_sf_list
 #define MAF_NOREPORT		0x08
 #define MAF_GSQUERY		0x10
=20
-struct ifmcaddr6
-{
+struct ifmcaddr6 {
 	struct in6_addr		mca_addr;
 	struct inet6_dev	*idev;
 	struct ifmcaddr6	*next;
@@ -126,15 +121,13 @@ struct ifmcaddr6
=20
 /* Anycast stuff */
=20
-struct ipv6_ac_socklist
-{
+struct ipv6_ac_socklist {
 	struct in6_addr		acl_addr;
 	int			acl_ifindex;
 	struct ipv6_ac_socklist *acl_next;
 };
=20
-struct ifacaddr6
-{
+struct ifacaddr6 {
 	struct in6_addr		aca_addr;
 	struct inet6_dev	*aca_idev;
 	struct rt6_info		*aca_rt;
@@ -157,8 +150,7 @@ struct ipv6_devstat {
 	DEFINE_SNMP_STAT(struct icmpv6msg_mib, icmpv6msg);
 };
=20
-struct inet6_dev=20
-{
+struct inet6_dev {
 	struct net_device		*dev;
=20
 	struct inet6_ifaddr	*addr_list;
diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index 15e1f8f..35ad7b9 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -13,8 +13,7 @@
 #include <linux/spinlock.h>
 #include <asm/atomic.h>
=20
-struct inet_peer
-{
+struct inet_peer {
 	/* group together avl_left,avl_right,v4daddr to speedup lookups */
 	struct inet_peer	*avl_left, *avl_right;
 	__be32			v4daddr;	/* peer's address */
diff --git a/include/net/ip.h b/include/net/ip.h
index 376adf4..e6b9d12 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -33,8 +33,7 @@
=20
 struct sock;
=20
-struct inet_skb_parm
-{
+struct inet_skb_parm {
 	struct ip_options	opt;		/* Compiled IP options		*/
 	unsigned char		flags;
=20
@@ -50,8 +49,7 @@ static inline unsigned int ip_hdrlen(const struct sk_=
buff *skb)
 	return ip_hdr(skb)->ihl * 4;
 }
=20
-struct ipcm_cookie
-{
+struct ipcm_cookie {
 	__be32			addr;
 	int			oif;
 	struct ip_options	*opt;
@@ -60,8 +58,7 @@ struct ipcm_cookie
=20
 #define IPCB(skb) ((struct inet_skb_parm*)((skb)->cb))
=20
-struct ip_ra_chain
-{
+struct ip_ra_chain {
 	struct ip_ra_chain	*next;
 	struct sock		*sk;
 	void			(*destructor)(struct sock *);
@@ -159,8 +156,7 @@ static inline __u8 ip_reply_arg_flowi_flags(const s=
truct ip_reply_arg *arg)
 void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_rep=
ly_arg *arg,
 		   unsigned int len);=20
=20
-struct ipv4_config
-{
+struct ipv4_config {
 	int	log_martians;
 	int	no_pmtu_disc;
 };
@@ -336,8 +332,7 @@ extern int	ip_call_ra_chain(struct sk_buff *skb);
  *	Functions provided by ip_fragment.c
  */
=20
-enum ip_defrag_users
-{
+enum ip_defrag_users {
 	IP_DEFRAG_LOCAL_DELIVER,
 	IP_DEFRAG_CALL_RA_CHAIN,
 	IP_DEFRAG_CONNTRACK_IN,
diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 15b492a..2578081 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -30,8 +30,7 @@
=20
 struct rt6_info;
=20
-struct fib6_config
-{
+struct fib6_config {
 	u32		fc_table;
 	u32		fc_metric;
 	int		fc_dst_len;
@@ -51,8 +50,7 @@ struct fib6_config
 	struct nl_info	fc_nlinfo;
 };
=20
-struct fib6_node
-{
+struct fib6_node {
 	struct fib6_node	*parent;
 	struct fib6_node	*left;
 	struct fib6_node	*right;
@@ -78,16 +76,14 @@ struct fib6_node
  *
  */
=20
-struct rt6key
-{
+struct rt6key {
 	struct in6_addr	addr;
 	int		plen;
 };
=20
 struct fib6_table;
=20
-struct rt6_info
-{
+struct rt6_info {
 	union {
 		struct dst_entry	dst;
 	} u;
@@ -127,8 +123,7 @@ static inline struct inet6_dev *ip6_dst_idev(struct=
 dst_entry *dst)
 	return ((struct rt6_info *)dst)->rt6i_idev;
 }
=20
-struct fib6_walker_t
-{
+struct fib6_walker_t {
 	struct fib6_walker_t *prev, *next;
 	struct fib6_node *root, *node;
 	struct rt6_info *leaf;
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 0e1b8ae..4a808de 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -103,8 +103,7 @@ extern void			rt6_pmtu_discovery(struct in6_addr *d=
addr,
=20
 struct netlink_callback;
=20
-struct rt6_rtnl_dump_arg
-{
+struct rt6_rtnl_dump_arg {
 	struct sk_buff *skb;
 	struct netlink_callback *cb;
 	struct net *net;
diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 98978e7..8dc3296 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -251,8 +251,7 @@ struct ip_vs_estimator {
 	u32			outbps;
 };
=20
-struct ip_vs_stats
-{
+struct ip_vs_stats {
 	struct ip_vs_stats_user	ustats;         /* statistics */
 	struct ip_vs_estimator	est;		/* estimator */
=20
@@ -518,8 +517,7 @@ struct ip_vs_scheduler {
 /*
  *	The application module object (a.k.a. app incarnation)
  */
-struct ip_vs_app
-{
+struct ip_vs_app {
 	struct list_head	a_list;		/* member in app list */
 	int			type;		/* IP_VS_APP_TYPE_xxx */
 	char			*name;		/* application module name */
diff --git a/include/net/ipip.h b/include/net/ipip.h
index b3db2fd..11e8513 100644
--- a/include/net/ipip.h
+++ b/include/net/ipip.h
@@ -8,16 +8,14 @@
 #define IPTUNNEL_ERR_TIMEO	(30*HZ)
=20
 /* 6rd prefix/relay information */
-struct ip_tunnel_6rd_parm
-{
+struct ip_tunnel_6rd_parm {
 	struct in6_addr		prefix;
 	__be32			relay_prefix;
 	u16			prefixlen;
 	u16			relay_prefixlen;
 };
=20
-struct ip_tunnel
-{
+struct ip_tunnel {
 	struct ip_tunnel	*next;
 	struct net_device	*dev;
=20
@@ -40,8 +38,7 @@ struct ip_tunnel
 	unsigned int			prl_count;	/* # of entries in PRL */
 };
=20
-struct ip_tunnel_prl_entry
-{
+struct ip_tunnel_prl_entry {
 	struct ip_tunnel_prl_entry	*next;
 	__be32				addr;
 	u16				flags;
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 8c31d8a..92db861 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -160,8 +160,7 @@ extern struct ctl_path net_ipv6_ctl_path[];
 #define ICMP6MSGIN_INC_STATS_BH(net, idev, field)	\
 	_DEVINC(net, icmpv6msg, _BH, idev, field)
=20
-struct ip6_ra_chain
-{
+struct ip6_ra_chain {
 	struct ip6_ra_chain	*next;
 	struct sock		*sk;
 	int			sel;
@@ -176,8 +175,7 @@ extern rwlock_t ip6_ra_lock;
    ancillary data and passed to IPv6.
  */
=20
-struct ipv6_txoptions
-{
+struct ipv6_txoptions {
 	/* Length of this structure */
 	int			tot_len;
=20
@@ -194,8 +192,7 @@ struct ipv6_txoptions
 	/* Option buffer, as read by IPV6_PKTOPTIONS, starts here. */
 };
=20
-struct ip6_flowlabel
-{
+struct ip6_flowlabel {
 	struct ip6_flowlabel	*next;
 	__be32			label;
 	atomic_t		users;
@@ -212,8 +209,7 @@ struct ip6_flowlabel
 #define IPV6_FLOWINFO_MASK	cpu_to_be32(0x0FFFFFFF)
 #define IPV6_FLOWLABEL_MASK	cpu_to_be32(0x000FFFFF)
=20
-struct ipv6_fl_socklist
-{
+struct ipv6_fl_socklist {
 	struct ipv6_fl_socklist	*next;
 	struct ip6_flowlabel	*fl;
 };
diff --git a/include/net/iw_handler.h b/include/net/iw_handler.h
index d5d3371..b2b98f3 100644
--- a/include/net/iw_handler.h
+++ b/include/net/iw_handler.h
@@ -300,8 +300,7 @@
  * This struct is also my long term insurance. I can add new fields he=
re
  * without breaking the prototype of iw_handler...
  */
-struct iw_request_info
-{
+struct iw_request_info {
 	__u16		cmd;		/* Wireless Extension command */
 	__u16		flags;		/* More to come ;-) */
 };
@@ -321,8 +320,7 @@ typedef int (*iw_handler)(struct net_device *dev, s=
truct iw_request_info *info,
  * shared by all driver instances... Same for the members...
  * This will be linked from net_device in <linux/netdevice.h>
  */
-struct iw_handler_def
-{
+struct iw_handler_def {
=20
 	/* Array of handlers for standard ioctls
 	 * We will call dev->wireless_handlers->standard[ioctl - SIOCSIWCOMMI=
T]
@@ -372,8 +370,7 @@ struct iw_handler_def
 /*
  * Describe how a standard IOCTL looks like.
  */
-struct iw_ioctl_description
-{
+struct iw_ioctl_description {
 	__u8	header_type;		/* NULL, iw_point or other */
 	__u8	token_type;		/* Future */
 	__u16	token_size;		/* Granularity of payload */
@@ -395,8 +392,7 @@ struct iw_ioctl_description
 /*
  * Instance specific spy data, i.e. addresses spied and quality for th=
em.
  */
-struct iw_spy_data
-{
+struct iw_spy_data {
 	/* --- Standard spy support --- */
 	int			spy_number;
 	u_char			spy_address[IW_MAX_SPY][ETH_ALEN];
diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 3817fda..db8e96d 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -37,8 +37,7 @@
=20
 struct neighbour;
=20
-struct neigh_parms
-{
+struct neigh_parms {
 #ifdef CONFIG_NET_NS
 	struct net *net;
 #endif
@@ -70,8 +69,7 @@ struct neigh_parms
 	int	locktime;
 };
=20
-struct neigh_statistics
-{
+struct neigh_statistics {
 	unsigned long allocs;		/* number of allocated neighs */
 	unsigned long destroys;		/* number of destroyed neighs */
 	unsigned long hash_grows;	/* number of hash resizes */
@@ -97,8 +95,7 @@ struct neigh_statistics
 		preempt_enable();					\
 	} while (0)
=20
-struct neighbour
-{
+struct neighbour {
 	struct neighbour	*next;
 	struct neigh_table	*tbl;
 	struct neigh_parms	*parms;
@@ -122,8 +119,7 @@ struct neighbour
 	u8			primary_key[0];
 };
=20
-struct neigh_ops
-{
+struct neigh_ops {
 	int			family;
 	void			(*solicit)(struct neighbour *, struct sk_buff*);
 	void			(*error_report)(struct neighbour *, struct sk_buff*);
@@ -133,8 +129,7 @@ struct neigh_ops
 	int			(*queue_xmit)(struct sk_buff*);
 };
=20
-struct pneigh_entry
-{
+struct pneigh_entry {
 	struct pneigh_entry	*next;
 #ifdef CONFIG_NET_NS
 	struct net		*net;
@@ -149,8 +144,7 @@ struct pneigh_entry
  */
=20
=20
-struct neigh_table
-{
+struct neigh_table {
 	struct neigh_table	*next;
 	int			family;
 	int			entry_size;
diff --git a/include/net/netfilter/nf_conntrack_ecache.h b/include/net/=
netfilter/nf_conntrack_ecache.h
index 4f20d58..475facc 100644
--- a/include/net/netfilter/nf_conntrack_ecache.h
+++ b/include/net/netfilter/nf_conntrack_ecache.h
@@ -13,8 +13,7 @@
 #include <net/netfilter/nf_conntrack_extend.h>
=20
 /* Connection tracking event types */
-enum ip_conntrack_events
-{
+enum ip_conntrack_events {
 	IPCT_NEW		=3D 0,	/* new conntrack */
 	IPCT_RELATED		=3D 1,	/* related conntrack */
 	IPCT_DESTROY		=3D 2,	/* destroyed conntrack */
diff --git a/include/net/netfilter/nf_conntrack_expect.h b/include/net/=
netfilter/nf_conntrack_expect.h
index a965280..9a2b9cb 100644
--- a/include/net/netfilter/nf_conntrack_expect.h
+++ b/include/net/netfilter/nf_conntrack_expect.h
@@ -9,8 +9,7 @@
 extern unsigned int nf_ct_expect_hsize;
 extern unsigned int nf_ct_expect_max;
=20
-struct nf_conntrack_expect
-{
+struct nf_conntrack_expect {
 	/* Conntrack expectation list member */
 	struct hlist_node lnode;
=20
@@ -64,8 +63,7 @@ static inline struct net *nf_ct_exp_net(struct nf_con=
ntrack_expect *exp)
 #endif
 }
=20
-struct nf_conntrack_expect_policy
-{
+struct nf_conntrack_expect_policy {
 	unsigned int	max_expected;
 	unsigned int	timeout;
 };
diff --git a/include/net/netfilter/nf_conntrack_extend.h b/include/net/=
netfilter/nf_conntrack_extend.h
index 7f8fc5d..e192dc1 100644
--- a/include/net/netfilter/nf_conntrack_extend.h
+++ b/include/net/netfilter/nf_conntrack_extend.h
@@ -3,8 +3,7 @@
=20
 #include <net/netfilter/nf_conntrack.h>
=20
-enum nf_ct_ext_id
-{
+enum nf_ct_ext_id {
 	NF_CT_EXT_HELPER,
 	NF_CT_EXT_NAT,
 	NF_CT_EXT_ACCT,
@@ -65,8 +64,7 @@ __nf_ct_ext_add(struct nf_conn *ct, enum nf_ct_ext_id=
 id, gfp_t gfp);
=20
 #define NF_CT_EXT_F_PREALLOC	0x0001
=20
-struct nf_ct_ext_type
-{
+struct nf_ct_ext_type {
 	/* Destroys relationships (can be NULL). */
 	void (*destroy)(struct nf_conn *ct);
 	/* Called when realloacted (can be NULL).
diff --git a/include/net/netfilter/nf_conntrack_helper.h b/include/net/=
netfilter/nf_conntrack_helper.h
index 1b70680..d015de9 100644
--- a/include/net/netfilter/nf_conntrack_helper.h
+++ b/include/net/netfilter/nf_conntrack_helper.h
@@ -16,8 +16,7 @@ struct module;
=20
 #define NF_CT_HELPER_NAME_LEN	16
=20
-struct nf_conntrack_helper
-{
+struct nf_conntrack_helper {
 	struct hlist_node hnode;	/* Internal use. */
=20
 	const char *name;		/* name of the module */
diff --git a/include/net/netfilter/nf_conntrack_l3proto.h b/include/net=
/netfilter/nf_conntrack_l3proto.h
index 9f99d36..a754761 100644
--- a/include/net/netfilter/nf_conntrack_l3proto.h
+++ b/include/net/netfilter/nf_conntrack_l3proto.h
@@ -16,8 +16,7 @@
 #include <linux/seq_file.h>
 #include <net/netfilter/nf_conntrack.h>
=20
-struct nf_conntrack_l3proto
-{
+struct nf_conntrack_l3proto {
 	/* L3 Protocol Family number. ex) PF_INET */
 	u_int16_t l3proto;
=20
diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net=
/netfilter/nf_conntrack_l4proto.h
index 3767fb4..ca6dcf3 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -15,8 +15,7 @@
=20
 struct seq_file;
=20
-struct nf_conntrack_l4proto
-{
+struct nf_conntrack_l4proto {
 	/* L3 Protocol number. */
 	u_int16_t l3proto;
=20
diff --git a/include/net/netfilter/nf_conntrack_tuple.h b/include/net/n=
etfilter/nf_conntrack_tuple.h
index 2628c15..4ee44c8 100644
--- a/include/net/netfilter/nf_conntrack_tuple.h
+++ b/include/net/netfilter/nf_conntrack_tuple.h
@@ -26,8 +26,7 @@
=20
 /* The protocol-specific manipulable parts of the tuple: always in
    network order! */
-union nf_conntrack_man_proto
-{
+union nf_conntrack_man_proto {
 	/* Add other protocols here. */
 	__be16 all;
=20
@@ -52,8 +51,7 @@ union nf_conntrack_man_proto
 };
=20
 /* The manipulable part of the tuple. */
-struct nf_conntrack_man
-{
+struct nf_conntrack_man {
 	union nf_inet_addr u3;
 	union nf_conntrack_man_proto u;
 	/* Layer 3 protocol */
@@ -61,8 +59,7 @@ struct nf_conntrack_man
 };
=20
 /* This contains the information to distinguish a connection. */
-struct nf_conntrack_tuple
-{
+struct nf_conntrack_tuple {
 	struct nf_conntrack_man src;
=20
 	/* These are the parts of the tuple which are fixed. */
@@ -100,8 +97,7 @@ struct nf_conntrack_tuple
 	} dst;
 };
=20
-struct nf_conntrack_tuple_mask
-{
+struct nf_conntrack_tuple_mask {
 	struct {
 		union nf_inet_addr u3;
 		union nf_conntrack_man_proto u;
diff --git a/include/net/netfilter/nf_nat.h b/include/net/netfilter/nf_=
nat.h
index 8df0b7f..f5f09f0 100644
--- a/include/net/netfilter/nf_nat.h
+++ b/include/net/netfilter/nf_nat.h
@@ -5,8 +5,7 @@
=20
 #define NF_NAT_MAPPING_TYPE_MAX_NAMELEN 16
=20
-enum nf_nat_manip_type
-{
+enum nf_nat_manip_type {
 	IP_NAT_MANIP_SRC,
 	IP_NAT_MANIP_DST
 };
@@ -30,8 +29,7 @@ struct nf_nat_seq {
 };
=20
 /* Single range specification. */
-struct nf_nat_range
-{
+struct nf_nat_range {
 	/* Set to OR of flags above. */
 	unsigned int flags;
=20
@@ -43,8 +41,7 @@ struct nf_nat_range
 };
=20
 /* For backwards compat: don't use in modern code. */
-struct nf_nat_multi_range_compat
-{
+struct nf_nat_multi_range_compat {
 	unsigned int rangesize; /* Must be 1. */
=20
 	/* hangs off end. */
@@ -57,8 +54,7 @@ struct nf_nat_multi_range_compat
 #include <net/netfilter/nf_conntrack_extend.h>
=20
 /* per conntrack: nat application helper private data */
-union nf_conntrack_nat_help
-{
+union nf_conntrack_nat_help {
 	/* insert nat helper private data here */
 	struct nf_nat_pptp nat_pptp_info;
 };
@@ -66,8 +62,7 @@ union nf_conntrack_nat_help
 struct nf_conn;
=20
 /* The structure embedded in the conntrack structure. */
-struct nf_conn_nat
-{
+struct nf_conn_nat {
 	struct hlist_node bysource;
 	struct nf_nat_seq seq[IP_CT_DIR_MAX];
 	struct nf_conn *ct;
diff --git a/include/net/netfilter/nf_nat_protocol.h b/include/net/netf=
ilter/nf_nat_protocol.h
index f3662c4..c398017 100644
--- a/include/net/netfilter/nf_nat_protocol.h
+++ b/include/net/netfilter/nf_nat_protocol.h
@@ -6,8 +6,7 @@
=20
 struct nf_nat_range;
=20
-struct nf_nat_protocol
-{
+struct nf_nat_protocol {
 	/* Protocol number. */
 	unsigned int protonum;
=20
diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index d1ca314..3dd210d 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -7,8 +7,7 @@
=20
 /* Basic packet classifier frontend definitions. */
=20
-struct tcf_walker
-{
+struct tcf_walker {
 	int	stop;
 	int	skip;
 	int	count;
@@ -61,8 +60,7 @@ tcf_unbind_filter(struct tcf_proto *tp, struct tcf_re=
sult *r)
 		tp->q->ops->cl_ops->unbind_tcf(tp->q, cl);
 }
=20
-struct tcf_exts
-{
+struct tcf_exts {
 #ifdef CONFIG_NET_CLS_ACT
 	struct tc_action *action;
 #endif
@@ -71,8 +69,7 @@ struct tcf_exts
 /* Map to export classifier specific extension TLV types to the
  * generic extensions API. Unsupported extensions must be set to 0.
  */
-struct tcf_ext_map
-{
+struct tcf_ext_map {
 	int action;
 	int police;
 };
@@ -143,8 +140,7 @@ extern int tcf_exts_dump_stats(struct sk_buff *skb,=
 struct tcf_exts *exts,
 /**
  * struct tcf_pkt_info - packet information
  */
-struct tcf_pkt_info
-{
+struct tcf_pkt_info {
 	unsigned char *		ptr;
 	int			nexthdr;
 };
@@ -162,8 +158,7 @@ struct tcf_ematch_ops;
  * @datalen: length of the ematch specific configuration data
  * @data: ematch specific data
  */
-struct tcf_ematch
-{
+struct tcf_ematch {
 	struct tcf_ematch_ops * ops;
 	unsigned long		data;
 	unsigned int		datalen;
@@ -211,8 +206,7 @@ static inline int tcf_em_early_end(struct tcf_ematc=
h *em, int result)
  * @hdr: ematch tree header supplied by userspace
  * @matches: array of ematches
  */
-struct tcf_ematch_tree
-{
+struct tcf_ematch_tree {
 	struct tcf_ematch_tree_hdr hdr;
 	struct tcf_ematch *	matches;
 =09
@@ -230,8 +224,7 @@ struct tcf_ematch_tree
  * @owner: owner, must be set to THIS_MODULE
  * @link: link to previous/next ematch module (internal use)
  */
-struct tcf_ematch_ops
-{
+struct tcf_ematch_ops {
 	int			kind;
 	int			datalen;
 	int			(*change)(struct tcf_proto *, void *,
@@ -302,8 +295,7 @@ static inline int tcf_em_tree_match(struct sk_buff =
*skb,
=20
 #else /* CONFIG_NET_EMATCH */
=20
-struct tcf_ematch_tree
-{
+struct tcf_ematch_tree {
 };
=20
 #define tcf_em_tree_validate(tp, tb, t) ((void)(t), 0)
diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index f911ec7..2d56726 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -5,8 +5,7 @@
 #include <linux/ktime.h>
 #include <net/sch_generic.h>
=20
-struct qdisc_walker
-{
+struct qdisc_walker {
 	int	stop;
 	int	skip;
 	int	count;
diff --git a/include/net/protocol.h b/include/net/protocol.h
index 60249e5..89932d4 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -47,8 +47,7 @@ struct net_protocol {
 };
=20
 #if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
-struct inet6_protocol=20
-{
+struct inet6_protocol {
 	int	(*handler)(struct sk_buff *skb);
=20
 	void	(*err_handler)(struct sk_buff *skb,
diff --git a/include/net/red.h b/include/net/red.h
index 3cf31d4..995108e 100644
--- a/include/net/red.h
+++ b/include/net/red.h
@@ -90,8 +90,7 @@
 #define RED_STAB_SIZE	256
 #define RED_STAB_MASK	(RED_STAB_SIZE - 1)
=20
-struct red_stats
-{
+struct red_stats {
 	u32		prob_drop;	/* Early probability drops */
 	u32		prob_mark;	/* Early probability marks */
 	u32		forced_drop;	/* Forced drops, qavg > max_thresh */
@@ -101,8 +100,7 @@ struct red_stats
 	u32		backlog;
 };
=20
-struct red_parms
-{
+struct red_parms {
 	/* Parameters */
 	u32		qth_min;	/* Min avg length threshold: A scaled */
 	u32		qth_max;	/* Max avg length threshold: A scaled */
diff --git a/include/net/route.h b/include/net/route.h
index 40f6346..cfb4c07 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -49,10 +49,8 @@
=20
 struct fib_nh;
 struct inet_peer;
-struct rtable
-{
-	union
-	{
+struct rtable {
+	union {
 		struct dst_entry	dst;
 	} u;
=20
@@ -77,16 +75,14 @@ struct rtable
 	struct inet_peer	*peer; /* long-living peer info */
 };
=20
-struct ip_rt_acct
-{
+struct ip_rt_acct {
 	__u32 	o_bytes;
 	__u32 	o_packets;
 	__u32 	i_bytes;
 	__u32 	i_packets;
 };
=20
-struct rt_cache_stat=20
-{
+struct rt_cache_stat {
         unsigned int in_hit;
         unsigned int in_slow_tot;
         unsigned int in_slow_mc;
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index c33180d..dad558b 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -15,16 +15,14 @@ struct qdisc_walker;
 struct tcf_walker;
 struct module;
=20
-struct qdisc_rate_table
-{
+struct qdisc_rate_table {
 	struct tc_ratespec rate;
 	u32		data[256];
 	struct qdisc_rate_table *next;
 	int		refcnt;
 };
=20
-enum qdisc_state_t
-{
+enum qdisc_state_t {
 	__QDISC_STATE_RUNNING,
 	__QDISC_STATE_SCHED,
 	__QDISC_STATE_DEACTIVATED,
@@ -37,8 +35,7 @@ struct qdisc_size_table {
 	u16			data[];
 };
=20
-struct Qdisc
-{
+struct Qdisc {
 	int 			(*enqueue)(struct sk_buff *skb, struct Qdisc *dev);
 	struct sk_buff *	(*dequeue)(struct Qdisc *dev);
 	unsigned		flags;
@@ -78,8 +75,7 @@ struct Qdisc
 	struct gnet_stats_queue	qstats;
 };
=20
-struct Qdisc_class_ops
-{
+struct Qdisc_class_ops {
 	/* Child qdisc manipulation */
 	struct netdev_queue *	(*select_queue)(struct Qdisc *, struct tcmsg *)=
;
 	int			(*graft)(struct Qdisc *, unsigned long cl,
@@ -108,8 +104,7 @@ struct Qdisc_class_ops
 					struct gnet_dump *);
 };
=20
-struct Qdisc_ops
-{
+struct Qdisc_ops {
 	struct Qdisc_ops	*next;
 	const struct Qdisc_class_ops	*cl_ops;
 	char			id[IFNAMSIZ];
@@ -133,14 +128,12 @@ struct Qdisc_ops
 };
=20
=20
-struct tcf_result
-{
+struct tcf_result {
 	unsigned long	class;
 	u32		classid;
 };
=20
-struct tcf_proto_ops
-{
+struct tcf_proto_ops {
 	struct tcf_proto_ops	*next;
 	char			kind[IFNAMSIZ];
=20
@@ -164,8 +157,7 @@ struct tcf_proto_ops
 	struct module		*owner;
 };
=20
-struct tcf_proto
-{
+struct tcf_proto {
 	/* Fast access part */
 	struct tcf_proto	*next;
 	void			*root;
@@ -261,14 +253,12 @@ extern struct Qdisc_ops noop_qdisc_ops;
 extern struct Qdisc_ops pfifo_fast_ops;
 extern struct Qdisc_ops mq_qdisc_ops;
=20
-struct Qdisc_class_common
-{
+struct Qdisc_class_common {
 	u32			classid;
 	struct hlist_node	hnode;
 };
=20
-struct Qdisc_class_hash
-{
+struct Qdisc_class_hash {
 	struct hlist_head	*hash;
 	unsigned int		hashsize;
 	unsigned int		hashmask;
diff --git a/include/net/scm.h b/include/net/scm.h
index cf48c80..8360e47 100644
--- a/include/net/scm.h
+++ b/include/net/scm.h
@@ -12,15 +12,13 @@
  */
 #define SCM_MAX_FD	255
=20
-struct scm_fp_list
-{
+struct scm_fp_list {
 	struct list_head	list;
 	int			count;
 	struct file		*fp[SCM_MAX_FD];
 };
=20
-struct scm_cookie
-{
+struct scm_cookie {
 	struct ucred		creds;		/* Skb credentials	*/
 	struct scm_fp_list	*fp;		/* Passed files		*/
 #ifdef CONFIG_SECURITY_NETWORK
@@ -88,8 +86,7 @@ static inline void scm_passec(struct socket *sock, st=
ruct msghdr *msg, struct sc
 static __inline__ void scm_recv(struct socket *sock, struct msghdr *ms=
g,
 				struct scm_cookie *scm, int flags)
 {
-	if (!msg->msg_control)
-	{
+	if (!msg->msg_control) {
 		if (test_bit(SOCK_PASSCRED, &sock->flags) || scm->fp)
 			msg->msg_flags |=3D MSG_CTRUNC;
 		scm_destroy(scm);
diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 8a6d529..78740ec 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -227,8 +227,7 @@ DECLARE_SNMP_STAT(struct sctp_mib, sctp_statistics)=
;
 #endif /* !TEST_FRAME */
=20
 /* sctp mib definitions */
-enum
-{
+enum {
 	SCTP_MIB_NUM =3D 0,
 	SCTP_MIB_CURRESTAB,			/* CurrEstab */
 	SCTP_MIB_ACTIVEESTABS,			/* ActiveEstabs */
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 740d09b..bf20f88 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -359,8 +359,7 @@ TCP_ECN_create_request(struct request_sock *req, st=
ruct tcphdr *th)
 		inet_rsk(req)->ecn_ok =3D 1;
 }
=20
-enum tcp_tw_status
-{
+enum tcp_tw_status {
 	TCP_TW_SUCCESS =3D 0,
 	TCP_TW_RST =3D 1,
 	TCP_TW_ACK =3D 2,
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index d9c6dbb..6d55b36 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -121,8 +121,7 @@ struct xfrm_state_walk {
 };
=20
 /* Full description of state of transformer. */
-struct xfrm_state
-{
+struct xfrm_state {
 #ifdef CONFIG_NET_NS
 	struct net		*xs_net;
 #endif
@@ -237,8 +236,7 @@ enum {
 };
=20
 /* callback structure passed from either netlink or pfkey */
-struct km_event
-{
+struct km_event {
 	union {
 		u32 hard;
 		u32 proto;
@@ -313,8 +311,7 @@ extern int xfrm_state_unregister_afinfo(struct xfrm=
_state_afinfo *afinfo);
=20
 extern void xfrm_state_delete_tunnel(struct xfrm_state *x);
=20
-struct xfrm_type
-{
+struct xfrm_type {
 	char			*description;
 	struct module		*owner;
 	__u8			proto;
@@ -420,8 +417,7 @@ static inline struct xfrm_mode *xfrm_ip2inner_mode(=
struct xfrm_state *x, int ipp
 		return x->inner_mode_iaf;
 }
=20
-struct xfrm_tmpl
-{
+struct xfrm_tmpl {
 /* id in template is interpreted as:
  * daddr - destination of tunnel, may be zero for transport mode.
  * spi   - zero to acquire spi. Not zero if spi is static, then
@@ -468,8 +464,7 @@ struct xfrm_policy_walk {
 	u32 seq;
 };
=20
-struct xfrm_policy
-{
+struct xfrm_policy {
 #ifdef CONFIG_NET_NS
 	struct net		*xp_net;
 #endif
@@ -538,8 +533,7 @@ struct xfrm_migrate {
 /* default seq threshold size */
 #define XFRM_AE_SEQT_SIZE		2
=20
-struct xfrm_mgr
-{
+struct xfrm_mgr {
 	struct list_head	list;
 	char			*id;
 	int			(*notify)(struct xfrm_state *x, struct km_event *c);
@@ -626,8 +620,7 @@ struct xfrm_spi_skb_cb {
 #define XFRM_SPI_SKB_CB(__skb) ((struct xfrm_spi_skb_cb *)&((__skb)->c=
b[0]))
=20
 /* Audit Information */
-struct xfrm_audit
-{
+struct xfrm_audit {
 	u32	secid;
 	uid_t	loginuid;
 	u32	sessionid;
@@ -871,8 +864,7 @@ static inline int xfrm_sec_ctx_match(struct xfrm_se=
c_ctx *s1, struct xfrm_sec_ct
  * bundles differing by session id. All the bundles grow from a parent
  * policy rule.
  */
-struct xfrm_dst
-{
+struct xfrm_dst {
 	union {
 		struct dst_entry	dst;
 		struct rtable		rt;
@@ -907,8 +899,7 @@ static inline void xfrm_dst_destroy(struct xfrm_dst=
 *xdst)
=20
 extern void xfrm_dst_ifdown(struct dst_entry *dst, struct net_device *=
dev);
=20
-struct sec_path
-{
+struct sec_path {
 	atomic_t		refcnt;
 	int			len;
 	struct xfrm_state	*xvec[XFRM_MAX_DEPTH];
