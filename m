From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: cleanup include/linux
Date: Wed, 04 Nov 2009 18:48:11 +0100
Message-ID: <4AF1BE5B.2080208@gmail.com>
References: <4AF0031B.4060708@gmail.com>	<20091103.024424.146854177.davem@davemloft.net>	<4AF02F6B.6040405@gmail.com> <20091104.050746.126372138.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:43797 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751196AbZKDRsM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 12:48:12 -0500
In-Reply-To: <20091104.050746.126372138.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, here is the second patch, for include/linux/ files
that 'belong' to network stacks.

Thanks


[PATCH net-next-2.6] net: cleanup include/linux

This cleanup patch puts struct/union/enum opening braces,
in first line to ease grep games.

struct something
{

becomes :

struct something {

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/dn.h                             |    9 -
 include/linux/errqueue.h                       |    6 
 include/linux/fib_rules.h                      |    9 -
 include/linux/filter.h                         |    6 
 include/linux/gen_stats.h                      |   15 --
 include/linux/if.h                             |   15 --
 include/linux/if_addr.h                        |    9 -
 include/linux/if_addrlabel.h                   |    6 
 include/linux/if_arcnet.h                      |   18 --
 include/linux/if_arp.h                         |    3 
 include/linux/if_bonding.h                     |    3 
 include/linux/if_bridge.h                      |    9 -
 include/linux/if_ec.h                          |   12 -
 include/linux/if_fddi.h                        |   22 +-
 include/linux/if_hippi.h                       |   15 --
 include/linux/if_link.h                        |   27 +--
 include/linux/if_packet.h                      |   27 +--
 include/linux/if_plip.h                        |    3 
 include/linux/if_pppol2tp.h                    |    3 
 include/linux/if_tunnel.h                      |    6 
 include/linux/igmp.h                           |   15 --
 include/linux/in.h                             |   18 --
 include/linux/in6.h                            |    9 -
 include/linux/inetdevice.h                     |    9 -
 include/linux/ip_vs.h                          |    3 
 include/linux/mroute.h                         |   18 --
 include/linux/mroute6.h                        |   15 --
 include/linux/neighbour.h                      |   18 --
 include/linux/netdevice.h                      |   30 +---
 include/linux/netfilter.h                      |    6 
 include/linux/netfilter/nf_conntrack_common.h  |    6 
 include/linux/netfilter/nf_conntrack_ftp.h     |    3 
 include/linux/netfilter/nf_conntrack_sctp.h    |    3 
 include/linux/netfilter/nf_conntrack_tcp.h     |    3 
 include/linux/netfilter/nfnetlink.h            |    6 
 include/linux/netfilter/nfnetlink_compat.h     |    3 
 include/linux/netfilter/x_tables.h             |   45 ++----
 include/linux/netfilter/xt_connbytes.h         |    3 
 include/linux/netfilter/xt_esp.h               |    3 
 include/linux/netfilter/xt_multiport.h         |    9 -
 include/linux/netfilter/xt_policy.h            |   18 --
 include/linux/netfilter/xt_state.h             |    3 
 include/linux/netfilter/xt_string.h            |    3 
 include/linux/netfilter/xt_tcpudp.h            |    6 
 include/linux/netfilter_arp/arp_tables.h       |   21 --
 include/linux/netfilter_bridge/ebt_802_3.h     |    3 
 include/linux/netfilter_bridge/ebt_among.h     |    9 -
 include/linux/netfilter_bridge/ebt_arpreply.h  |    3 
 include/linux/netfilter_bridge/ebt_ip.h        |    3 
 include/linux/netfilter_bridge/ebt_ip6.h       |    3 
 include/linux/netfilter_bridge/ebt_limit.h     |    3 
 include/linux/netfilter_bridge/ebt_log.h       |    3 
 include/linux/netfilter_bridge/ebt_mark_m.h    |    3 
 include/linux/netfilter_bridge/ebt_mark_t.h    |    3 
 include/linux/netfilter_bridge/ebt_nat.h       |    3 
 include/linux/netfilter_bridge/ebt_pkttype.h   |    3 
 include/linux/netfilter_bridge/ebt_redirect.h  |    3 
 include/linux/netfilter_bridge/ebt_stp.h       |    6 
 include/linux/netfilter_bridge/ebtables.h      |   39 +----
 include/linux/netfilter_ipv4/ip_tables.h       |   27 +--
 include/linux/netfilter_ipv4/ipt_SAME.h        |    3 
 include/linux/netfilter_ipv4/ipt_ah.h          |    3 
 include/linux/netfilter_ipv6/ip6_tables.h      |   27 +--
 include/linux/netfilter_ipv6/ip6t_ah.h         |    3 
 include/linux/netfilter_ipv6/ip6t_frag.h       |    3 
 include/linux/netfilter_ipv6/ip6t_ipv6header.h |    3 
 include/linux/netfilter_ipv6/ip6t_mh.h         |    3 
 include/linux/netfilter_ipv6/ip6t_opts.h       |    3 
 include/linux/netfilter_ipv6/ip6t_rt.h         |    3 
 include/linux/netlink.h                        |   24 +--
 include/linux/pkt_cls.h                        |   84 +++--------
 include/linux/pkt_sched.h                      |  111 +++++----------
 include/linux/route.h                          |    3 
 include/linux/rtnetlink.h                      |   57 ++-----
 include/linux/skbuff.h                         |    3 
 include/linux/tc_act/tc_defact.h               |    6 
 include/linux/tc_act/tc_gact.h                 |    9 -
 include/linux/tc_act/tc_ipt.h                  |    3 
 include/linux/tc_act/tc_mirred.h               |    6 
 include/linux/tc_act/tc_nat.h                  |    6 
 include/linux/tc_act/tc_pedit.h                |    9 -
 include/linux/tc_ematch/tc_em_cmp.h            |    6 
 include/linux/tc_ematch/tc_em_meta.h           |   15 --
 include/linux/tc_ematch/tc_em_nbyte.h          |    3 
 include/linux/tc_ematch/tc_em_text.h           |    3 
 include/linux/tcp.h                            |    6 
 include/linux/xfrm.h                           |   27 +--
 87 files changed, 351 insertions(+), 694 deletions(-)

diff --git a/include/linux/dn.h b/include/linux/dn.h
index fe99908..9c50445 100644
--- a/include/linux/dn.h
+++ b/include/linux/dn.h
@@ -71,14 +71,12 @@
 /* Structures */
 
 
-struct dn_naddr 
-{
+struct dn_naddr {
 	__le16		a_len;
 	__u8 a_addr[DN_MAXADDL]; /* Two bytes little endian */
 };
 
-struct sockaddr_dn
-{
+struct sockaddr_dn {
 	__u16		sdn_family;
 	__u8		sdn_flags;
 	__u8		sdn_objnum;
@@ -101,8 +99,7 @@ struct optdata_dn {
         __u8   opt_data[16];   /* User data              */
 };
 
-struct accessdata_dn
-{
+struct accessdata_dn {
 	__u8		acc_accl;
 	__u8		acc_acc[DN_MAXACCL];
 	__u8 		acc_passl;
diff --git a/include/linux/errqueue.h b/include/linux/errqueue.h
index ec12cc7..034072c 100644
--- a/include/linux/errqueue.h
+++ b/include/linux/errqueue.h
@@ -3,8 +3,7 @@
 
 #include <linux/types.h>
 
-struct sock_extended_err
-{
+struct sock_extended_err {
 	__u32	ee_errno;	
 	__u8	ee_origin;
 	__u8	ee_type;
@@ -31,8 +30,7 @@ struct sock_extended_err
 
 #define SKB_EXT_ERR(skb) ((struct sock_exterr_skb *) ((skb)->cb))
 
-struct sock_exterr_skb
-{
+struct sock_exterr_skb {
 	union {
 		struct inet_skb_parm	h4;
 #if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
diff --git a/include/linux/fib_rules.h b/include/linux/fib_rules.h
index 87b606b..c7e5b70 100644
--- a/include/linux/fib_rules.h
+++ b/include/linux/fib_rules.h
@@ -13,8 +13,7 @@
 /* try to find source address in routing lookups */
 #define FIB_RULE_FIND_SADDR	0x00010000
 
-struct fib_rule_hdr
-{
+struct fib_rule_hdr {
 	__u8		family;
 	__u8		dst_len;
 	__u8		src_len;
@@ -28,8 +27,7 @@ struct fib_rule_hdr
 	__u32		flags;
 };
 
-enum
-{
+enum {
 	FRA_UNSPEC,
 	FRA_DST,	/* destination address */
 	FRA_SRC,	/* source address */
@@ -52,8 +50,7 @@ enum
 
 #define FRA_MAX (__FRA_MAX - 1)
 
-enum
-{
+enum {
 	FR_ACT_UNSPEC,
 	FR_ACT_TO_TBL,		/* Pass to fixed table */
 	FR_ACT_GOTO,		/* Jump to another rule */
diff --git a/include/linux/filter.h b/include/linux/filter.h
index bb3b435..29a0e3d 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -23,16 +23,14 @@
  *	the BPF code definitions which need to match so you can share filters
  */
  
-struct sock_filter	/* Filter block */
-{
+struct sock_filter {	/* Filter block */
 	__u16	code;   /* Actual filter code */
 	__u8	jt;	/* Jump true */
 	__u8	jf;	/* Jump false */
 	__u32	k;      /* Generic multiuse field */
 };
 
-struct sock_fprog	/* Required for SO_ATTACH_FILTER. */
-{
+struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
 	unsigned short		len;	/* Number of filter blocks */
 	struct sock_filter __user *filter;
 };
diff --git a/include/linux/gen_stats.h b/include/linux/gen_stats.h
index 710e901..552c8a0 100644
--- a/include/linux/gen_stats.h
+++ b/include/linux/gen_stats.h
@@ -18,13 +18,11 @@ enum {
  * @bytes: number of seen bytes
  * @packets: number of seen packets
  */
-struct gnet_stats_basic
-{
+struct gnet_stats_basic {
 	__u64	bytes;
 	__u32	packets;
 };
-struct gnet_stats_basic_packed
-{
+struct gnet_stats_basic_packed {
 	__u64	bytes;
 	__u32	packets;
 } __attribute__ ((packed));
@@ -34,8 +32,7 @@ struct gnet_stats_basic_packed
  * @bps: current byte rate
  * @pps: current packet rate
  */
-struct gnet_stats_rate_est
-{
+struct gnet_stats_rate_est {
 	__u32	bps;
 	__u32	pps;
 };
@@ -48,8 +45,7 @@ struct gnet_stats_rate_est
  * @requeues: number of requeues
  * @overlimits: number of enqueues over the limit
  */
-struct gnet_stats_queue
-{
+struct gnet_stats_queue {
 	__u32	qlen;
 	__u32	backlog;
 	__u32	drops;
@@ -62,8 +58,7 @@ struct gnet_stats_queue
  * @interval: sampling period
  * @ewma_log: the log of measurement window weight
  */
-struct gnet_estimator
-{
+struct gnet_estimator {
 	signed char	interval;
 	unsigned char	ewma_log;
 };
diff --git a/include/linux/if.h b/include/linux/if.h
index b9a6229..3b2a46b 100644
--- a/include/linux/if.h
+++ b/include/linux/if.h
@@ -125,8 +125,7 @@ enum {
  *	being very small might be worth keeping for clean configuration.
  */
 
-struct ifmap 
-{
+struct ifmap {
 	unsigned long mem_start;
 	unsigned long mem_end;
 	unsigned short base_addr; 
@@ -136,8 +135,7 @@ struct ifmap
 	/* 3 bytes spare */
 };
 
-struct if_settings
-{
+struct if_settings {
 	unsigned int type;	/* Type of physical device or protocol */
 	unsigned int size;	/* Size of the data allocated by the caller */
 	union {
@@ -161,8 +159,7 @@ struct if_settings
  * remainder may be interface specific.
  */
 
-struct ifreq 
-{
+struct ifreq {
 #define IFHWADDRLEN	6
 	union
 	{
@@ -211,11 +208,9 @@ struct ifreq
  * must know all networks accessible).
  */
 
-struct ifconf 
-{
+struct ifconf  {
 	int	ifc_len;			/* size of buffer	*/
-	union 
-	{
+	union {
 		char __user *ifcu_buf;
 		struct ifreq __user *ifcu_req;
 	} ifc_ifcu;
diff --git a/include/linux/if_addr.h b/include/linux/if_addr.h
index fd97404..23357ab 100644
--- a/include/linux/if_addr.h
+++ b/include/linux/if_addr.h
@@ -4,8 +4,7 @@
 #include <linux/types.h>
 #include <linux/netlink.h>
 
-struct ifaddrmsg
-{
+struct ifaddrmsg {
 	__u8		ifa_family;
 	__u8		ifa_prefixlen;	/* The prefix length		*/
 	__u8		ifa_flags;	/* Flags			*/
@@ -20,8 +19,7 @@ struct ifaddrmsg
  * but for point-to-point IFA_ADDRESS is DESTINATION address,
  * local address is supplied in IFA_LOCAL attribute.
  */
-enum
-{
+enum {
 	IFA_UNSPEC,
 	IFA_ADDRESS,
 	IFA_LOCAL,
@@ -47,8 +45,7 @@ enum
 #define IFA_F_TENTATIVE		0x40
 #define IFA_F_PERMANENT		0x80
 
-struct ifa_cacheinfo
-{
+struct ifa_cacheinfo {
 	__u32	ifa_prefered;
 	__u32	ifa_valid;
 	__u32	cstamp; /* created timestamp, hundredths of seconds */
diff --git a/include/linux/if_addrlabel.h b/include/linux/if_addrlabel.h
index 89571f6..54580c2 100644
--- a/include/linux/if_addrlabel.h
+++ b/include/linux/if_addrlabel.h
@@ -12,8 +12,7 @@
 
 #include <linux/types.h>
 
-struct ifaddrlblmsg
-{
+struct ifaddrlblmsg {
 	__u8		ifal_family;		/* Address family */
 	__u8		__ifal_reserved;	/* Reserved */
 	__u8		ifal_prefixlen;		/* Prefix length */
@@ -22,8 +21,7 @@ struct ifaddrlblmsg
 	__u32		ifal_seq;		/* sequence number */
 };
 
-enum
-{
+enum {
 	IFAL_ADDRESS = 1,
 	IFAL_LABEL = 2,
 	__IFAL_MAX
diff --git a/include/linux/if_arcnet.h b/include/linux/if_arcnet.h
index 0835deb..46e34bd 100644
--- a/include/linux/if_arcnet.h
+++ b/include/linux/if_arcnet.h
@@ -56,8 +56,7 @@
 /*
  * The RFC1201-specific components of an arcnet packet header.
  */
-struct arc_rfc1201
-{
+struct arc_rfc1201 {
     __u8  proto;		/* protocol ID field - varies		*/
     __u8  split_flag;	/* for use with split packets		*/
     __be16   sequence;		/* sequence number			*/
@@ -69,8 +68,7 @@ struct arc_rfc1201
 /*
  * The RFC1051-specific components.
  */
-struct arc_rfc1051
-{
+struct arc_rfc1051 {
     __u8 proto;		/* ARC_P_RFC1051_ARP/RFC1051_IP	*/
     __u8 payload[0];		/* 507 bytes			*/
 };
@@ -81,8 +79,7 @@ struct arc_rfc1051
  * The ethernet-encap-specific components.  We have a real ethernet header
  * and some data.
  */
-struct arc_eth_encap
-{
+struct arc_eth_encap {
     __u8 proto;		/* Always ARC_P_ETHER			*/
     struct ethhdr eth;		/* standard ethernet header (yuck!)	*/
     __u8 payload[0];		/* 493 bytes				*/
@@ -90,8 +87,7 @@ struct arc_eth_encap
 #define ETH_ENCAP_HDR_SIZE 14
 
 
-struct arc_cap
-{
+struct arc_cap {
 	__u8 proto;
 	__u8 cookie[sizeof(int)];   /* Actually NOT sent over the network */
 	union {
@@ -108,8 +104,7 @@ struct arc_cap
  * the _end_ of the 512-byte buffer.  We hide this complexity inside the
  * driver.
  */
-struct arc_hardware
-{
+struct arc_hardware {
     __u8  source,		/* source ARCnet - filled in automagically */
              dest,		/* destination ARCnet - 0 for broadcast    */
     	     offset[2];		/* offset bytes (some weird semantics)     */
@@ -120,8 +115,7 @@ struct arc_hardware
  * This is an ARCnet frame header, as seen by the kernel (and userspace,
  * when you do a raw packet capture).
  */
-struct archdr
-{
+struct archdr {
     /* hardware requirements */
     struct arc_hardware hard;
      
diff --git a/include/linux/if_arp.h b/include/linux/if_arp.h
index 282eb37..e80b7f8 100644
--- a/include/linux/if_arp.h
+++ b/include/linux/if_arp.h
@@ -133,8 +133,7 @@ struct arpreq_old {
  *	This structure defines an ethernet arp header.
  */
 
-struct arphdr
-{
+struct arphdr {
 	__be16		ar_hrd;		/* format of hardware address	*/
 	__be16		ar_pro;		/* format of protocol address	*/
 	unsigned char	ar_hln;		/* length of hardware address	*/
diff --git a/include/linux/if_bonding.h b/include/linux/if_bonding.h
index 65c2d24..cd525fa 100644
--- a/include/linux/if_bonding.h
+++ b/include/linux/if_bonding.h
@@ -94,8 +94,7 @@ typedef struct ifbond {
 	__s32 miimon;
 } ifbond;
 
-typedef struct ifslave
-{
+typedef struct ifslave {
 	__s32 slave_id; /* Used as an IN param to the BOND_SLAVE_INFO_QUERY ioctl */
 	char slave_name[IFNAMSIZ];
 	__s8 link;
diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index 6badb3e..938b7e8 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -49,8 +49,7 @@
 #define BR_STATE_FORWARDING 3
 #define BR_STATE_BLOCKING 4
 
-struct __bridge_info
-{
+struct __bridge_info {
 	__u64 designated_root;
 	__u64 bridge_id;
 	__u32 root_path_cost;
@@ -72,8 +71,7 @@ struct __bridge_info
 	__u32 gc_timer_value;
 };
 
-struct __port_info
-{
+struct __port_info {
 	__u64 designated_root;
 	__u64 designated_bridge;
 	__u16 port_id;
@@ -89,8 +87,7 @@ struct __port_info
 	__u32 hold_timer_value;
 };
 
-struct __fdb_entry
-{
+struct __fdb_entry {
 	__u8 mac_addr[6];
 	__u8 port_no;
 	__u8 is_local;
diff --git a/include/linux/if_ec.h b/include/linux/if_ec.h
index e7499aa..d85f9f4 100644
--- a/include/linux/if_ec.h
+++ b/include/linux/if_ec.h
@@ -5,14 +5,12 @@
 
 /* User visible stuff. Glibc provides its own but libc5 folk will use these */
 
-struct ec_addr
-{
+struct ec_addr {
   unsigned char station;		/* Station number.  */
   unsigned char net;			/* Network number.  */
 };
 
-struct sockaddr_ec
-{
+struct sockaddr_ec {
   unsigned short sec_family;
   unsigned char port;			/* Port number.  */
   unsigned char cb;			/* Control/flag byte.  */
@@ -37,8 +35,7 @@ struct sockaddr_ec
 #define EC_HLEN				6
 
 /* This is what an Econet frame looks like on the wire. */
-struct ec_framehdr 
-{
+struct ec_framehdr {
   unsigned char dst_stn;
   unsigned char dst_net;
   unsigned char src_stn;
@@ -62,8 +59,7 @@ static inline struct econet_sock *ec_sk(const struct sock *sk)
 	return (struct econet_sock *)sk;
 }
 
-struct ec_device
-{
+struct ec_device {
   unsigned char station, net;		/* Econet protocol address */
 };
 
diff --git a/include/linux/if_fddi.h b/include/linux/if_fddi.h
index 45de104..5459c5c 100644
--- a/include/linux/if_fddi.h
+++ b/include/linux/if_fddi.h
@@ -63,36 +63,32 @@
 #define FDDI_UI_CMD			0x03
 
 /* Define 802.2 Type 1 header */
-struct fddi_8022_1_hdr
-	{
+struct fddi_8022_1_hdr {
 	__u8	dsap;					/* destination service access point */
 	__u8	ssap;					/* source service access point */
 	__u8	ctrl;					/* control byte #1 */
-	} __attribute__ ((packed));
+} __attribute__ ((packed));
 
 /* Define 802.2 Type 2 header */
-struct fddi_8022_2_hdr
-	{
+struct fddi_8022_2_hdr {
 	__u8	dsap;					/* destination service access point */
 	__u8	ssap;					/* source service access point */
 	__u8	ctrl_1;					/* control byte #1 */
 	__u8	ctrl_2;					/* control byte #2 */
-	} __attribute__ ((packed));
+} __attribute__ ((packed));
 
 /* Define 802.2 SNAP header */
 #define FDDI_K_OUI_LEN	3
-struct fddi_snap_hdr
-	{
+struct fddi_snap_hdr {
 	__u8	dsap;					/* always 0xAA */
 	__u8	ssap;					/* always 0xAA */
 	__u8	ctrl;					/* always 0x03 */
 	__u8	oui[FDDI_K_OUI_LEN];	/* organizational universal id */
 	__be16	ethertype;				/* packet type ID field */
-	} __attribute__ ((packed));
+} __attribute__ ((packed));
 
 /* Define FDDI LLC frame header */
-struct fddihdr
-	{
+struct fddihdr {
 	__u8	fc;						/* frame control */
 	__u8	daddr[FDDI_K_ALEN];		/* destination address */
 	__u8	saddr[FDDI_K_ALEN];		/* source address */
@@ -102,7 +98,7 @@ struct fddihdr
 		struct fddi_8022_2_hdr		llc_8022_2;
 		struct fddi_snap_hdr		llc_snap;
 		} hdr;
-	} __attribute__ ((packed));
+} __attribute__ ((packed));
 
 #ifdef __KERNEL__
 #include <linux/netdevice.h>
@@ -197,7 +193,7 @@ struct fddi_statistics {
 	__u32	port_pc_withhold[2];
 	__u32	port_ler_flag[2];
 	__u32	port_hardware_present[2];
-	};
+};
 #endif /* __KERNEL__ */
 
 #endif	/* _LINUX_IF_FDDI_H */
diff --git a/include/linux/if_hippi.h b/include/linux/if_hippi.h
index 4a7c994..8d038eb 100644
--- a/include/linux/if_hippi.h
+++ b/include/linux/if_hippi.h
@@ -51,8 +51,7 @@
  *	HIPPI statistics collection data. 
  */
  
-struct hipnet_statistics
-{
+struct hipnet_statistics {
 	int	rx_packets;		/* total packets received	*/
 	int	tx_packets;		/* total packets transmitted	*/
 	int	rx_errors;		/* bad packets received		*/
@@ -77,8 +76,7 @@ struct hipnet_statistics
 };
 
 
-struct hippi_fp_hdr
-{
+struct hippi_fp_hdr {
 #if 0
 	__u8		ulp;				/* must contain 4 */
 #if defined (__BIG_ENDIAN_BITFIELD)
@@ -108,8 +106,7 @@ struct hippi_fp_hdr
 	__be32		d2_size;
 } __attribute__ ((packed));
 
-struct hippi_le_hdr
-{
+struct hippi_le_hdr {
 #if defined (__BIG_ENDIAN_BITFIELD)
 	__u8		fc:3;
 	__u8		double_wide:1;
@@ -139,8 +136,7 @@ struct hippi_le_hdr
  * Looks like the dsap and ssap fields have been swapped by mistake in
  * RFC 2067 "IP over HIPPI".
  */
-struct hippi_snap_hdr
-{
+struct hippi_snap_hdr {
 	__u8	dsap;			/* always 0xAA */
 	__u8	ssap;			/* always 0xAA */
 	__u8	ctrl;			/* always 0x03 */
@@ -148,8 +144,7 @@ struct hippi_snap_hdr
 	__be16	ethertype;		/* packet type ID field */
 } __attribute__ ((packed));
 
-struct hippi_hdr
-{
+struct hippi_hdr {
 	struct hippi_fp_hdr	fp;
 	struct hippi_le_hdr	le;
 	struct hippi_snap_hdr	snap;
diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 176c518..1d3b242 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -5,8 +5,7 @@
 #include <linux/netlink.h>
 
 /* The struct should be in sync with struct net_device_stats */
-struct rtnl_link_stats
-{
+struct rtnl_link_stats {
 	__u32	rx_packets;		/* total packets received	*/
 	__u32	tx_packets;		/* total packets transmitted	*/
 	__u32	rx_bytes;		/* total bytes received 	*/
@@ -39,8 +38,7 @@ struct rtnl_link_stats
 };
 
 /* The struct should be in sync with struct ifmap */
-struct rtnl_link_ifmap
-{
+struct rtnl_link_ifmap {
 	__u64	mem_start;
 	__u64	mem_end;
 	__u64	base_addr;
@@ -49,8 +47,7 @@ struct rtnl_link_ifmap
 	__u8	port;
 };
 
-enum
-{
+enum {
 	IFLA_UNSPEC,
 	IFLA_ADDRESS,
 	IFLA_BROADCAST,
@@ -123,8 +120,7 @@ enum
  */
 
 /* Subtype attributes for IFLA_PROTINFO */
-enum
-{
+enum {
 	IFLA_INET6_UNSPEC,
 	IFLA_INET6_FLAGS,	/* link flags			*/
 	IFLA_INET6_CONF,	/* sysctl parameters		*/
@@ -137,16 +133,14 @@ enum
 
 #define IFLA_INET6_MAX	(__IFLA_INET6_MAX - 1)
 
-struct ifla_cacheinfo
-{
+struct ifla_cacheinfo {
 	__u32	max_reasm_len;
 	__u32	tstamp;		/* ipv6InterfaceTable updated timestamp */
 	__u32	reachable_time;
 	__u32	retrans_time;
 };
 
-enum
-{
+enum {
 	IFLA_INFO_UNSPEC,
 	IFLA_INFO_KIND,
 	IFLA_INFO_DATA,
@@ -158,8 +152,7 @@ enum
 
 /* VLAN section */
 
-enum
-{
+enum {
 	IFLA_VLAN_UNSPEC,
 	IFLA_VLAN_ID,
 	IFLA_VLAN_FLAGS,
@@ -175,8 +168,7 @@ struct ifla_vlan_flags {
 	__u32	mask;
 };
 
-enum
-{
+enum {
 	IFLA_VLAN_QOS_UNSPEC,
 	IFLA_VLAN_QOS_MAPPING,
 	__IFLA_VLAN_QOS_MAX
@@ -184,8 +176,7 @@ enum
 
 #define IFLA_VLAN_QOS_MAX	(__IFLA_VLAN_QOS_MAX - 1)
 
-struct ifla_vlan_qos_mapping
-{
+struct ifla_vlan_qos_mapping {
 	__u32 from;
 	__u32 to;
 };
diff --git a/include/linux/if_packet.h b/include/linux/if_packet.h
index dea7d6b..4021d47 100644
--- a/include/linux/if_packet.h
+++ b/include/linux/if_packet.h
@@ -3,15 +3,13 @@
 
 #include <linux/types.h>
 
-struct sockaddr_pkt
-{
+struct sockaddr_pkt {
 	unsigned short spkt_family;
 	unsigned char spkt_device[14];
 	__be16 spkt_protocol;
 };
 
-struct sockaddr_ll
-{
+struct sockaddr_ll {
 	unsigned short	sll_family;
 	__be16		sll_protocol;
 	int		sll_ifindex;
@@ -49,14 +47,12 @@ struct sockaddr_ll
 #define PACKET_TX_RING			13
 #define PACKET_LOSS			14
 
-struct tpacket_stats
-{
+struct tpacket_stats {
 	unsigned int	tp_packets;
 	unsigned int	tp_drops;
 };
 
-struct tpacket_auxdata
-{
+struct tpacket_auxdata {
 	__u32		tp_status;
 	__u32		tp_len;
 	__u32		tp_snaplen;
@@ -78,8 +74,7 @@ struct tpacket_auxdata
 #define TP_STATUS_SENDING	0x2
 #define TP_STATUS_WRONG_FORMAT	0x4
 
-struct tpacket_hdr
-{
+struct tpacket_hdr {
 	unsigned long	tp_status;
 	unsigned int	tp_len;
 	unsigned int	tp_snaplen;
@@ -93,8 +88,7 @@ struct tpacket_hdr
 #define TPACKET_ALIGN(x)	(((x)+TPACKET_ALIGNMENT-1)&~(TPACKET_ALIGNMENT-1))
 #define TPACKET_HDRLEN		(TPACKET_ALIGN(sizeof(struct tpacket_hdr)) + sizeof(struct sockaddr_ll))
 
-struct tpacket2_hdr
-{
+struct tpacket2_hdr {
 	__u32		tp_status;
 	__u32		tp_len;
 	__u32		tp_snaplen;
@@ -107,8 +101,7 @@ struct tpacket2_hdr
 
 #define TPACKET2_HDRLEN		(TPACKET_ALIGN(sizeof(struct tpacket2_hdr)) + sizeof(struct sockaddr_ll))
 
-enum tpacket_versions
-{
+enum tpacket_versions {
 	TPACKET_V1,
 	TPACKET_V2,
 };
@@ -126,16 +119,14 @@ enum tpacket_versions
    - Pad to align to TPACKET_ALIGNMENT=16
  */
 
-struct tpacket_req
-{
+struct tpacket_req {
 	unsigned int	tp_block_size;	/* Minimal size of contiguous block */
 	unsigned int	tp_block_nr;	/* Number of blocks */
 	unsigned int	tp_frame_size;	/* Size of frame */
 	unsigned int	tp_frame_nr;	/* Total number of frames */
 };
 
-struct packet_mreq
-{
+struct packet_mreq {
 	int		mr_ifindex;
 	unsigned short	mr_type;
 	unsigned short	mr_alen;
diff --git a/include/linux/if_plip.h b/include/linux/if_plip.h
index 153a649..6298c7e 100644
--- a/include/linux/if_plip.h
+++ b/include/linux/if_plip.h
@@ -15,8 +15,7 @@
 
 #define	SIOCDEVPLIP	SIOCDEVPRIVATE
 
-struct plipconf
-{
+struct plipconf {
 	unsigned short pcmd;
 	unsigned long  nibble;
 	unsigned long  trigger;
diff --git a/include/linux/if_pppol2tp.h b/include/linux/if_pppol2tp.h
index 3a14b08..c58baea 100644
--- a/include/linux/if_pppol2tp.h
+++ b/include/linux/if_pppol2tp.h
@@ -24,8 +24,7 @@
 /* Structure used to connect() the socket to a particular tunnel UDP
  * socket.
  */
-struct pppol2tp_addr
-{
+struct pppol2tp_addr {
 	__kernel_pid_t	pid;		/* pid that owns the fd.
 					 * 0 => current */
 	int	fd;			/* FD of UDP socket to use */
diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
index 8d76cb4..1822d63 100644
--- a/include/linux/if_tunnel.h
+++ b/include/linux/if_tunnel.h
@@ -30,8 +30,7 @@
 #define GRE_FLAGS	__cpu_to_be16(0x00F8)
 #define GRE_VERSION	__cpu_to_be16(0x0007)
 
-struct ip_tunnel_parm
-{
+struct ip_tunnel_parm {
 	char			name[IFNAMSIZ];
 	int			link;
 	__be16			i_flags;
@@ -63,8 +62,7 @@ struct ip_tunnel_6rd {
 	__u16			relay_prefixlen;
 };
 
-enum
-{
+enum {
 	IFLA_GRE_UNSPEC,
 	IFLA_GRE_LINK,
 	IFLA_GRE_IFLAGS,
diff --git a/include/linux/igmp.h b/include/linux/igmp.h
index fe158e0..724c27e 100644
--- a/include/linux/igmp.h
+++ b/include/linux/igmp.h
@@ -27,8 +27,7 @@
  *	Header in on cable format
  */
 
-struct igmphdr
-{
+struct igmphdr {
 	__u8 type;
 	__u8 code;		/* For newer IGMP */
 	__sum16 csum;
@@ -151,8 +150,7 @@ static inline struct igmpv3_query *
 extern int sysctl_igmp_max_memberships;
 extern int sysctl_igmp_max_msf;
 
-struct ip_sf_socklist
-{
+struct ip_sf_socklist {
 	unsigned int		sl_max;
 	unsigned int		sl_count;
 	__be32			sl_addr[0];
@@ -167,16 +165,14 @@ struct ip_sf_socklist
    this list never used in fast path code
  */
 
-struct ip_mc_socklist
-{
+struct ip_mc_socklist {
 	struct ip_mc_socklist	*next;
 	struct ip_mreqn		multi;
 	unsigned int		sfmode;		/* MCAST_{INCLUDE,EXCLUDE} */
 	struct ip_sf_socklist	*sflist;
 };
 
-struct ip_sf_list
-{
+struct ip_sf_list {
 	struct ip_sf_list	*sf_next;
 	__be32			sf_inaddr;
 	unsigned long		sf_count[2];	/* include/exclude counts */
@@ -185,8 +181,7 @@ struct ip_sf_list
 	unsigned char		sf_crcount;	/* retrans. left to send */
 };
 
-struct ip_mc_list
-{
+struct ip_mc_list {
 	struct in_device	*interface;
 	__be32			multiaddr;
 	struct ip_sf_list	*sources;
diff --git a/include/linux/in.h b/include/linux/in.h
index cf196da..b615649 100644
--- a/include/linux/in.h
+++ b/include/linux/in.h
@@ -118,14 +118,12 @@ struct in_addr {
 
 /* Request struct for multicast socket ops */
 
-struct ip_mreq 
-{
+struct ip_mreq  {
 	struct in_addr imr_multiaddr;	/* IP multicast address of group */
 	struct in_addr imr_interface;	/* local IP address of interface */
 };
 
-struct ip_mreqn
-{
+struct ip_mreqn {
 	struct in_addr	imr_multiaddr;		/* IP multicast address of group */
 	struct in_addr	imr_address;		/* local IP address of interface */
 	int		imr_ifindex;		/* Interface index */
@@ -149,21 +147,18 @@ struct ip_msfilter {
 	(sizeof(struct ip_msfilter) - sizeof(__u32) \
 	+ (numsrc) * sizeof(__u32))
 
-struct group_req
-{
+struct group_req {
 	__u32				 gr_interface;	/* interface index */
 	struct __kernel_sockaddr_storage gr_group;	/* group address */
 };
 
-struct group_source_req
-{
+struct group_source_req {
 	__u32				 gsr_interface;	/* interface index */
 	struct __kernel_sockaddr_storage gsr_group;	/* group address */
 	struct __kernel_sockaddr_storage gsr_source;	/* source address */
 };
 
-struct group_filter
-{
+struct group_filter {
 	__u32				 gf_interface;	/* interface index */
 	struct __kernel_sockaddr_storage gf_group;	/* multicast address */
 	__u32				 gf_fmode;	/* filter mode */
@@ -175,8 +170,7 @@ struct group_filter
 	(sizeof(struct group_filter) - sizeof(struct __kernel_sockaddr_storage) \
 	+ (numsrc) * sizeof(struct __kernel_sockaddr_storage))
 
-struct in_pktinfo
-{
+struct in_pktinfo {
 	int		ipi_ifindex;
 	struct in_addr	ipi_spec_dst;
 	struct in_addr	ipi_addr;
diff --git a/include/linux/in6.h b/include/linux/in6.h
index 718bf21..dfa2916 100644
--- a/include/linux/in6.h
+++ b/include/linux/in6.h
@@ -27,10 +27,8 @@
  *	IPv6 address structure
  */
 
-struct in6_addr
-{
-	union 
-	{
+struct in6_addr {
+	union {
 		__u8		u6_addr8[16];
 		__be16		u6_addr16[8];
 		__be32		u6_addr32[4];
@@ -75,8 +73,7 @@ struct ipv6_mreq {
 
 #define ipv6mr_acaddr	ipv6mr_multiaddr
 
-struct in6_flowlabel_req
-{
+struct in6_flowlabel_req {
 	struct in6_addr	flr_dst;
 	__be32	flr_label;
 	__u8	flr_action;
diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index ad27c7d..eecfa55 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -10,15 +10,13 @@
 #include <linux/timer.h>
 #include <linux/sysctl.h>
 
-struct ipv4_devconf
-{
+struct ipv4_devconf {
 	void	*sysctl;
 	int	data[__NET_IPV4_CONF_MAX - 1];
 	DECLARE_BITMAP(state, __NET_IPV4_CONF_MAX - 1);
 };
 
-struct in_device
-{
+struct in_device {
 	struct net_device	*dev;
 	atomic_t		refcnt;
 	int			dead;
@@ -110,8 +108,7 @@ static inline void ipv4_devconf_setall(struct in_device *in_dev)
 #define IN_DEV_ARP_IGNORE(in_dev)	IN_DEV_MAXCONF((in_dev), ARP_IGNORE)
 #define IN_DEV_ARP_NOTIFY(in_dev)	IN_DEV_MAXCONF((in_dev), ARP_NOTIFY)
 
-struct in_ifaddr
-{
+struct in_ifaddr {
 	struct in_ifaddr	*ifa_next;
 	struct in_device	*ifa_dev;
 	struct rcu_head		rcu_head;
diff --git a/include/linux/ip_vs.h b/include/linux/ip_vs.h
index 148265e..dfc1703 100644
--- a/include/linux/ip_vs.h
+++ b/include/linux/ip_vs.h
@@ -127,8 +127,7 @@ struct ip_vs_dest_user {
 /*
  *	IPVS statistics object (for user space)
  */
-struct ip_vs_stats_user
-{
+struct ip_vs_stats_user {
 	__u32                   conns;          /* connections scheduled */
 	__u32                   inpkts;         /* incoming packets */
 	__u32                   outpkts;        /* outgoing packets */
diff --git a/include/linux/mroute.h b/include/linux/mroute.h
index d5f6915..c5f3d53 100644
--- a/include/linux/mroute.h
+++ b/include/linux/mroute.h
@@ -76,8 +76,7 @@ struct vifctl {
  *	Cache manipulation structures for mrouted and PIMd
  */
  
-struct mfcctl
-{
+struct mfcctl {
 	struct in_addr mfcc_origin;		/* Origin of mcast	*/
 	struct in_addr mfcc_mcastgrp;		/* Group in question	*/
 	vifi_t	mfcc_parent;			/* Where it arrived	*/
@@ -92,8 +91,7 @@ struct mfcctl
  *	Group count retrieval for mrouted
  */
  
-struct sioc_sg_req
-{
+struct sioc_sg_req {
 	struct in_addr src;
 	struct in_addr grp;
 	unsigned long pktcnt;
@@ -105,8 +103,7 @@ struct sioc_sg_req
  *	To get vif packet counts
  */
 
-struct sioc_vif_req
-{
+struct sioc_vif_req {
 	vifi_t	vifi;		/* Which iface */
 	unsigned long icount;	/* In packets */
 	unsigned long ocount;	/* Out packets */
@@ -119,8 +116,7 @@ struct sioc_vif_req
  *	data. Magically happens to be like an IP packet as per the original
  */
  
-struct igmpmsg
-{
+struct igmpmsg {
 	__u32 unused1,unused2;
 	unsigned char im_msgtype;		/* What is this */
 	unsigned char im_mbz;			/* Must be zero */
@@ -181,8 +177,7 @@ static inline int ip_mr_init(void)
 }
 #endif
 
-struct vif_device
-{
+struct vif_device {
 	struct net_device 	*dev;			/* Device we are using */
 	unsigned long	bytes_in,bytes_out;
 	unsigned long	pkt_in,pkt_out;		/* Statistics 			*/
@@ -195,8 +190,7 @@ struct vif_device
 
 #define VIFF_STATIC 0x8000
 
-struct mfc_cache 
-{
+struct mfc_cache {
 	struct mfc_cache *next;			/* Next entry on cache line 	*/
 #ifdef CONFIG_NET_NS
 	struct net *mfc_net;
diff --git a/include/linux/mroute6.h b/include/linux/mroute6.h
index b191865..2caa1a8 100644
--- a/include/linux/mroute6.h
+++ b/include/linux/mroute6.h
@@ -75,8 +75,7 @@ struct mif6ctl {
  *	Cache manipulation structures for mrouted and PIMd
  */
 
-struct mf6cctl
-{
+struct mf6cctl {
 	struct sockaddr_in6 mf6cc_origin;		/* Origin of mcast	*/
 	struct sockaddr_in6 mf6cc_mcastgrp;		/* Group in question	*/
 	mifi_t	mf6cc_parent;			/* Where it arrived	*/
@@ -87,8 +86,7 @@ struct mf6cctl
  *	Group count retrieval for pim6sd
  */
 
-struct sioc_sg_req6
-{
+struct sioc_sg_req6 {
 	struct sockaddr_in6 src;
 	struct sockaddr_in6 grp;
 	unsigned long pktcnt;
@@ -100,8 +98,7 @@ struct sioc_sg_req6
  *	To get vif packet counts
  */
 
-struct sioc_mif_req6
-{
+struct sioc_mif_req6 {
 	mifi_t	mifi;		/* Which iface */
 	unsigned long icount;	/* In packets */
 	unsigned long ocount;	/* Out packets */
@@ -172,8 +169,7 @@ static inline void ip6_mr_cleanup(void)
 }
 #endif
 
-struct mif_device
-{
+struct mif_device {
 	struct net_device 	*dev;			/* Device we are using */
 	unsigned long	bytes_in,bytes_out;
 	unsigned long	pkt_in,pkt_out;		/* Statistics 			*/
@@ -185,8 +181,7 @@ struct mif_device
 
 #define VIFF_STATIC 0x8000
 
-struct mfc6_cache
-{
+struct mfc6_cache {
 	struct mfc6_cache *next;		/* Next entry on cache line 	*/
 #ifdef CONFIG_NET_NS
 	struct net *mfc6_net;
diff --git a/include/linux/neighbour.h b/include/linux/neighbour.h
index 12c9de1..a7003b7 100644
--- a/include/linux/neighbour.h
+++ b/include/linux/neighbour.h
@@ -4,8 +4,7 @@
 #include <linux/types.h>
 #include <linux/netlink.h>
 
-struct ndmsg
-{
+struct ndmsg {
 	__u8		ndm_family;
 	__u8		ndm_pad1;
 	__u16		ndm_pad2;
@@ -15,8 +14,7 @@ struct ndmsg
 	__u8		ndm_type;
 };
 
-enum
-{
+enum {
 	NDA_UNSPEC,
 	NDA_DST,
 	NDA_LLADDR,
@@ -56,8 +54,7 @@ enum
    NUD_PERMANENT is also cannot be deleted by garbage collectors.
  */
 
-struct nda_cacheinfo
-{
+struct nda_cacheinfo {
 	__u32		ndm_confirmed;
 	__u32		ndm_used;
 	__u32		ndm_updated;
@@ -89,8 +86,7 @@ struct nda_cacheinfo
  * device.
  ****/
 
-struct ndt_stats
-{
+struct ndt_stats {
 	__u64		ndts_allocs;
 	__u64		ndts_destroys;
 	__u64		ndts_hash_grows;
@@ -124,15 +120,13 @@ enum {
 };
 #define NDTPA_MAX (__NDTPA_MAX - 1)
 
-struct ndtmsg
-{
+struct ndtmsg {
 	__u8		ndtm_family;
 	__u8		ndtm_pad1;
 	__u16		ndtm_pad2;
 };
 
-struct ndt_config
-{
+struct ndt_config {
 	__u16		ndtc_key_len;
 	__u16		ndtc_entry_size;
 	__u32		ndtc_entries;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5077de0..465add6 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -125,8 +125,7 @@ typedef enum netdev_tx netdev_tx_t;
  *	with byte counters.
  */
 
-struct net_device_stats
-{
+struct net_device_stats {
 	unsigned long	rx_packets;		/* total packets received	*/
 	unsigned long	tx_packets;		/* total packets transmitted	*/
 	unsigned long	rx_bytes;		/* total bytes received 	*/
@@ -179,8 +178,7 @@ struct neighbour;
 struct neigh_parms;
 struct sk_buff;
 
-struct netif_rx_stats
-{
+struct netif_rx_stats {
 	unsigned total;
 	unsigned dropped;
 	unsigned time_squeeze;
@@ -189,8 +187,7 @@ struct netif_rx_stats
 
 DECLARE_PER_CPU(struct netif_rx_stats, netdev_rx_stat);
 
-struct dev_addr_list
-{
+struct dev_addr_list {
 	struct dev_addr_list	*next;
 	u8			da_addr[MAX_ADDR_LEN];
 	u8			da_addrlen;
@@ -227,8 +224,7 @@ struct netdev_hw_addr_list {
 	int			count;
 };
 
-struct hh_cache
-{
+struct hh_cache {
 	struct hh_cache *hh_next;	/* Next entry			     */
 	atomic_t	hh_refcnt;	/* number of users                   */
 /*
@@ -291,8 +287,7 @@ struct header_ops {
  * code.
  */
 
-enum netdev_state_t
-{
+enum netdev_state_t {
 	__LINK_STATE_START,
 	__LINK_STATE_PRESENT,
 	__LINK_STATE_NOCARRIER,
@@ -341,8 +336,7 @@ struct napi_struct {
 	struct sk_buff		*skb;
 };
 
-enum
-{
+enum {
 	NAPI_STATE_SCHED,	/* Poll is scheduled */
 	NAPI_STATE_DISABLE,	/* Disable pending */
 	NAPI_STATE_NPSVC,	/* Netpoll - don't dequeue from poll_list */
@@ -458,8 +452,7 @@ static inline void napi_synchronize(const struct napi_struct *n)
 # define napi_synchronize(n)	barrier()
 #endif
 
-enum netdev_queue_state_t
-{
+enum netdev_queue_state_t {
 	__QUEUE_STATE_XOFF,
 	__QUEUE_STATE_FROZEN,
 };
@@ -653,8 +646,7 @@ struct net_device_ops {
  *	moves out.
  */
 
-struct net_device
-{
+struct net_device {
 
 	/*
 	 * This is the first field of the "visible" part of this structure
@@ -1229,8 +1221,7 @@ static inline int unregister_gifconf(unsigned int family)
  * Incoming packets are placed on per-cpu queues so that
  * no locking is needed.
  */
-struct softnet_data
-{
+struct softnet_data {
 	struct Qdisc		*output_queue;
 	struct sk_buff_head	input_pkt_queue;
 	struct list_head	poll_list;
@@ -1627,7 +1618,8 @@ static inline int netif_dormant(const struct net_device *dev)
  *
  * Check if carrier is operational
  */
-static inline int netif_oper_up(const struct net_device *dev) {
+static inline int netif_oper_up(const struct net_device *dev)
+{
 	return (dev->operstate == IF_OPER_UP ||
 		dev->operstate == IF_OPER_UNKNOWN /* backward compat */);
 }
diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 6132b5e..48c5496 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -93,8 +93,7 @@ typedef unsigned int nf_hookfn(unsigned int hooknum,
 			       const struct net_device *out,
 			       int (*okfn)(struct sk_buff *));
 
-struct nf_hook_ops
-{
+struct nf_hook_ops {
 	struct list_head list;
 
 	/* User fills in from here down. */
@@ -106,8 +105,7 @@ struct nf_hook_ops
 	int priority;
 };
 
-struct nf_sockopt_ops
-{
+struct nf_sockopt_ops {
 	struct list_head list;
 
 	u_int8_t pf;
diff --git a/include/linux/netfilter/nf_conntrack_common.h b/include/linux/netfilter/nf_conntrack_common.h
index a8248ee..a374787 100644
--- a/include/linux/netfilter/nf_conntrack_common.h
+++ b/include/linux/netfilter/nf_conntrack_common.h
@@ -3,8 +3,7 @@
 /* Connection state tracking for netfilter.  This is separated from,
    but required by, the NAT layer; it can also be used by an iptables
    extension. */
-enum ip_conntrack_info
-{
+enum ip_conntrack_info {
 	/* Part of an established connection (either direction). */
 	IP_CT_ESTABLISHED,
 
@@ -76,8 +75,7 @@ enum ip_conntrack_status {
 };
 
 #ifdef __KERNEL__
-struct ip_conntrack_stat
-{
+struct ip_conntrack_stat {
 	unsigned int searched;
 	unsigned int found;
 	unsigned int new;
diff --git a/include/linux/netfilter/nf_conntrack_ftp.h b/include/linux/netfilter/nf_conntrack_ftp.h
index 47727d7..3e3aa08 100644
--- a/include/linux/netfilter/nf_conntrack_ftp.h
+++ b/include/linux/netfilter/nf_conntrack_ftp.h
@@ -3,8 +3,7 @@
 /* FTP tracking. */
 
 /* This enum is exposed to userspace */
-enum nf_ct_ftp_type
-{
+enum nf_ct_ftp_type {
 	/* PORT command from client */
 	NF_CT_FTP_PORT,
 	/* PASV response from server */
diff --git a/include/linux/netfilter/nf_conntrack_sctp.h b/include/linux/netfilter/nf_conntrack_sctp.h
index 768f78c..ceeefe6 100644
--- a/include/linux/netfilter/nf_conntrack_sctp.h
+++ b/include/linux/netfilter/nf_conntrack_sctp.h
@@ -16,8 +16,7 @@ enum sctp_conntrack {
 	SCTP_CONNTRACK_MAX
 };
 
-struct ip_ct_sctp
-{
+struct ip_ct_sctp {
 	enum sctp_conntrack state;
 
 	__be32 vtag[IP_CT_DIR_MAX];
diff --git a/include/linux/netfilter/nf_conntrack_tcp.h b/include/linux/netfilter/nf_conntrack_tcp.h
index 4352fee..f6d97f6 100644
--- a/include/linux/netfilter/nf_conntrack_tcp.h
+++ b/include/linux/netfilter/nf_conntrack_tcp.h
@@ -55,8 +55,7 @@ struct ip_ct_tcp_state {
 	u_int8_t	flags;		/* per direction options */
 };
 
-struct ip_ct_tcp
-{
+struct ip_ct_tcp {
 	struct ip_ct_tcp_state seen[2];	/* connection parameters per direction */
 	u_int8_t	state;		/* state of the connection (enum tcp_conntrack) */
 	/* For detecting stale connections */
diff --git a/include/linux/netfilter/nfnetlink.h b/include/linux/netfilter/nfnetlink.h
index 9f00da2..49d321f 100644
--- a/include/linux/netfilter/nfnetlink.h
+++ b/include/linux/netfilter/nfnetlink.h
@@ -55,8 +55,7 @@ struct nfgenmsg {
 #include <linux/capability.h>
 #include <net/netlink.h>
 
-struct nfnl_callback
-{
+struct nfnl_callback {
 	int (*call)(struct sock *nl, struct sk_buff *skb, 
 		    const struct nlmsghdr *nlh,
 		    const struct nlattr * const cda[]);
@@ -64,8 +63,7 @@ struct nfnl_callback
 	const u_int16_t attr_count;		/* number of nlattr's */
 };
 
-struct nfnetlink_subsystem
-{
+struct nfnetlink_subsystem {
 	const char *name;
 	__u8 subsys_id;			/* nfnetlink subsystem ID */
 	__u8 cb_count;			/* number of callbacks */
diff --git a/include/linux/netfilter/nfnetlink_compat.h b/include/linux/netfilter/nfnetlink_compat.h
index eda55ca..ffb9503 100644
--- a/include/linux/netfilter/nfnetlink_compat.h
+++ b/include/linux/netfilter/nfnetlink_compat.h
@@ -21,8 +21,7 @@
  * ! nfnetlink use the same attributes methods. - J. Schulist.
  */
 
-struct nfattr
-{
+struct nfattr {
 	__u16 nfa_len;
 	__u16 nfa_type;	/* we use 15 bits for the type, and the highest
 				 * bit to indicate whether the payload is nested */
diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 812cb15..378f27a 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -6,8 +6,7 @@
 #define XT_FUNCTION_MAXNAMELEN 30
 #define XT_TABLE_MAXNAMELEN 32
 
-struct xt_entry_match
-{
+struct xt_entry_match {
 	union {
 		struct {
 			__u16 match_size;
@@ -31,8 +30,7 @@ struct xt_entry_match
 	unsigned char data[0];
 };
 
-struct xt_entry_target
-{
+struct xt_entry_target {
 	union {
 		struct {
 			__u16 target_size;
@@ -64,16 +62,14 @@ struct xt_entry_target
 	},								       \
 }
 
-struct xt_standard_target
-{
+struct xt_standard_target {
 	struct xt_entry_target target;
 	int verdict;
 };
 
 /* The argument to IPT_SO_GET_REVISION_*.  Returns highest revision
  * kernel supports, if >= revision. */
-struct xt_get_revision
-{
+struct xt_get_revision {
 	char name[XT_FUNCTION_MAXNAMELEN-1];
 
 	__u8 revision;
@@ -90,8 +86,7 @@ struct xt_get_revision
  * ip6t_entry and arpt_entry.  This sucks, and it is a hack.  It will be my
  * personal pleasure to remove it -HW
  */
-struct _xt_align
-{
+struct _xt_align {
 	__u8 u8;
 	__u16 u16;
 	__u32 u32;
@@ -109,14 +104,12 @@ struct _xt_align
 #define SET_COUNTER(c,b,p) do { (c).bcnt = (b); (c).pcnt = (p); } while(0)
 #define ADD_COUNTER(c,b,p) do { (c).bcnt += (b); (c).pcnt += (p); } while(0)
 
-struct xt_counters
-{
+struct xt_counters {
 	__u64 pcnt, bcnt;			/* Packet and byte counters */
 };
 
 /* The argument to IPT_SO_ADD_COUNTERS. */
-struct xt_counters_info
-{
+struct xt_counters_info {
 	/* Which table. */
 	char name[XT_TABLE_MAXNAMELEN];
 
@@ -269,8 +262,7 @@ struct xt_tgdtor_param {
 	u_int8_t family;
 };
 
-struct xt_match
-{
+struct xt_match {
 	struct list_head list;
 
 	const char name[XT_FUNCTION_MAXNAMELEN-1];
@@ -310,8 +302,7 @@ struct xt_match
 };
 
 /* Registration hooks for targets. */
-struct xt_target
-{
+struct xt_target {
 	struct list_head list;
 
 	const char name[XT_FUNCTION_MAXNAMELEN-1];
@@ -349,8 +340,7 @@ struct xt_target
 };
 
 /* Furniture shopping... */
-struct xt_table
-{
+struct xt_table {
 	struct list_head list;
 
 	/* What hooks you will enter on */
@@ -371,8 +361,7 @@ struct xt_table
 #include <linux/netfilter_ipv4.h>
 
 /* The table itself */
-struct xt_table_info
-{
+struct xt_table_info {
 	/* Size per table */
 	unsigned int size;
 	/* Number of entries: FIXME. --RR */
@@ -528,8 +517,7 @@ static inline unsigned long ifname_compare_aligned(const char *_a,
 #ifdef CONFIG_COMPAT
 #include <net/compat.h>
 
-struct compat_xt_entry_match
-{
+struct compat_xt_entry_match {
 	union {
 		struct {
 			u_int16_t match_size;
@@ -545,8 +533,7 @@ struct compat_xt_entry_match
 	unsigned char data[0];
 };
 
-struct compat_xt_entry_target
-{
+struct compat_xt_entry_target {
 	union {
 		struct {
 			u_int16_t target_size;
@@ -566,8 +553,7 @@ struct compat_xt_entry_target
  * need to change whole approach in order to calculate align as function of
  * current task alignment */
 
-struct compat_xt_counters
-{
+struct compat_xt_counters {
 #if defined(CONFIG_X86_64) || defined(CONFIG_IA64)
 	u_int32_t cnt[4];
 #else
@@ -575,8 +561,7 @@ struct compat_xt_counters
 #endif
 };
 
-struct compat_xt_counters_info
-{
+struct compat_xt_counters_info {
 	char name[XT_TABLE_MAXNAMELEN];
 	compat_uint_t num_counters;
 	struct compat_xt_counters counters[0];
diff --git a/include/linux/netfilter/xt_connbytes.h b/include/linux/netfilter/xt_connbytes.h
index 52bd615..92fcbb0 100644
--- a/include/linux/netfilter/xt_connbytes.h
+++ b/include/linux/netfilter/xt_connbytes.h
@@ -15,8 +15,7 @@ enum xt_connbytes_direction {
 	XT_CONNBYTES_DIR_BOTH,
 };
 
-struct xt_connbytes_info
-{
+struct xt_connbytes_info {
 	struct {
 		aligned_u64 from;	/* count to be matched */
 		aligned_u64 to;		/* count to be matched */
diff --git a/include/linux/netfilter/xt_esp.h b/include/linux/netfilter/xt_esp.h
index ef6fa47..ee68824 100644
--- a/include/linux/netfilter/xt_esp.h
+++ b/include/linux/netfilter/xt_esp.h
@@ -3,8 +3,7 @@
 
 #include <linux/types.h>
 
-struct xt_esp
-{
+struct xt_esp {
 	__u32 spis[2];	/* Security Parameter Index */
 	__u8  invflags;	/* Inverse flags */
 };
diff --git a/include/linux/netfilter/xt_multiport.h b/include/linux/netfilter/xt_multiport.h
index 185db49..5b7e72d 100644
--- a/include/linux/netfilter/xt_multiport.h
+++ b/include/linux/netfilter/xt_multiport.h
@@ -3,8 +3,7 @@
 
 #include <linux/types.h>
 
-enum xt_multiport_flags
-{
+enum xt_multiport_flags {
 	XT_MULTIPORT_SOURCE,
 	XT_MULTIPORT_DESTINATION,
 	XT_MULTIPORT_EITHER
@@ -13,15 +12,13 @@ enum xt_multiport_flags
 #define XT_MULTI_PORTS	15
 
 /* Must fit inside union xt_matchinfo: 16 bytes */
-struct xt_multiport
-{
+struct xt_multiport {
 	__u8 flags;				/* Type of comparison */
 	__u8 count;				/* Number of ports */
 	__u16 ports[XT_MULTI_PORTS];	/* Ports */
 };
 
-struct xt_multiport_v1
-{
+struct xt_multiport_v1 {
 	__u8 flags;				/* Type of comparison */
 	__u8 count;				/* Number of ports */
 	__u16 ports[XT_MULTI_PORTS];	/* Ports */
diff --git a/include/linux/netfilter/xt_policy.h b/include/linux/netfilter/xt_policy.h
index 7bb64e7..be8ead0 100644
--- a/include/linux/netfilter/xt_policy.h
+++ b/include/linux/netfilter/xt_policy.h
@@ -5,22 +5,19 @@
 
 #define XT_POLICY_MAX_ELEM	4
 
-enum xt_policy_flags
-{
+enum xt_policy_flags {
 	XT_POLICY_MATCH_IN	= 0x1,
 	XT_POLICY_MATCH_OUT	= 0x2,
 	XT_POLICY_MATCH_NONE	= 0x4,
 	XT_POLICY_MATCH_STRICT	= 0x8,
 };
 
-enum xt_policy_modes
-{
+enum xt_policy_modes {
 	XT_POLICY_MODE_TRANSPORT,
 	XT_POLICY_MODE_TUNNEL
 };
 
-struct xt_policy_spec
-{
+struct xt_policy_spec {
 	__u8	saddr:1,
 			daddr:1,
 			proto:1,
@@ -30,15 +27,13 @@ struct xt_policy_spec
 };
 
 #ifndef __KERNEL__
-union xt_policy_addr
-{
+union xt_policy_addr {
 	struct in_addr	a4;
 	struct in6_addr	a6;
 };
 #endif
 
-struct xt_policy_elem
-{
+struct xt_policy_elem {
 	union {
 #ifdef __KERNEL__
 		struct {
@@ -65,8 +60,7 @@ struct xt_policy_elem
 	struct xt_policy_spec	invert;
 };
 
-struct xt_policy_info
-{
+struct xt_policy_info {
 	struct xt_policy_elem pol[XT_POLICY_MAX_ELEM];
 	__u16 flags;
 	__u16 len;
diff --git a/include/linux/netfilter/xt_state.h b/include/linux/netfilter/xt_state.h
index c06f32e..7b32de8 100644
--- a/include/linux/netfilter/xt_state.h
+++ b/include/linux/netfilter/xt_state.h
@@ -6,8 +6,7 @@
 
 #define XT_STATE_UNTRACKED (1 << (IP_CT_NUMBER + 1))
 
-struct xt_state_info
-{
+struct xt_state_info {
 	unsigned int statemask;
 };
 #endif /*_XT_STATE_H*/
diff --git a/include/linux/netfilter/xt_string.h b/include/linux/netfilter/xt_string.h
index ecbb95f..235347c 100644
--- a/include/linux/netfilter/xt_string.h
+++ b/include/linux/netfilter/xt_string.h
@@ -11,8 +11,7 @@ enum {
 	XT_STRING_FLAG_IGNORECASE	= 0x02
 };
 
-struct xt_string_info
-{
+struct xt_string_info {
 	__u16 from_offset;
 	__u16 to_offset;
 	char	  algo[XT_STRING_MAX_ALGO_NAME_SIZE];
diff --git a/include/linux/netfilter/xt_tcpudp.h b/include/linux/netfilter/xt_tcpudp.h
index a490a0b..38aa7b3 100644
--- a/include/linux/netfilter/xt_tcpudp.h
+++ b/include/linux/netfilter/xt_tcpudp.h
@@ -4,8 +4,7 @@
 #include <linux/types.h>
 
 /* TCP matching stuff */
-struct xt_tcp
-{
+struct xt_tcp {
 	__u16 spts[2];			/* Source port range. */
 	__u16 dpts[2];			/* Destination port range. */
 	__u8 option;			/* TCP Option iff non-zero*/
@@ -22,8 +21,7 @@ struct xt_tcp
 #define XT_TCP_INV_MASK		0x0F	/* All possible flags. */
 
 /* UDP matching stuff */
-struct xt_udp
-{
+struct xt_udp {
 	__u16 spts[2];			/* Source port range. */
 	__u16 dpts[2];			/* Destination port range. */
 	__u8 invflags;			/* Inverse flags */
diff --git a/include/linux/netfilter_arp/arp_tables.h b/include/linux/netfilter_arp/arp_tables.h
index 6fe3e6a..f233652 100644
--- a/include/linux/netfilter_arp/arp_tables.h
+++ b/include/linux/netfilter_arp/arp_tables.h
@@ -132,8 +132,7 @@ struct arpt_entry
 #define ARPT_RETURN XT_RETURN
 
 /* The argument to ARPT_SO_GET_INFO */
-struct arpt_getinfo
-{
+struct arpt_getinfo {
 	/* Which table: caller fills this in. */
 	char name[ARPT_TABLE_MAXNAMELEN];
 
@@ -155,8 +154,7 @@ struct arpt_getinfo
 };
 
 /* The argument to ARPT_SO_SET_REPLACE. */
-struct arpt_replace
-{
+struct arpt_replace {
 	/* Which table. */
 	char name[ARPT_TABLE_MAXNAMELEN];
 
@@ -191,8 +189,7 @@ struct arpt_replace
 #define arpt_counters xt_counters
 
 /* The argument to ARPT_SO_GET_ENTRIES. */
-struct arpt_get_entries
-{
+struct arpt_get_entries {
 	/* Which table: user fills this in. */
 	char name[ARPT_TABLE_MAXNAMELEN];
 
@@ -224,20 +221,17 @@ static __inline__ struct arpt_entry_target *arpt_get_target(struct arpt_entry *e
 #ifdef __KERNEL__
 
 /* Standard entry. */
-struct arpt_standard
-{
+struct arpt_standard {
 	struct arpt_entry entry;
 	struct arpt_standard_target target;
 };
 
-struct arpt_error_target
-{
+struct arpt_error_target {
 	struct arpt_entry_target target;
 	char errorname[ARPT_FUNCTION_MAXNAMELEN];
 };
 
-struct arpt_error
-{
+struct arpt_error {
 	struct arpt_entry entry;
 	struct arpt_error_target target;
 };
@@ -279,8 +273,7 @@ extern unsigned int arpt_do_table(struct sk_buff *skb,
 #ifdef CONFIG_COMPAT
 #include <net/compat.h>
 
-struct compat_arpt_entry
-{
+struct compat_arpt_entry {
 	struct arpt_arp arp;
 	u_int16_t target_offset;
 	u_int16_t next_offset;
diff --git a/include/linux/netfilter_bridge/ebt_802_3.h b/include/linux/netfilter_bridge/ebt_802_3.h
index a11b0c2..c73ef0b 100644
--- a/include/linux/netfilter_bridge/ebt_802_3.h
+++ b/include/linux/netfilter_bridge/ebt_802_3.h
@@ -58,8 +58,7 @@ static inline struct ebt_802_3_hdr *ebt_802_3_hdr(const struct sk_buff *skb)
 }
 #endif
 
-struct ebt_802_3_info 
-{
+struct ebt_802_3_info {
 	uint8_t  sap;
 	__be16 type;
 	uint8_t  bitmask;
diff --git a/include/linux/netfilter_bridge/ebt_among.h b/include/linux/netfilter_bridge/ebt_among.h
index 7654069..0009558 100644
--- a/include/linux/netfilter_bridge/ebt_among.h
+++ b/include/linux/netfilter_bridge/ebt_among.h
@@ -29,14 +29,12 @@
  * Yes, it is a memory overhead, but in 2003 AD, who cares?
  */
 
-struct ebt_mac_wormhash_tuple
-{
+struct ebt_mac_wormhash_tuple {
 	uint32_t cmp[2];
 	__be32 ip;
 };
 
-struct ebt_mac_wormhash
-{
+struct ebt_mac_wormhash {
 	int table[257];
 	int poolsize;
 	struct ebt_mac_wormhash_tuple pool[0];
@@ -45,8 +43,7 @@ struct ebt_mac_wormhash
 #define ebt_mac_wormhash_size(x) ((x) ? sizeof(struct ebt_mac_wormhash) \
 		+ (x)->poolsize * sizeof(struct ebt_mac_wormhash_tuple) : 0)
 
-struct ebt_among_info
-{
+struct ebt_among_info {
 	int wh_dst_ofs;
 	int wh_src_ofs;
 	int bitmask;
diff --git a/include/linux/netfilter_bridge/ebt_arpreply.h b/include/linux/netfilter_bridge/ebt_arpreply.h
index 96a8339..7e77896 100644
--- a/include/linux/netfilter_bridge/ebt_arpreply.h
+++ b/include/linux/netfilter_bridge/ebt_arpreply.h
@@ -1,8 +1,7 @@
 #ifndef __LINUX_BRIDGE_EBT_ARPREPLY_H
 #define __LINUX_BRIDGE_EBT_ARPREPLY_H
 
-struct ebt_arpreply_info
-{
+struct ebt_arpreply_info {
 	unsigned char mac[ETH_ALEN];
 	int target;
 };
diff --git a/include/linux/netfilter_bridge/ebt_ip.h b/include/linux/netfilter_bridge/ebt_ip.h
index d684747..6a708fb 100644
--- a/include/linux/netfilter_bridge/ebt_ip.h
+++ b/include/linux/netfilter_bridge/ebt_ip.h
@@ -26,8 +26,7 @@
 #define EBT_IP_MATCH "ip"
 
 /* the same values are used for the invflags */
-struct ebt_ip_info
-{
+struct ebt_ip_info {
 	__be32 saddr;
 	__be32 daddr;
 	__be32 smsk;
diff --git a/include/linux/netfilter_bridge/ebt_ip6.h b/include/linux/netfilter_bridge/ebt_ip6.h
index 2273c3a..e5de987 100644
--- a/include/linux/netfilter_bridge/ebt_ip6.h
+++ b/include/linux/netfilter_bridge/ebt_ip6.h
@@ -23,8 +23,7 @@
 #define EBT_IP6_MATCH "ip6"
 
 /* the same values are used for the invflags */
-struct ebt_ip6_info
-{
+struct ebt_ip6_info {
 	struct in6_addr saddr;
 	struct in6_addr daddr;
 	struct in6_addr smsk;
diff --git a/include/linux/netfilter_bridge/ebt_limit.h b/include/linux/netfilter_bridge/ebt_limit.h
index d8b6500..4bf76b7 100644
--- a/include/linux/netfilter_bridge/ebt_limit.h
+++ b/include/linux/netfilter_bridge/ebt_limit.h
@@ -9,8 +9,7 @@
 /* 1/10,000 sec period => max of 10,000/sec.  Min rate is then 429490
    seconds, or one every 59 hours. */
 
-struct ebt_limit_info
-{
+struct ebt_limit_info {
 	u_int32_t avg;    /* Average secs between packets * scale */
 	u_int32_t burst;  /* Period multiplier for upper limit. */
 
diff --git a/include/linux/netfilter_bridge/ebt_log.h b/include/linux/netfilter_bridge/ebt_log.h
index b76e653..cc2cdfb 100644
--- a/include/linux/netfilter_bridge/ebt_log.h
+++ b/include/linux/netfilter_bridge/ebt_log.h
@@ -9,8 +9,7 @@
 #define EBT_LOG_PREFIX_SIZE 30
 #define EBT_LOG_WATCHER "log"
 
-struct ebt_log_info
-{
+struct ebt_log_info {
 	uint8_t loglevel;
 	uint8_t prefix[EBT_LOG_PREFIX_SIZE];
 	uint32_t bitmask;
diff --git a/include/linux/netfilter_bridge/ebt_mark_m.h b/include/linux/netfilter_bridge/ebt_mark_m.h
index 301524f..9ceb10e 100644
--- a/include/linux/netfilter_bridge/ebt_mark_m.h
+++ b/include/linux/netfilter_bridge/ebt_mark_m.h
@@ -4,8 +4,7 @@
 #define EBT_MARK_AND 0x01
 #define EBT_MARK_OR 0x02
 #define EBT_MARK_MASK (EBT_MARK_AND | EBT_MARK_OR)
-struct ebt_mark_m_info
-{
+struct ebt_mark_m_info {
 	unsigned long mark, mask;
 	uint8_t invert;
 	uint8_t bitmask;
diff --git a/include/linux/netfilter_bridge/ebt_mark_t.h b/include/linux/netfilter_bridge/ebt_mark_t.h
index 6270f6f..7d5a268 100644
--- a/include/linux/netfilter_bridge/ebt_mark_t.h
+++ b/include/linux/netfilter_bridge/ebt_mark_t.h
@@ -13,8 +13,7 @@
 #define MARK_AND_VALUE (0xffffffd0)
 #define MARK_XOR_VALUE (0xffffffc0)
 
-struct ebt_mark_t_info
-{
+struct ebt_mark_t_info {
 	unsigned long mark;
 	/* EBT_ACCEPT, EBT_DROP, EBT_CONTINUE or EBT_RETURN */
 	int target;
diff --git a/include/linux/netfilter_bridge/ebt_nat.h b/include/linux/netfilter_bridge/ebt_nat.h
index 435b886..5e74e3b 100644
--- a/include/linux/netfilter_bridge/ebt_nat.h
+++ b/include/linux/netfilter_bridge/ebt_nat.h
@@ -2,8 +2,7 @@
 #define __LINUX_BRIDGE_EBT_NAT_H
 
 #define NAT_ARP_BIT  (0x00000010)
-struct ebt_nat_info
-{
+struct ebt_nat_info {
 	unsigned char mac[ETH_ALEN];
 	/* EBT_ACCEPT, EBT_DROP, EBT_CONTINUE or EBT_RETURN */
 	int target;
diff --git a/include/linux/netfilter_bridge/ebt_pkttype.h b/include/linux/netfilter_bridge/ebt_pkttype.h
index 0d64bbb..51a7998 100644
--- a/include/linux/netfilter_bridge/ebt_pkttype.h
+++ b/include/linux/netfilter_bridge/ebt_pkttype.h
@@ -1,8 +1,7 @@
 #ifndef __LINUX_BRIDGE_EBT_PKTTYPE_H
 #define __LINUX_BRIDGE_EBT_PKTTYPE_H
 
-struct ebt_pkttype_info
-{
+struct ebt_pkttype_info {
 	uint8_t pkt_type;
 	uint8_t invert;
 };
diff --git a/include/linux/netfilter_bridge/ebt_redirect.h b/include/linux/netfilter_bridge/ebt_redirect.h
index 5c67990..dd9622c 100644
--- a/include/linux/netfilter_bridge/ebt_redirect.h
+++ b/include/linux/netfilter_bridge/ebt_redirect.h
@@ -1,8 +1,7 @@
 #ifndef __LINUX_BRIDGE_EBT_REDIRECT_H
 #define __LINUX_BRIDGE_EBT_REDIRECT_H
 
-struct ebt_redirect_info
-{
+struct ebt_redirect_info {
 	/* EBT_ACCEPT, EBT_DROP, EBT_CONTINUE or EBT_RETURN */
 	int target;
 };
diff --git a/include/linux/netfilter_bridge/ebt_stp.h b/include/linux/netfilter_bridge/ebt_stp.h
index e5fd678..e503a0a 100644
--- a/include/linux/netfilter_bridge/ebt_stp.h
+++ b/include/linux/netfilter_bridge/ebt_stp.h
@@ -20,8 +20,7 @@
 
 #define EBT_STP_MATCH "stp"
 
-struct ebt_stp_config_info
-{
+struct ebt_stp_config_info {
 	uint8_t flags;
 	uint16_t root_priol, root_priou;
 	char root_addr[6], root_addrmsk[6];
@@ -35,8 +34,7 @@ struct ebt_stp_config_info
 	uint16_t forward_delayl, forward_delayu;
 };
 
-struct ebt_stp_info
-{
+struct ebt_stp_info {
 	uint8_t type;
 	struct ebt_stp_config_info config;
 	uint16_t bitmask;
diff --git a/include/linux/netfilter_bridge/ebtables.h b/include/linux/netfilter_bridge/ebtables.h
index ea281e6..3cc40c1 100644
--- a/include/linux/netfilter_bridge/ebtables.h
+++ b/include/linux/netfilter_bridge/ebtables.h
@@ -34,14 +34,12 @@
 struct xt_match;
 struct xt_target;
 
-struct ebt_counter
-{
+struct ebt_counter {
 	uint64_t pcnt;
 	uint64_t bcnt;
 };
 
-struct ebt_replace
-{
+struct ebt_replace {
 	char name[EBT_TABLE_MAXNAMELEN];
 	unsigned int valid_hooks;
 	/* nr of rules in the table */
@@ -57,8 +55,7 @@ struct ebt_replace
 	char __user *entries;
 };
 
-struct ebt_replace_kernel
-{
+struct ebt_replace_kernel {
 	char name[EBT_TABLE_MAXNAMELEN];
 	unsigned int valid_hooks;
 	/* nr of rules in the table */
@@ -120,8 +117,7 @@ struct ebt_entries {
 #define EBT_INV_MASK (EBT_IPROTO | EBT_IIN | EBT_IOUT | EBT_ILOGICALIN \
    | EBT_ILOGICALOUT | EBT_ISOURCE | EBT_IDEST)
 
-struct ebt_entry_match
-{
+struct ebt_entry_match {
 	union {
 		char name[EBT_FUNCTION_MAXNAMELEN];
 		struct xt_match *match;
@@ -131,8 +127,7 @@ struct ebt_entry_match
 	unsigned char data[0] __attribute__ ((aligned (__alignof__(struct ebt_replace))));
 };
 
-struct ebt_entry_watcher
-{
+struct ebt_entry_watcher {
 	union {
 		char name[EBT_FUNCTION_MAXNAMELEN];
 		struct xt_target *watcher;
@@ -142,8 +137,7 @@ struct ebt_entry_watcher
 	unsigned char data[0] __attribute__ ((aligned (__alignof__(struct ebt_replace))));
 };
 
-struct ebt_entry_target
-{
+struct ebt_entry_target {
 	union {
 		char name[EBT_FUNCTION_MAXNAMELEN];
 		struct xt_target *target;
@@ -154,8 +148,7 @@ struct ebt_entry_target
 };
 
 #define EBT_STANDARD_TARGET "standard"
-struct ebt_standard_target
-{
+struct ebt_standard_target {
 	struct ebt_entry_target target;
 	int verdict;
 };
@@ -206,8 +199,7 @@ struct ebt_entry {
 #define EBT_MATCH 0
 #define EBT_NOMATCH 1
 
-struct ebt_match
-{
+struct ebt_match {
 	struct list_head list;
 	const char name[EBT_FUNCTION_MAXNAMELEN];
 	bool (*match)(const struct sk_buff *skb, const struct net_device *in,
@@ -224,8 +216,7 @@ struct ebt_match
 	struct module *me;
 };
 
-struct ebt_watcher
-{
+struct ebt_watcher {
 	struct list_head list;
 	const char name[EBT_FUNCTION_MAXNAMELEN];
 	unsigned int (*target)(struct sk_buff *skb,
@@ -242,8 +233,7 @@ struct ebt_watcher
 	struct module *me;
 };
 
-struct ebt_target
-{
+struct ebt_target {
 	struct list_head list;
 	const char name[EBT_FUNCTION_MAXNAMELEN];
 	/* returns one of the standard EBT_* verdicts */
@@ -262,15 +252,13 @@ struct ebt_target
 };
 
 /* used for jumping from and into user defined chains (udc) */
-struct ebt_chainstack
-{
+struct ebt_chainstack {
 	struct ebt_entries *chaininfo; /* pointer to chain data */
 	struct ebt_entry *e; /* pointer to entry data */
 	unsigned int n; /* n'th entry */
 };
 
-struct ebt_table_info
-{
+struct ebt_table_info {
 	/* total size of the entries */
 	unsigned int entries_size;
 	unsigned int nentries;
@@ -282,8 +270,7 @@ struct ebt_table_info
 	struct ebt_counter counters[0] ____cacheline_aligned;
 };
 
-struct ebt_table
-{
+struct ebt_table {
 	struct list_head list;
 	char name[EBT_TABLE_MAXNAMELEN];
 	struct ebt_replace_kernel *table;
diff --git a/include/linux/netfilter_ipv4/ip_tables.h b/include/linux/netfilter_ipv4/ip_tables.h
index 61fafc8..27b3f58 100644
--- a/include/linux/netfilter_ipv4/ip_tables.h
+++ b/include/linux/netfilter_ipv4/ip_tables.h
@@ -76,8 +76,7 @@ struct ipt_ip {
 /* This structure defines each of the firewall rules.  Consists of 3
    parts which are 1) general IP header stuff 2) match specific
    stuff 3) the target to perform if the rule matches */
-struct ipt_entry
-{
+struct ipt_entry {
 	struct ipt_ip ip;
 
 	/* Mark with fields that we care about. */
@@ -135,8 +134,7 @@ struct ipt_entry
 #define IPT_UDP_INV_MASK	XT_UDP_INV_MASK
 
 /* ICMP matching stuff */
-struct ipt_icmp
-{
+struct ipt_icmp {
 	u_int8_t type;				/* type to match */
 	u_int8_t code[2];			/* range of code */
 	u_int8_t invflags;			/* Inverse flags */
@@ -146,8 +144,7 @@ struct ipt_icmp
 #define IPT_ICMP_INV	0x01	/* Invert the sense of type/code test */
 
 /* The argument to IPT_SO_GET_INFO */
-struct ipt_getinfo
-{
+struct ipt_getinfo {
 	/* Which table: caller fills this in. */
 	char name[IPT_TABLE_MAXNAMELEN];
 
@@ -169,8 +166,7 @@ struct ipt_getinfo
 };
 
 /* The argument to IPT_SO_SET_REPLACE. */
-struct ipt_replace
-{
+struct ipt_replace {
 	/* Which table. */
 	char name[IPT_TABLE_MAXNAMELEN];
 
@@ -204,8 +200,7 @@ struct ipt_replace
 #define ipt_counters_info xt_counters_info
 
 /* The argument to IPT_SO_GET_ENTRIES. */
-struct ipt_get_entries
-{
+struct ipt_get_entries {
 	/* Which table: user fills this in. */
 	char name[IPT_TABLE_MAXNAMELEN];
 
@@ -250,20 +245,17 @@ extern struct xt_table *ipt_register_table(struct net *net,
 extern void ipt_unregister_table(struct xt_table *table);
 
 /* Standard entry. */
-struct ipt_standard
-{
+struct ipt_standard {
 	struct ipt_entry entry;
 	struct ipt_standard_target target;
 };
 
-struct ipt_error_target
-{
+struct ipt_error_target {
 	struct ipt_entry_target target;
 	char errorname[IPT_FUNCTION_MAXNAMELEN];
 };
 
-struct ipt_error
-{
+struct ipt_error {
 	struct ipt_entry entry;
 	struct ipt_error_target target;
 };
@@ -301,8 +293,7 @@ extern unsigned int ipt_do_table(struct sk_buff *skb,
 #ifdef CONFIG_COMPAT
 #include <net/compat.h>
 
-struct compat_ipt_entry
-{
+struct compat_ipt_entry {
 	struct ipt_ip ip;
 	compat_uint_t nfcache;
 	u_int16_t target_offset;
diff --git a/include/linux/netfilter_ipv4/ipt_SAME.h b/include/linux/netfilter_ipv4/ipt_SAME.h
index be6e682..2529660 100644
--- a/include/linux/netfilter_ipv4/ipt_SAME.h
+++ b/include/linux/netfilter_ipv4/ipt_SAME.h
@@ -5,8 +5,7 @@
 
 #define IPT_SAME_NODST		0x01
 
-struct ipt_same_info
-{
+struct ipt_same_info {
 	unsigned char info;
 	u_int32_t rangesize;
 	u_int32_t ipnum;
diff --git a/include/linux/netfilter_ipv4/ipt_ah.h b/include/linux/netfilter_ipv4/ipt_ah.h
index 7b9a2ac..2e555b4 100644
--- a/include/linux/netfilter_ipv4/ipt_ah.h
+++ b/include/linux/netfilter_ipv4/ipt_ah.h
@@ -1,8 +1,7 @@
 #ifndef _IPT_AH_H
 #define _IPT_AH_H
 
-struct ipt_ah
-{
+struct ipt_ah {
 	u_int32_t spis[2];			/* Security Parameter Index */
 	u_int8_t  invflags;			/* Inverse flags */
 };
diff --git a/include/linux/netfilter_ipv6/ip6_tables.h b/include/linux/netfilter_ipv6/ip6_tables.h
index a64e145..b31050d 100644
--- a/include/linux/netfilter_ipv6/ip6_tables.h
+++ b/include/linux/netfilter_ipv6/ip6_tables.h
@@ -88,8 +88,7 @@ struct ip6t_ip6 {
 /* This structure defines each of the firewall rules.  Consists of 3
    parts which are 1) general IP header stuff 2) match specific
    stuff 3) the target to perform if the rule matches */
-struct ip6t_entry
-{
+struct ip6t_entry {
 	struct ip6t_ip6 ipv6;
 
 	/* Mark with fields that we care about. */
@@ -111,20 +110,17 @@ struct ip6t_entry
 };
 
 /* Standard entry */
-struct ip6t_standard
-{
+struct ip6t_standard {
 	struct ip6t_entry entry;
 	struct ip6t_standard_target target;
 };
 
-struct ip6t_error_target
-{
+struct ip6t_error_target {
 	struct ip6t_entry_target target;
 	char errorname[IP6T_FUNCTION_MAXNAMELEN];
 };
 
-struct ip6t_error
-{
+struct ip6t_error {
 	struct ip6t_entry entry;
 	struct ip6t_error_target target;
 };
@@ -195,8 +191,7 @@ struct ip6t_error
 #define IP6T_UDP_INV_MASK	XT_UDP_INV_MASK
 
 /* ICMP matching stuff */
-struct ip6t_icmp
-{
+struct ip6t_icmp {
 	u_int8_t type;				/* type to match */
 	u_int8_t code[2];			/* range of code */
 	u_int8_t invflags;			/* Inverse flags */
@@ -206,8 +201,7 @@ struct ip6t_icmp
 #define IP6T_ICMP_INV	0x01	/* Invert the sense of type/code test */
 
 /* The argument to IP6T_SO_GET_INFO */
-struct ip6t_getinfo
-{
+struct ip6t_getinfo {
 	/* Which table: caller fills this in. */
 	char name[IP6T_TABLE_MAXNAMELEN];
 
@@ -229,8 +223,7 @@ struct ip6t_getinfo
 };
 
 /* The argument to IP6T_SO_SET_REPLACE. */
-struct ip6t_replace
-{
+struct ip6t_replace {
 	/* Which table. */
 	char name[IP6T_TABLE_MAXNAMELEN];
 
@@ -264,8 +257,7 @@ struct ip6t_replace
 #define ip6t_counters_info xt_counters_info
 
 /* The argument to IP6T_SO_GET_ENTRIES. */
-struct ip6t_get_entries
-{
+struct ip6t_get_entries {
 	/* Which table: user fills this in. */
 	char name[IP6T_TABLE_MAXNAMELEN];
 
@@ -330,8 +322,7 @@ extern int ip6_masked_addrcmp(const struct in6_addr *addr1,
 #ifdef CONFIG_COMPAT
 #include <net/compat.h>
 
-struct compat_ip6t_entry
-{
+struct compat_ip6t_entry {
 	struct ip6t_ip6 ipv6;
 	compat_uint_t nfcache;
 	u_int16_t target_offset;
diff --git a/include/linux/netfilter_ipv6/ip6t_ah.h b/include/linux/netfilter_ipv6/ip6t_ah.h
index 8531879..17a745c 100644
--- a/include/linux/netfilter_ipv6/ip6t_ah.h
+++ b/include/linux/netfilter_ipv6/ip6t_ah.h
@@ -1,8 +1,7 @@
 #ifndef _IP6T_AH_H
 #define _IP6T_AH_H
 
-struct ip6t_ah
-{
+struct ip6t_ah {
 	u_int32_t spis[2];			/* Security Parameter Index */
 	u_int32_t hdrlen;			/* Header Length */
 	u_int8_t  hdrres;			/* Test of the Reserved Filed */
diff --git a/include/linux/netfilter_ipv6/ip6t_frag.h b/include/linux/netfilter_ipv6/ip6t_frag.h
index 66070a0..3724d08 100644
--- a/include/linux/netfilter_ipv6/ip6t_frag.h
+++ b/include/linux/netfilter_ipv6/ip6t_frag.h
@@ -1,8 +1,7 @@
 #ifndef _IP6T_FRAG_H
 #define _IP6T_FRAG_H
 
-struct ip6t_frag
-{
+struct ip6t_frag {
 	u_int32_t ids[2];			/* Security Parameter Index */
 	u_int32_t hdrlen;			/* Header Length */
 	u_int8_t  flags;			/*  */
diff --git a/include/linux/netfilter_ipv6/ip6t_ipv6header.h b/include/linux/netfilter_ipv6/ip6t_ipv6header.h
index 51c53fc..01dfd44 100644
--- a/include/linux/netfilter_ipv6/ip6t_ipv6header.h
+++ b/include/linux/netfilter_ipv6/ip6t_ipv6header.h
@@ -8,8 +8,7 @@ on whether they contain certain headers */
 #ifndef __IPV6HEADER_H
 #define __IPV6HEADER_H
 
-struct ip6t_ipv6header_info
-{
+struct ip6t_ipv6header_info {
 	u_int8_t matchflags;
 	u_int8_t invflags;
 	u_int8_t modeflag;
diff --git a/include/linux/netfilter_ipv6/ip6t_mh.h b/include/linux/netfilter_ipv6/ip6t_mh.h
index b9ca9a5..18549bc 100644
--- a/include/linux/netfilter_ipv6/ip6t_mh.h
+++ b/include/linux/netfilter_ipv6/ip6t_mh.h
@@ -2,8 +2,7 @@
 #define _IP6T_MH_H
 
 /* MH matching stuff */
-struct ip6t_mh
-{
+struct ip6t_mh {
 	u_int8_t types[2];	/* MH type range */
 	u_int8_t invflags;	/* Inverse flags */
 };
diff --git a/include/linux/netfilter_ipv6/ip6t_opts.h b/include/linux/netfilter_ipv6/ip6t_opts.h
index a07e363..62d89bc 100644
--- a/include/linux/netfilter_ipv6/ip6t_opts.h
+++ b/include/linux/netfilter_ipv6/ip6t_opts.h
@@ -3,8 +3,7 @@
 
 #define IP6T_OPTS_OPTSNR 16
 
-struct ip6t_opts
-{
+struct ip6t_opts {
 	u_int32_t hdrlen;			/* Header Length */
 	u_int8_t flags;				/*  */
 	u_int8_t invflags;			/* Inverse flags */
diff --git a/include/linux/netfilter_ipv6/ip6t_rt.h b/include/linux/netfilter_ipv6/ip6t_rt.h
index 5215602..ab91bfd 100644
--- a/include/linux/netfilter_ipv6/ip6t_rt.h
+++ b/include/linux/netfilter_ipv6/ip6t_rt.h
@@ -5,8 +5,7 @@
 
 #define IP6T_RT_HOPS 16
 
-struct ip6t_rt
-{
+struct ip6t_rt {
 	u_int32_t rt_type;			/* Routing Type */
 	u_int32_t segsleft[2];			/* Segments Left */
 	u_int32_t hdrlen;			/* Header Length */
diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index ab5d312..fde27c0 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -29,16 +29,14 @@
 
 struct net;
 
-struct sockaddr_nl
-{
+struct sockaddr_nl {
 	sa_family_t	nl_family;	/* AF_NETLINK	*/
 	unsigned short	nl_pad;		/* zero		*/
 	__u32		nl_pid;		/* port ID	*/
        	__u32		nl_groups;	/* multicast groups mask */
 };
 
-struct nlmsghdr
-{
+struct nlmsghdr {
 	__u32		nlmsg_len;	/* Length of message including header */
 	__u16		nlmsg_type;	/* Message content */
 	__u16		nlmsg_flags;	/* Additional flags */
@@ -94,8 +92,7 @@ struct nlmsghdr
 
 #define NLMSG_MIN_TYPE		0x10	/* < 0x10: reserved control messages */
 
-struct nlmsgerr
-{
+struct nlmsgerr {
 	int		error;
 	struct nlmsghdr msg;
 };
@@ -106,8 +103,7 @@ struct nlmsgerr
 #define NETLINK_BROADCAST_ERROR	4
 #define NETLINK_NO_ENOBUFS	5
 
-struct nl_pktinfo
-{
+struct nl_pktinfo {
 	__u32	group;
 };
 
@@ -127,8 +123,7 @@ enum {
  *  <-------------- nlattr->nla_len -------------->
  */
 
-struct nlattr
-{
+struct nlattr {
 	__u16           nla_len;
 	__u16           nla_type;
 };
@@ -161,8 +156,7 @@ static inline struct nlmsghdr *nlmsg_hdr(const struct sk_buff *skb)
 	return (struct nlmsghdr *)skb->data;
 }
 
-struct netlink_skb_parms
-{
+struct netlink_skb_parms {
 	struct ucred		creds;		/* Skb credentials	*/
 	__u32			pid;
 	__u32			dst_group;
@@ -220,8 +214,7 @@ int netlink_sendskb(struct sock *sk, struct sk_buff *skb);
 #define NLMSG_DEFAULT_SIZE (NLMSG_GOODSIZE - NLMSG_HDRLEN)
 
 
-struct netlink_callback
-{
+struct netlink_callback {
 	struct sk_buff		*skb;
 	const struct nlmsghdr	*nlh;
 	int			(*dump)(struct sk_buff * skb,
@@ -231,8 +224,7 @@ struct netlink_callback
 	long			args[6];
 };
 
-struct netlink_notify
-{
+struct netlink_notify {
 	struct net *net;
 	int pid;
 	int protocol;
diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
index 3c842ed..7f6ba86 100644
--- a/include/linux/pkt_cls.h
+++ b/include/linux/pkt_cls.h
@@ -75,8 +75,7 @@ bits 9,10,11: redirect counter -  redirect TTL. Loop avoidance
 #define SET_TC_AT(v,n)   ((V_TC_AT(n)) | (v & ~M_TC_AT))
 
 /* Action attributes */
-enum
-{
+enum {
 	TCA_ACT_UNSPEC,
 	TCA_ACT_KIND,
 	TCA_ACT_OPTIONS,
@@ -108,8 +107,7 @@ enum
 #define TC_ACT_JUMP		0x10000000
 
 /* Action type identifiers*/
-enum
-{
+enum {
 	TCA_ID_UNSPEC=0,
 	TCA_ID_POLICE=1,
 	/* other actions go here */
@@ -118,8 +116,7 @@ enum
 
 #define TCA_ID_MAX __TCA_ID_MAX
 
-struct tc_police
-{
+struct tc_police {
 	__u32			index;
 	int			action;
 #define TC_POLICE_UNSPEC	TC_ACT_UNSPEC
@@ -138,15 +135,13 @@ struct tc_police
 	__u32			capab;
 };
 
-struct tcf_t
-{
+struct tcf_t {
 	__u64   install;
 	__u64   lastuse;
 	__u64   expires;
 };
 
-struct tc_cnt
-{
+struct tc_cnt {
 	int                   refcnt; 
 	int                   bindcnt;
 };
@@ -158,8 +153,7 @@ struct tc_cnt
 	int                   refcnt; \
 	int                   bindcnt
 
-enum
-{
+enum {
 	TCA_POLICE_UNSPEC,
 	TCA_POLICE_TBF,
 	TCA_POLICE_RATE,
@@ -182,8 +176,7 @@ enum
 #define TC_U32_UNSPEC	0
 #define TC_U32_ROOT	(0xFFF00000)
 
-enum
-{
+enum {
 	TCA_U32_UNSPEC,
 	TCA_U32_CLASSID,
 	TCA_U32_HASH,
@@ -200,16 +193,14 @@ enum
 
 #define TCA_U32_MAX (__TCA_U32_MAX - 1)
 
-struct tc_u32_key
-{
+struct tc_u32_key {
 	__be32		mask;
 	__be32		val;
 	int		off;
 	int		offmask;
 };
 
-struct tc_u32_sel
-{
+struct tc_u32_sel {
 	unsigned char		flags;
 	unsigned char		offshift;
 	unsigned char		nkeys;
@@ -223,15 +214,13 @@ struct tc_u32_sel
 	struct tc_u32_key	keys[0];
 };
 
-struct tc_u32_mark
-{
+struct tc_u32_mark {
 	__u32		val;
 	__u32		mask;
 	__u32		success;
 };
 
-struct tc_u32_pcnt
-{
+struct tc_u32_pcnt {
 	__u64 rcnt;
 	__u64 rhit;
 	__u64 kcnts[0];
@@ -249,8 +238,7 @@ struct tc_u32_pcnt
 
 /* RSVP filter */
 
-enum
-{
+enum {
 	TCA_RSVP_UNSPEC,
 	TCA_RSVP_CLASSID,
 	TCA_RSVP_DST,
@@ -263,15 +251,13 @@ enum
 
 #define TCA_RSVP_MAX (__TCA_RSVP_MAX - 1 )
 
-struct tc_rsvp_gpi
-{
+struct tc_rsvp_gpi {
 	__u32	key;
 	__u32	mask;
 	int	offset;
 };
 
-struct tc_rsvp_pinfo
-{
+struct tc_rsvp_pinfo {
 	struct tc_rsvp_gpi dpi;
 	struct tc_rsvp_gpi spi;
 	__u8	protocol;
@@ -282,8 +268,7 @@ struct tc_rsvp_pinfo
 
 /* ROUTE filter */
 
-enum
-{
+enum {
 	TCA_ROUTE4_UNSPEC,
 	TCA_ROUTE4_CLASSID,
 	TCA_ROUTE4_TO,
@@ -299,8 +284,7 @@ enum
 
 /* FW filter */
 
-enum
-{
+enum {
 	TCA_FW_UNSPEC,
 	TCA_FW_CLASSID,
 	TCA_FW_POLICE,
@@ -314,8 +298,7 @@ enum
 
 /* TC index filter */
 
-enum
-{
+enum {
 	TCA_TCINDEX_UNSPEC,
 	TCA_TCINDEX_HASH,
 	TCA_TCINDEX_MASK,
@@ -331,8 +314,7 @@ enum
 
 /* Flow filter */
 
-enum
-{
+enum {
 	FLOW_KEY_SRC,
 	FLOW_KEY_DST,
 	FLOW_KEY_PROTO,
@@ -355,14 +337,12 @@ enum
 
 #define FLOW_KEY_MAX	(__FLOW_KEY_MAX - 1)
 
-enum
-{
+enum {
 	FLOW_MODE_MAP,
 	FLOW_MODE_HASH,
 };
 
-enum
-{
+enum {
 	TCA_FLOW_UNSPEC,
 	TCA_FLOW_KEYS,
 	TCA_FLOW_MODE,
@@ -383,8 +363,7 @@ enum
 
 /* Basic filter */
 
-enum
-{
+enum {
 	TCA_BASIC_UNSPEC,
 	TCA_BASIC_CLASSID,
 	TCA_BASIC_EMATCHES,
@@ -398,8 +377,7 @@ enum
 
 /* Cgroup classifier */
 
-enum
-{
+enum {
 	TCA_CGROUP_UNSPEC,
 	TCA_CGROUP_ACT,
 	TCA_CGROUP_POLICE,
@@ -411,14 +389,12 @@ enum
 
 /* Extended Matches */
 
-struct tcf_ematch_tree_hdr
-{
+struct tcf_ematch_tree_hdr {
 	__u16		nmatches;
 	__u16		progid;
 };
 
-enum
-{
+enum {
 	TCA_EMATCH_TREE_UNSPEC,
 	TCA_EMATCH_TREE_HDR,
 	TCA_EMATCH_TREE_LIST,
@@ -426,8 +402,7 @@ enum
 };
 #define TCA_EMATCH_TREE_MAX (__TCA_EMATCH_TREE_MAX - 1)
 
-struct tcf_ematch_hdr
-{
+struct tcf_ematch_hdr {
 	__u16		matchid;
 	__u16		kind;
 	__u16		flags;
@@ -457,8 +432,7 @@ struct tcf_ematch_hdr
 #define TCF_EM_REL_MASK	3
 #define TCF_EM_REL_VALID(v) (((v) & TCF_EM_REL_MASK) != TCF_EM_REL_MASK)
 
-enum
-{
+enum {
 	TCF_LAYER_LINK,
 	TCF_LAYER_NETWORK,
 	TCF_LAYER_TRANSPORT,
@@ -479,13 +453,11 @@ enum
 #define        TCF_EM_VLAN		6
 #define	TCF_EM_MAX		6
 
-enum
-{
+enum {
 	TCF_EM_PROG_TC
 };
 
-enum
-{
+enum {
 	TCF_EM_OPND_EQ,
 	TCF_EM_OPND_GT,
 	TCF_EM_OPND_LT
diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index d51a2b3..2cfa4bc 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -29,8 +29,7 @@
    Particular schedulers may have also their private records.
  */
 
-struct tc_stats
-{
+struct tc_stats {
 	__u64	bytes;			/* NUmber of enqueues bytes */
 	__u32	packets;		/* Number of enqueued packets	*/
 	__u32	drops;			/* Packets dropped because of lack of resources */
@@ -42,8 +41,7 @@ struct tc_stats
 	__u32	backlog;
 };
 
-struct tc_estimator
-{
+struct tc_estimator {
 	signed char	interval;
 	unsigned char	ewma_log;
 };
@@ -75,8 +73,7 @@ struct tc_estimator
 #define TC_H_ROOT	(0xFFFFFFFFU)
 #define TC_H_INGRESS    (0xFFFFFFF1U)
 
-struct tc_ratespec
-{
+struct tc_ratespec {
 	unsigned char	cell_log;
 	unsigned char	__reserved;
 	unsigned short	overhead;
@@ -109,8 +106,7 @@ enum {
 
 /* FIFO section */
 
-struct tc_fifo_qopt
-{
+struct tc_fifo_qopt {
 	__u32	limit;	/* Queue length: bytes for bfifo, packets for pfifo */
 };
 
@@ -119,8 +115,7 @@ struct tc_fifo_qopt
 #define TCQ_PRIO_BANDS	16
 #define TCQ_MIN_PRIO_BANDS 2
 
-struct tc_prio_qopt
-{
+struct tc_prio_qopt {
 	int	bands;			/* Number of bands */
 	__u8	priomap[TC_PRIO_MAX+1];	/* Map: logical priority -> PRIO band */
 };
@@ -134,8 +129,7 @@ struct tc_multiq_qopt {
 
 /* TBF section */
 
-struct tc_tbf_qopt
-{
+struct tc_tbf_qopt {
 	struct tc_ratespec rate;
 	struct tc_ratespec peakrate;
 	__u32		limit;
@@ -143,8 +137,7 @@ struct tc_tbf_qopt
 	__u32		mtu;
 };
 
-enum
-{
+enum {
 	TCA_TBF_UNSPEC,
 	TCA_TBF_PARMS,
 	TCA_TBF_RTAB,
@@ -161,8 +154,7 @@ enum
 
 /* SFQ section */
 
-struct tc_sfq_qopt
-{
+struct tc_sfq_qopt {
 	unsigned	quantum;	/* Bytes per round allocated to flow */
 	int		perturb_period;	/* Period of hash perturbation */
 	__u32		limit;		/* Maximal packets in queue */
@@ -170,8 +162,7 @@ struct tc_sfq_qopt
 	unsigned	flows;		/* Maximal number of flows  */
 };
 
-struct tc_sfq_xstats
-{
+struct tc_sfq_xstats {
 	__s32		allot;
 };
 
@@ -186,8 +177,7 @@ struct tc_sfq_xstats
 
 /* RED section */
 
-enum
-{
+enum {
 	TCA_RED_UNSPEC,
 	TCA_RED_PARMS,
 	TCA_RED_STAB,
@@ -196,8 +186,7 @@ enum
 
 #define TCA_RED_MAX (__TCA_RED_MAX - 1)
 
-struct tc_red_qopt
-{
+struct tc_red_qopt {
 	__u32		limit;		/* HARD maximal queue length (bytes)	*/
 	__u32		qth_min;	/* Min average length threshold (bytes) */
 	__u32		qth_max;	/* Max average length threshold (bytes) */
@@ -209,8 +198,7 @@ struct tc_red_qopt
 #define TC_RED_HARDDROP	2
 };
 
-struct tc_red_xstats
-{
+struct tc_red_xstats {
 	__u32           early;          /* Early drops */
 	__u32           pdrop;          /* Drops due to queue limits */
 	__u32           other;          /* Drops due to drop() calls */
@@ -221,8 +209,7 @@ struct tc_red_xstats
 
 #define MAX_DPs 16
 
-enum
-{
+enum {
        TCA_GRED_UNSPEC,
        TCA_GRED_PARMS,
        TCA_GRED_STAB,
@@ -232,8 +219,7 @@ enum
 
 #define TCA_GRED_MAX (__TCA_GRED_MAX - 1)
 
-struct tc_gred_qopt
-{
+struct tc_gred_qopt {
 	__u32		limit;        /* HARD maximal queue length (bytes)    */
 	__u32		qth_min;      /* Min average length threshold (bytes) */
 	__u32		qth_max;      /* Max average length threshold (bytes) */
@@ -253,8 +239,7 @@ struct tc_gred_qopt
 };
 
 /* gred setup */
-struct tc_gred_sopt
-{
+struct tc_gred_sopt {
 	__u32		DPs;
 	__u32		def_DP;
 	__u8		grio;
@@ -267,8 +252,7 @@ struct tc_gred_sopt
 #define TC_HTB_MAXDEPTH		8
 #define TC_HTB_PROTOVER		3 /* the same as HTB and TC's major */
 
-struct tc_htb_opt
-{
+struct tc_htb_opt {
 	struct tc_ratespec 	rate;
 	struct tc_ratespec 	ceil;
 	__u32	buffer;
@@ -277,8 +261,7 @@ struct tc_htb_opt
 	__u32	level;		/* out only */
 	__u32	prio;
 };
-struct tc_htb_glob
-{
+struct tc_htb_glob {
 	__u32 version;		/* to match HTB/TC */
     	__u32 rate2quantum;	/* bps->quantum divisor */
     	__u32 defcls;		/* default class number */
@@ -287,8 +270,7 @@ struct tc_htb_glob
 	/* stats */
 	__u32 direct_pkts; /* count of non shapped packets */
 };
-enum
-{
+enum {
 	TCA_HTB_UNSPEC,
 	TCA_HTB_PARMS,
 	TCA_HTB_INIT,
@@ -299,8 +281,7 @@ enum
 
 #define TCA_HTB_MAX (__TCA_HTB_MAX - 1)
 
-struct tc_htb_xstats
-{
+struct tc_htb_xstats {
 	__u32 lends;
 	__u32 borrows;
 	__u32 giants;	/* too big packets (rate will not be accurate) */
@@ -310,28 +291,24 @@ struct tc_htb_xstats
 
 /* HFSC section */
 
-struct tc_hfsc_qopt
-{
+struct tc_hfsc_qopt {
 	__u16	defcls;		/* default class */
 };
 
-struct tc_service_curve
-{
+struct tc_service_curve {
 	__u32	m1;		/* slope of the first segment in bps */
 	__u32	d;		/* x-projection of the first segment in us */
 	__u32	m2;		/* slope of the second segment in bps */
 };
 
-struct tc_hfsc_stats
-{
+struct tc_hfsc_stats {
 	__u64	work;		/* total work done */
 	__u64	rtwork;		/* work done by real-time criteria */
 	__u32	period;		/* current period */
 	__u32	level;		/* class level in hierarchy */
 };
 
-enum
-{
+enum {
 	TCA_HFSC_UNSPEC,
 	TCA_HFSC_RSC,
 	TCA_HFSC_FSC,
@@ -348,8 +325,7 @@ enum
 #define TC_CBQ_MAXLEVEL		8
 #define TC_CBQ_DEF_EWMA		5
 
-struct tc_cbq_lssopt
-{
+struct tc_cbq_lssopt {
 	unsigned char	change;
 	unsigned char	flags;
 #define TCF_CBQ_LSS_BOUNDED	1
@@ -368,8 +344,7 @@ struct tc_cbq_lssopt
 	__u32		avpkt;
 };
 
-struct tc_cbq_wrropt
-{
+struct tc_cbq_wrropt {
 	unsigned char	flags;
 	unsigned char	priority;
 	unsigned char	cpriority;
@@ -378,8 +353,7 @@ struct tc_cbq_wrropt
 	__u32		weight;
 };
 
-struct tc_cbq_ovl
-{
+struct tc_cbq_ovl {
 	unsigned char	strategy;
 #define	TC_CBQ_OVL_CLASSIC	0
 #define	TC_CBQ_OVL_DELAY	1
@@ -391,30 +365,26 @@ struct tc_cbq_ovl
 	__u32		penalty;
 };
 
-struct tc_cbq_police
-{
+struct tc_cbq_police {
 	unsigned char	police;
 	unsigned char	__res1;
 	unsigned short	__res2;
 };
 
-struct tc_cbq_fopt
-{
+struct tc_cbq_fopt {
 	__u32		split;
 	__u32		defmap;
 	__u32		defchange;
 };
 
-struct tc_cbq_xstats
-{
+struct tc_cbq_xstats {
 	__u32		borrows;
 	__u32		overactions;
 	__s32		avgidle;
 	__s32		undertime;
 };
 
-enum
-{
+enum {
 	TCA_CBQ_UNSPEC,
 	TCA_CBQ_LSSOPT,
 	TCA_CBQ_WRROPT,
@@ -459,8 +429,7 @@ enum {
 
 /* Network emulator */
 
-enum
-{
+enum {
 	TCA_NETEM_UNSPEC,
 	TCA_NETEM_CORR,
 	TCA_NETEM_DELAY_DIST,
@@ -471,8 +440,7 @@ enum
 
 #define TCA_NETEM_MAX (__TCA_NETEM_MAX - 1)
 
-struct tc_netem_qopt
-{
+struct tc_netem_qopt {
 	__u32	latency;	/* added delay (us) */
 	__u32   limit;		/* fifo limit (packets) */
 	__u32	loss;		/* random packet loss (0=none ~0=100%) */
@@ -481,21 +449,18 @@ struct tc_netem_qopt
 	__u32	jitter;		/* random jitter in latency (us) */
 };
 
-struct tc_netem_corr
-{
+struct tc_netem_corr {
 	__u32	delay_corr;	/* delay correlation */
 	__u32	loss_corr;	/* packet loss correlation */
 	__u32	dup_corr;	/* duplicate correlation  */
 };
 
-struct tc_netem_reorder
-{
+struct tc_netem_reorder {
 	__u32	probability;
 	__u32	correlation;
 };
 
-struct tc_netem_corrupt
-{
+struct tc_netem_corrupt {
 	__u32	probability;
 	__u32	correlation;
 };
@@ -504,8 +469,7 @@ struct tc_netem_corrupt
 
 /* DRR */
 
-enum
-{
+enum {
 	TCA_DRR_UNSPEC,
 	TCA_DRR_QUANTUM,
 	__TCA_DRR_MAX
@@ -513,8 +477,7 @@ enum
 
 #define TCA_DRR_MAX	(__TCA_DRR_MAX - 1)
 
-struct tc_drr_stats
-{
+struct tc_drr_stats {
 	__u32	deficit;
 };
 
diff --git a/include/linux/route.h b/include/linux/route.h
index f7ed35d..6600708 100644
--- a/include/linux/route.h
+++ b/include/linux/route.h
@@ -27,8 +27,7 @@
 #include <linux/compiler.h>
 
 /* This structure gets passed by the SIOCADDRT and SIOCDELRT calls. */
-struct rtentry 
-{
+struct rtentry {
 	unsigned long	rt_pad1;
 	struct sockaddr	rt_dst;		/* target address		*/
 	struct sockaddr	rt_gateway;	/* gateway addr (RTF_GATEWAY)	*/
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index e78b60c..14fc906 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -127,8 +127,7 @@ enum {
    with attribute type.
  */
 
-struct rtattr
-{
+struct rtattr {
 	unsigned short	rta_len;
 	unsigned short	rta_type;
 };
@@ -154,8 +153,7 @@ struct rtattr
  *		Definitions used in routing table administration.
  ****/
 
-struct rtmsg
-{
+struct rtmsg {
 	unsigned char		rtm_family;
 	unsigned char		rtm_dst_len;
 	unsigned char		rtm_src_len;
@@ -171,8 +169,7 @@ struct rtmsg
 
 /* rtm_type */
 
-enum
-{
+enum {
 	RTN_UNSPEC,
 	RTN_UNICAST,		/* Gateway or direct route	*/
 	RTN_LOCAL,		/* Accept locally		*/
@@ -230,8 +227,7 @@ enum
    could be assigned a value between UNIVERSE and LINK.
 */
 
-enum rt_scope_t
-{
+enum rt_scope_t {
 	RT_SCOPE_UNIVERSE=0,
 /* User defined values  */
 	RT_SCOPE_SITE=200,
@@ -249,8 +245,7 @@ enum rt_scope_t
 
 /* Reserved table identifiers */
 
-enum rt_class_t
-{
+enum rt_class_t {
 	RT_TABLE_UNSPEC=0,
 /* User defined values */
 	RT_TABLE_COMPAT=252,
@@ -263,8 +258,7 @@ enum rt_class_t
 
 /* Routing message attributes */
 
-enum rtattr_type_t
-{
+enum rtattr_type_t {
 	RTA_UNSPEC,
 	RTA_DST,
 	RTA_SRC,
@@ -298,8 +292,7 @@ enum rtattr_type_t
  * and rtt for different paths from multipath.
  */
 
-struct rtnexthop
-{
+struct rtnexthop {
 	unsigned short		rtnh_len;
 	unsigned char		rtnh_flags;
 	unsigned char		rtnh_hops;
@@ -325,8 +318,7 @@ struct rtnexthop
 
 /* RTM_CACHEINFO */
 
-struct rta_cacheinfo
-{
+struct rta_cacheinfo {
 	__u32	rta_clntref;
 	__u32	rta_lastuse;
 	__s32	rta_expires;
@@ -341,8 +333,7 @@ struct rta_cacheinfo
 
 /* RTM_METRICS --- array of struct rtattr with types of RTAX_* */
 
-enum
-{
+enum {
 	RTAX_UNSPEC,
 #define RTAX_UNSPEC RTAX_UNSPEC
 	RTAX_LOCK,
@@ -383,8 +374,7 @@ enum
 #define RTAX_FEATURE_NO_WSCALE	0x00000010
 #define RTAX_FEATURE_NO_DSACK	0x00000020
 
-struct rta_session
-{
+struct rta_session {
 	__u8	proto;
 	__u8	pad1;
 	__u16	pad2;
@@ -409,8 +399,7 @@ struct rta_session
  *		General form of address family dependent message.
  ****/
 
-struct rtgenmsg
-{
+struct rtgenmsg {
 	unsigned char		rtgen_family;
 };
 
@@ -423,8 +412,7 @@ struct rtgenmsg
  * on network protocol.
  */
 
-struct ifinfomsg
-{
+struct ifinfomsg {
 	unsigned char	ifi_family;
 	unsigned char	__ifi_pad;
 	unsigned short	ifi_type;		/* ARPHRD_* */
@@ -437,8 +425,7 @@ struct ifinfomsg
  *		prefix information 
  ****/
 
-struct prefixmsg
-{
+struct prefixmsg {
 	unsigned char	prefix_family;
 	unsigned char	prefix_pad1;
 	unsigned short	prefix_pad2;
@@ -459,8 +446,7 @@ enum
 
 #define PREFIX_MAX	(__PREFIX_MAX - 1)
 
-struct prefix_cacheinfo
-{
+struct prefix_cacheinfo {
 	__u32	preferred_time;
 	__u32	valid_time;
 };
@@ -470,8 +456,7 @@ struct prefix_cacheinfo
  *		Traffic control messages.
  ****/
 
-struct tcmsg
-{
+struct tcmsg {
 	unsigned char	tcm_family;
 	unsigned char	tcm__pad1;
 	unsigned short	tcm__pad2;
@@ -481,8 +466,7 @@ struct tcmsg
 	__u32		tcm_info;
 };
 
-enum
-{
+enum {
 	TCA_UNSPEC,
 	TCA_KIND,
 	TCA_OPTIONS,
@@ -504,8 +488,7 @@ enum
  *		Neighbor Discovery userland options
  ****/
 
-struct nduseroptmsg
-{
+struct nduseroptmsg {
 	unsigned char	nduseropt_family;
 	unsigned char	nduseropt_pad1;
 	unsigned short	nduseropt_opts_len;	/* Total length of options */
@@ -517,8 +500,7 @@ struct nduseroptmsg
 	/* Followed by one or more ND options */
 };
 
-enum
-{
+enum {
 	NDUSEROPT_UNSPEC,
 	NDUSEROPT_SRCADDR,
 	__NDUSEROPT_MAX
@@ -600,8 +582,7 @@ enum rtnetlink_groups {
 #define RTNLGRP_MAX	(__RTNLGRP_MAX - 1)
 
 /* TC action piece */
-struct tcamsg
-{
+struct tcamsg {
 	unsigned char	tca_family;
 	unsigned char	tca__pad1;
 	unsigned short	tca__pad2;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 0c68fbd..d0448c5 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -491,8 +491,7 @@ extern int skb_append_datato_frags(struct sock *sk, struct sk_buff *skb,
 			int len,int odd, struct sk_buff *skb),
 			void *from, int length);
 
-struct skb_seq_state
-{
+struct skb_seq_state {
 	__u32		lower_offset;
 	__u32		upper_offset;
 	__u32		frag_idx;
diff --git a/include/linux/tc_act/tc_defact.h b/include/linux/tc_act/tc_defact.h
index 964f473..6f65d07 100644
--- a/include/linux/tc_act/tc_defact.h
+++ b/include/linux/tc_act/tc_defact.h
@@ -3,13 +3,11 @@
 
 #include <linux/pkt_cls.h>
 
-struct tc_defact
-{
+struct tc_defact {
 	tc_gen;
 };
                                                                                 
-enum
-{
+enum {
 	TCA_DEF_UNSPEC,
 	TCA_DEF_TM,
 	TCA_DEF_PARMS,
diff --git a/include/linux/tc_act/tc_gact.h b/include/linux/tc_act/tc_gact.h
index e895c0a..f7bf94e 100644
--- a/include/linux/tc_act/tc_gact.h
+++ b/include/linux/tc_act/tc_gact.h
@@ -5,14 +5,12 @@
 #include <linux/pkt_cls.h>
 
 #define TCA_ACT_GACT 5
-struct tc_gact
-{
+struct tc_gact {
 	tc_gen;
 
 };
 
-struct tc_gact_p
-{
+struct tc_gact_p {
 #define PGACT_NONE              0
 #define PGACT_NETRAND           1
 #define PGACT_DETERM            2
@@ -22,8 +20,7 @@ struct tc_gact_p
 	int                   paction;
 };
  
-enum
-{
+enum {
 	TCA_GACT_UNSPEC,
 	TCA_GACT_TM,
 	TCA_GACT_PARMS,
diff --git a/include/linux/tc_act/tc_ipt.h b/include/linux/tc_act/tc_ipt.h
index 4b6f7b6..a233556 100644
--- a/include/linux/tc_act/tc_ipt.h
+++ b/include/linux/tc_act/tc_ipt.h
@@ -5,8 +5,7 @@
 
 #define TCA_ACT_IPT 6
 
-enum
-{
+enum {
 	TCA_IPT_UNSPEC,
 	TCA_IPT_TABLE,
 	TCA_IPT_HOOK,
diff --git a/include/linux/tc_act/tc_mirred.h b/include/linux/tc_act/tc_mirred.h
index 0a99ab6..7561750 100644
--- a/include/linux/tc_act/tc_mirred.h
+++ b/include/linux/tc_act/tc_mirred.h
@@ -10,15 +10,13 @@
 #define TCA_INGRESS_REDIR 3  /* packet redirect to INGRESS*/
 #define TCA_INGRESS_MIRROR 4 /* mirror packet to INGRESS */
                                                                                 
-struct tc_mirred
-{
+struct tc_mirred {
 	tc_gen;
 	int                     eaction;   /* one of IN/EGRESS_MIRROR/REDIR */
 	__u32                   ifindex;  /* ifindex of egress port */
 };
                                                                                 
-enum
-{
+enum {
 	TCA_MIRRED_UNSPEC,
 	TCA_MIRRED_TM,
 	TCA_MIRRED_PARMS,
diff --git a/include/linux/tc_act/tc_nat.h b/include/linux/tc_act/tc_nat.h
index e7cf31e..6663aeb 100644
--- a/include/linux/tc_act/tc_nat.h
+++ b/include/linux/tc_act/tc_nat.h
@@ -6,8 +6,7 @@
 
 #define TCA_ACT_NAT 9
 
-enum
-{
+enum {
 	TCA_NAT_UNSPEC,
 	TCA_NAT_PARMS,
 	TCA_NAT_TM,
@@ -17,8 +16,7 @@ enum
 
 #define TCA_NAT_FLAG_EGRESS 1
 
-struct tc_nat
-{
+struct tc_nat {
 	tc_gen;
 	__be32 old_addr;
 	__be32 new_addr;
diff --git a/include/linux/tc_act/tc_pedit.h b/include/linux/tc_act/tc_pedit.h
index 54ce906..716cfab 100644
--- a/include/linux/tc_act/tc_pedit.h
+++ b/include/linux/tc_act/tc_pedit.h
@@ -6,8 +6,7 @@
 
 #define TCA_ACT_PEDIT 7
 
-enum
-{
+enum {
 	TCA_PEDIT_UNSPEC,
 	TCA_PEDIT_TM,
 	TCA_PEDIT_PARMS,
@@ -15,8 +14,7 @@ enum
 };
 #define TCA_PEDIT_MAX (__TCA_PEDIT_MAX - 1)
                                                                                 
-struct tc_pedit_key
-{
+struct tc_pedit_key {
 	__u32           mask;  /* AND */
 	__u32           val;   /*XOR */
 	__u32           off;  /*offset */
@@ -25,8 +23,7 @@ struct tc_pedit_key
 	__u32           shift;
 };
                                                                                 
-struct tc_pedit_sel
-{
+struct tc_pedit_sel {
 	tc_gen;
 	unsigned char           nkeys;
 	unsigned char           flags;
diff --git a/include/linux/tc_ematch/tc_em_cmp.h b/include/linux/tc_ematch/tc_em_cmp.h
index 38e7f7b..f34bb1b 100644
--- a/include/linux/tc_ematch/tc_em_cmp.h
+++ b/include/linux/tc_ematch/tc_em_cmp.h
@@ -4,8 +4,7 @@
 #include <linux/types.h>
 #include <linux/pkt_cls.h>
 
-struct tcf_em_cmp
-{
+struct tcf_em_cmp {
 	__u32		val;
 	__u32		mask;
 	__u16		off;
@@ -15,8 +14,7 @@ struct tcf_em_cmp
 	__u8		opnd:4;
 };
 
-enum
-{
+enum {
 	TCF_EM_ALIGN_U8  = 1,
 	TCF_EM_ALIGN_U16 = 2,
 	TCF_EM_ALIGN_U32 = 4
diff --git a/include/linux/tc_ematch/tc_em_meta.h b/include/linux/tc_ematch/tc_em_meta.h
index dcfb733..0864206 100644
--- a/include/linux/tc_ematch/tc_em_meta.h
+++ b/include/linux/tc_ematch/tc_em_meta.h
@@ -4,8 +4,7 @@
 #include <linux/types.h>
 #include <linux/pkt_cls.h>
 
-enum
-{
+enum {
 	TCA_EM_META_UNSPEC,
 	TCA_EM_META_HDR,
 	TCA_EM_META_LVALUE,
@@ -14,8 +13,7 @@ enum
 };
 #define TCA_EM_META_MAX (__TCA_EM_META_MAX - 1)
 
-struct tcf_meta_val
-{
+struct tcf_meta_val {
 	__u16			kind;
 	__u8			shift;
 	__u8			op;
@@ -26,16 +24,14 @@ struct tcf_meta_val
 #define TCF_META_ID_MASK	0x7ff
 #define TCF_META_ID(kind)	((kind) & TCF_META_ID_MASK)
 
-enum
-{
+enum {
 	TCF_META_TYPE_VAR,
 	TCF_META_TYPE_INT,
 	__TCF_META_TYPE_MAX
 };
 #define TCF_META_TYPE_MAX (__TCF_META_TYPE_MAX - 1)
 
-enum
-{
+enum {
 	TCF_META_ID_VALUE,
 	TCF_META_ID_RANDOM,
 	TCF_META_ID_LOADAVG_0,
@@ -87,8 +83,7 @@ enum
 };
 #define TCF_META_ID_MAX (__TCF_META_ID_MAX - 1)
 
-struct tcf_meta_hdr
-{
+struct tcf_meta_hdr {
 	struct tcf_meta_val	left;
 	struct tcf_meta_val	right;
 };
diff --git a/include/linux/tc_ematch/tc_em_nbyte.h b/include/linux/tc_ematch/tc_em_nbyte.h
index 9ed8c2e..7172cfb 100644
--- a/include/linux/tc_ematch/tc_em_nbyte.h
+++ b/include/linux/tc_ematch/tc_em_nbyte.h
@@ -4,8 +4,7 @@
 #include <linux/types.h>
 #include <linux/pkt_cls.h>
 
-struct tcf_em_nbyte
-{
+struct tcf_em_nbyte {
 	__u16		off;
 	__u16		len:12;
 	__u8		layer:4;
diff --git a/include/linux/tc_ematch/tc_em_text.h b/include/linux/tc_ematch/tc_em_text.h
index d12a73a..5aac404 100644
--- a/include/linux/tc_ematch/tc_em_text.h
+++ b/include/linux/tc_ematch/tc_em_text.h
@@ -6,8 +6,7 @@
 
 #define TC_EM_TEXT_ALGOSIZ	16
 
-struct tcf_em_text
-{
+struct tcf_em_text {
 	char		algo[TC_EM_TEXT_ALGOSIZ];
 	__u16		from_offset;
 	__u16		to_offset;
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 61723a7..eeecb85 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -102,8 +102,7 @@ enum {
 #define TCPI_OPT_WSCALE		4
 #define TCPI_OPT_ECN		8
 
-enum tcp_ca_state
-{
+enum tcp_ca_state {
 	TCP_CA_Open = 0,
 #define TCPF_CA_Open	(1<<TCP_CA_Open)
 	TCP_CA_Disorder = 1,
@@ -116,8 +115,7 @@ enum tcp_ca_state
 #define TCPF_CA_Loss	(1<<TCP_CA_Loss)
 };
 
-struct tcp_info
-{
+struct tcp_info {
 	__u8	tcpi_state;
 	__u8	tcpi_ca_state;
 	__u8	tcpi_retransmits;
diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index 2d4ec15..3246f0e 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -10,8 +10,7 @@
 /* Structure to encapsulate addresses. I do not want to use
  * "standard" structure. My apologies.
  */
-typedef union
-{
+typedef union {
 	__be32		a4;
 	__be32		a6[4];
 } xfrm_address_t;
@@ -20,8 +19,7 @@ typedef union
  * the state by (spi,daddr,ah/esp) or to store information about
  * spi, protocol and tunnel address on output.
  */
-struct xfrm_id
-{
+struct xfrm_id {
 	xfrm_address_t	daddr;
 	__be32		spi;
 	__u8		proto;
@@ -45,8 +43,7 @@ struct xfrm_sec_ctx {
 
 /* Selector, used as selector both on policy rules (SPD) and SAs. */
 
-struct xfrm_selector
-{
+struct xfrm_selector {
 	xfrm_address_t	daddr;
 	xfrm_address_t	saddr;
 	__be16	dport;
@@ -63,8 +60,7 @@ struct xfrm_selector
 
 #define XFRM_INF (~(__u64)0)
 
-struct xfrm_lifetime_cfg
-{
+struct xfrm_lifetime_cfg {
 	__u64	soft_byte_limit;
 	__u64	hard_byte_limit;
 	__u64	soft_packet_limit;
@@ -75,16 +71,14 @@ struct xfrm_lifetime_cfg
 	__u64	hard_use_expires_seconds;
 };
 
-struct xfrm_lifetime_cur
-{
+struct xfrm_lifetime_cur {
 	__u64	bytes;
 	__u64	packets;
 	__u64	add_time;
 	__u64	use_time;
 };
 
-struct xfrm_replay_state
-{
+struct xfrm_replay_state {
 	__u32	oseq;
 	__u32	seq;
 	__u32	bitmap;
@@ -109,16 +103,14 @@ struct xfrm_stats {
 	__u32	integrity_failed;
 };
 
-enum
-{
+enum {
 	XFRM_POLICY_TYPE_MAIN	= 0,
 	XFRM_POLICY_TYPE_SUB	= 1,
 	XFRM_POLICY_TYPE_MAX	= 2,
 	XFRM_POLICY_TYPE_ANY	= 255
 };
 
-enum
-{
+enum {
 	XFRM_POLICY_IN	= 0,
 	XFRM_POLICY_OUT	= 1,
 	XFRM_POLICY_FWD	= 2,
@@ -126,8 +118,7 @@ enum
 	XFRM_POLICY_MAX	= 3
 };
 
-enum
-{
+enum {
 	XFRM_SHARE_ANY,		/* No limitations */
 	XFRM_SHARE_SESSION,	/* For this session only */
 	XFRM_SHARE_USER,	/* For this user only */
