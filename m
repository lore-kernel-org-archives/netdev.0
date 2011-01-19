From: kaber@trash.net
Subject: [PATCH 67/79] netfilter: xtables: use __uXX guarded types for userspace exports
Date: Wed, 19 Jan 2011 20:15:07 +0100
Message-ID: <1295464519-21763-68-git-send-email-kaber@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1295464519-21763-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 include/linux/netfilter_bridge/ebt_802_3.h     |   24 ++++++++++++------------
 include/linux/netfilter_bridge/ebt_among.h     |    2 +-
 include/linux/netfilter_bridge/ebt_arp.h       |    4 ++--
 include/linux/netfilter_bridge/ebt_ip.h        |   12 ++++++------
 include/linux/netfilter_bridge/ebt_ip6.h       |   16 ++++++++--------
 include/linux/netfilter_bridge/ebt_limit.h     |    8 ++++----
 include/linux/netfilter_bridge/ebt_log.h       |    6 +++---
 include/linux/netfilter_bridge/ebt_mark_m.h    |    4 ++--
 include/linux/netfilter_bridge/ebt_nflog.h     |   10 +++++-----
 include/linux/netfilter_bridge/ebt_pkttype.h   |    4 ++--
 include/linux/netfilter_bridge/ebt_stp.h       |   24 ++++++++++++------------
 include/linux/netfilter_bridge/ebt_ulog.h      |    2 +-
 include/linux/netfilter_bridge/ebt_vlan.h      |    8 ++++----
 include/linux/netfilter_ipv4/ipt_CLUSTERIP.h   |   14 +++++++-------
 include/linux/netfilter_ipv4/ipt_ECN.h         |    6 +++---
 include/linux/netfilter_ipv4/ipt_SAME.h        |    6 +++---
 include/linux/netfilter_ipv4/ipt_TTL.h         |    4 ++--
 include/linux/netfilter_ipv4/ipt_addrtype.h    |   14 +++++++-------
 include/linux/netfilter_ipv4/ipt_ah.h          |    4 ++--
 include/linux/netfilter_ipv4/ipt_ecn.h         |    8 ++++----
 include/linux/netfilter_ipv4/ipt_ttl.h         |    4 ++--
 include/linux/netfilter_ipv6/ip6t_HL.h         |    4 ++--
 include/linux/netfilter_ipv6/ip6t_REJECT.h     |    2 +-
 include/linux/netfilter_ipv6/ip6t_ah.h         |    8 ++++----
 include/linux/netfilter_ipv6/ip6t_frag.h       |    8 ++++----
 include/linux/netfilter_ipv6/ip6t_hl.h         |    4 ++--
 include/linux/netfilter_ipv6/ip6t_ipv6header.h |    6 +++---
 include/linux/netfilter_ipv6/ip6t_mh.h         |    4 ++--
 include/linux/netfilter_ipv6/ip6t_opts.h       |   10 +++++-----
 include/linux/netfilter_ipv6/ip6t_rt.h         |   12 ++++++------
 30 files changed, 121 insertions(+), 121 deletions(-)

diff --git a/include/linux/netfilter_bridge/ebt_802_3.h b/include/linux/netfilter_bridge/ebt_802_3.h
index c73ef0b..c427764 100644
--- a/include/linux/netfilter_bridge/ebt_802_3.h
+++ b/include/linux/netfilter_bridge/ebt_802_3.h
@@ -24,24 +24,24 @@
 
 /* ui has one byte ctrl, ni has two */
 struct hdr_ui {
-	uint8_t dsap;
-	uint8_t ssap;
-	uint8_t ctrl;
-	uint8_t orig[3];
+	__u8 dsap;
+	__u8 ssap;
+	__u8 ctrl;
+	__u8 orig[3];
 	__be16 type;
 };
 
 struct hdr_ni {
-	uint8_t dsap;
-	uint8_t ssap;
+	__u8 dsap;
+	__u8 ssap;
 	__be16 ctrl;
-	uint8_t  orig[3];
+	__u8  orig[3];
 	__be16 type;
 };
 
 struct ebt_802_3_hdr {
-	uint8_t  daddr[6];
-	uint8_t  saddr[6];
+	__u8  daddr[6];
+	__u8  saddr[6];
 	__be16 len;
 	union {
 		struct hdr_ui ui;
@@ -59,10 +59,10 @@ static inline struct ebt_802_3_hdr *ebt_802_3_hdr(const struct sk_buff *skb)
 #endif
 
 struct ebt_802_3_info {
-	uint8_t  sap;
+	__u8  sap;
 	__be16 type;
-	uint8_t  bitmask;
-	uint8_t  invflags;
+	__u8  bitmask;
+	__u8  invflags;
 };
 
 #endif
diff --git a/include/linux/netfilter_bridge/ebt_among.h b/include/linux/netfilter_bridge/ebt_among.h
index 0009558..686c961 100644
--- a/include/linux/netfilter_bridge/ebt_among.h
+++ b/include/linux/netfilter_bridge/ebt_among.h
@@ -30,7 +30,7 @@
  */
 
 struct ebt_mac_wormhash_tuple {
-	uint32_t cmp[2];
+	__u32 cmp[2];
 	__be32 ip;
 };
 
diff --git a/include/linux/netfilter_bridge/ebt_arp.h b/include/linux/netfilter_bridge/ebt_arp.h
index cbf4843..e62b5af 100644
--- a/include/linux/netfilter_bridge/ebt_arp.h
+++ b/include/linux/netfilter_bridge/ebt_arp.h
@@ -27,8 +27,8 @@ struct ebt_arp_info
 	unsigned char smmsk[ETH_ALEN];
 	unsigned char dmaddr[ETH_ALEN];
 	unsigned char dmmsk[ETH_ALEN];
-	uint8_t  bitmask;
-	uint8_t  invflags;
+	__u8  bitmask;
+	__u8  invflags;
 };
 
 #endif
diff --git a/include/linux/netfilter_bridge/ebt_ip.h b/include/linux/netfilter_bridge/ebt_ip.h
index 6a708fb..d99de58 100644
--- a/include/linux/netfilter_bridge/ebt_ip.h
+++ b/include/linux/netfilter_bridge/ebt_ip.h
@@ -31,12 +31,12 @@ struct ebt_ip_info {
 	__be32 daddr;
 	__be32 smsk;
 	__be32 dmsk;
-	uint8_t  tos;
-	uint8_t  protocol;
-	uint8_t  bitmask;
-	uint8_t  invflags;
-	uint16_t sport[2];
-	uint16_t dport[2];
+	__u8  tos;
+	__u8  protocol;
+	__u8  bitmask;
+	__u8  invflags;
+	__u16 sport[2];
+	__u16 dport[2];
 };
 
 #endif
diff --git a/include/linux/netfilter_bridge/ebt_ip6.h b/include/linux/netfilter_bridge/ebt_ip6.h
index 22af18a..998e9d5 100644
--- a/include/linux/netfilter_bridge/ebt_ip6.h
+++ b/include/linux/netfilter_bridge/ebt_ip6.h
@@ -31,17 +31,17 @@ struct ebt_ip6_info {
 	struct in6_addr daddr;
 	struct in6_addr smsk;
 	struct in6_addr dmsk;
-	uint8_t  tclass;
-	uint8_t  protocol;
-	uint8_t  bitmask;
-	uint8_t  invflags;
+	__u8  tclass;
+	__u8  protocol;
+	__u8  bitmask;
+	__u8  invflags;
 	union {
-		uint16_t sport[2];
-		uint8_t icmpv6_type[2];
+		__u16 sport[2];
+		__u8 icmpv6_type[2];
 	};
 	union {
-		uint16_t dport[2];
-		uint8_t icmpv6_code[2];
+		__u16 dport[2];
+		__u8 icmpv6_code[2];
 	};
 };
 
diff --git a/include/linux/netfilter_bridge/ebt_limit.h b/include/linux/netfilter_bridge/ebt_limit.h
index 4bf76b7..721d51f 100644
--- a/include/linux/netfilter_bridge/ebt_limit.h
+++ b/include/linux/netfilter_bridge/ebt_limit.h
@@ -10,13 +10,13 @@
    seconds, or one every 59 hours. */
 
 struct ebt_limit_info {
-	u_int32_t avg;    /* Average secs between packets * scale */
-	u_int32_t burst;  /* Period multiplier for upper limit. */
+	__u32 avg;    /* Average secs between packets * scale */
+	__u32 burst;  /* Period multiplier for upper limit. */
 
 	/* Used internally by the kernel */
 	unsigned long prev;
-	u_int32_t credit;
-	u_int32_t credit_cap, cost;
+	__u32 credit;
+	__u32 credit_cap, cost;
 };
 
 #endif
diff --git a/include/linux/netfilter_bridge/ebt_log.h b/include/linux/netfilter_bridge/ebt_log.h
index cc2cdfb..564beb4 100644
--- a/include/linux/netfilter_bridge/ebt_log.h
+++ b/include/linux/netfilter_bridge/ebt_log.h
@@ -10,9 +10,9 @@
 #define EBT_LOG_WATCHER "log"
 
 struct ebt_log_info {
-	uint8_t loglevel;
-	uint8_t prefix[EBT_LOG_PREFIX_SIZE];
-	uint32_t bitmask;
+	__u8 loglevel;
+	__u8 prefix[EBT_LOG_PREFIX_SIZE];
+	__u32 bitmask;
 };
 
 #endif
diff --git a/include/linux/netfilter_bridge/ebt_mark_m.h b/include/linux/netfilter_bridge/ebt_mark_m.h
index 9ceb10e..97b96c4 100644
--- a/include/linux/netfilter_bridge/ebt_mark_m.h
+++ b/include/linux/netfilter_bridge/ebt_mark_m.h
@@ -6,8 +6,8 @@
 #define EBT_MARK_MASK (EBT_MARK_AND | EBT_MARK_OR)
 struct ebt_mark_m_info {
 	unsigned long mark, mask;
-	uint8_t invert;
-	uint8_t bitmask;
+	__u8 invert;
+	__u8 bitmask;
 };
 #define EBT_MARK_MATCH "mark_m"
 
diff --git a/include/linux/netfilter_bridge/ebt_nflog.h b/include/linux/netfilter_bridge/ebt_nflog.h
index 0528178..477315b 100644
--- a/include/linux/netfilter_bridge/ebt_nflog.h
+++ b/include/linux/netfilter_bridge/ebt_nflog.h
@@ -10,11 +10,11 @@
 #define EBT_NFLOG_DEFAULT_THRESHOLD	1
 
 struct ebt_nflog_info {
-	u_int32_t len;
-	u_int16_t group;
-	u_int16_t threshold;
-	u_int16_t flags;
-	u_int16_t pad;
+	__u32 len;
+	__u16 group;
+	__u16 threshold;
+	__u16 flags;
+	__u16 pad;
 	char prefix[EBT_NFLOG_PREFIX_SIZE];
 };
 
diff --git a/include/linux/netfilter_bridge/ebt_pkttype.h b/include/linux/netfilter_bridge/ebt_pkttype.h
index 51a7998..7c0fb0f 100644
--- a/include/linux/netfilter_bridge/ebt_pkttype.h
+++ b/include/linux/netfilter_bridge/ebt_pkttype.h
@@ -2,8 +2,8 @@
 #define __LINUX_BRIDGE_EBT_PKTTYPE_H
 
 struct ebt_pkttype_info {
-	uint8_t pkt_type;
-	uint8_t invert;
+	__u8 pkt_type;
+	__u8 invert;
 };
 #define EBT_PKTTYPE_MATCH "pkttype"
 
diff --git a/include/linux/netfilter_bridge/ebt_stp.h b/include/linux/netfilter_bridge/ebt_stp.h
index e503a0a..13a0bd4 100644
--- a/include/linux/netfilter_bridge/ebt_stp.h
+++ b/include/linux/netfilter_bridge/ebt_stp.h
@@ -21,24 +21,24 @@
 #define EBT_STP_MATCH "stp"
 
 struct ebt_stp_config_info {
-	uint8_t flags;
-	uint16_t root_priol, root_priou;
+	__u8 flags;
+	__u16 root_priol, root_priou;
 	char root_addr[6], root_addrmsk[6];
-	uint32_t root_costl, root_costu;
-	uint16_t sender_priol, sender_priou;
+	__u32 root_costl, root_costu;
+	__u16 sender_priol, sender_priou;
 	char sender_addr[6], sender_addrmsk[6];
-	uint16_t portl, portu;
-	uint16_t msg_agel, msg_ageu;
-	uint16_t max_agel, max_ageu;
-	uint16_t hello_timel, hello_timeu;
-	uint16_t forward_delayl, forward_delayu;
+	__u16 portl, portu;
+	__u16 msg_agel, msg_ageu;
+	__u16 max_agel, max_ageu;
+	__u16 hello_timel, hello_timeu;
+	__u16 forward_delayl, forward_delayu;
 };
 
 struct ebt_stp_info {
-	uint8_t type;
+	__u8 type;
 	struct ebt_stp_config_info config;
-	uint16_t bitmask;
-	uint16_t invflags;
+	__u16 bitmask;
+	__u16 invflags;
 };
 
 #endif
diff --git a/include/linux/netfilter_bridge/ebt_ulog.h b/include/linux/netfilter_bridge/ebt_ulog.h
index b677e26..de35a51 100644
--- a/include/linux/netfilter_bridge/ebt_ulog.h
+++ b/include/linux/netfilter_bridge/ebt_ulog.h
@@ -10,7 +10,7 @@
 #define EBT_ULOG_VERSION 1
 
 struct ebt_ulog_info {
-	uint32_t nlgroup;
+	__u32 nlgroup;
 	unsigned int cprange;
 	unsigned int qthreshold;
 	char prefix[EBT_ULOG_PREFIX_LEN];
diff --git a/include/linux/netfilter_bridge/ebt_vlan.h b/include/linux/netfilter_bridge/ebt_vlan.h
index 1d98be4..48dffc1 100644
--- a/include/linux/netfilter_bridge/ebt_vlan.h
+++ b/include/linux/netfilter_bridge/ebt_vlan.h
@@ -8,12 +8,12 @@
 #define EBT_VLAN_MATCH "vlan"
 
 struct ebt_vlan_info {
-	uint16_t id;		/* VLAN ID {1-4095} */
-	uint8_t prio;		/* VLAN User Priority {0-7} */
+	__u16 id;		/* VLAN ID {1-4095} */
+	__u8 prio;		/* VLAN User Priority {0-7} */
 	__be16 encap;		/* VLAN Encapsulated frame code {0-65535} */
-	uint8_t bitmask;		/* Args bitmask bit 1=1 - ID arg,
+	__u8 bitmask;		/* Args bitmask bit 1=1 - ID arg,
 				   bit 2=1 User-Priority arg, bit 3=1 encap*/
-	uint8_t invflags;		/* Inverse bitmask  bit 1=1 - inversed ID arg, 
+	__u8 invflags;		/* Inverse bitmask  bit 1=1 - inversed ID arg, 
 				   bit 2=1 - inversed Pirority arg */
 };
 
diff --git a/include/linux/netfilter_ipv4/ipt_CLUSTERIP.h b/include/linux/netfilter_ipv4/ipt_CLUSTERIP.h
index e5a3687..3114f06 100644
--- a/include/linux/netfilter_ipv4/ipt_CLUSTERIP.h
+++ b/include/linux/netfilter_ipv4/ipt_CLUSTERIP.h
@@ -17,15 +17,15 @@ struct clusterip_config;
 
 struct ipt_clusterip_tgt_info {
 
-	u_int32_t flags;
+	__u32 flags;
 
 	/* only relevant for new ones */
-	u_int8_t clustermac[6];
-	u_int16_t num_total_nodes;
-	u_int16_t num_local_nodes;
-	u_int16_t local_nodes[CLUSTERIP_MAX_NODES];
-	u_int32_t hash_mode;
-	u_int32_t hash_initval;
+	__u8 clustermac[6];
+	__u16 num_total_nodes;
+	__u16 num_local_nodes;
+	__u16 local_nodes[CLUSTERIP_MAX_NODES];
+	__u32 hash_mode;
+	__u32 hash_initval;
 
 	/* Used internally by the kernel */
 	struct clusterip_config *config;
diff --git a/include/linux/netfilter_ipv4/ipt_ECN.h b/include/linux/netfilter_ipv4/ipt_ECN.h
index 7ca4591..c6e3e01 100644
--- a/include/linux/netfilter_ipv4/ipt_ECN.h
+++ b/include/linux/netfilter_ipv4/ipt_ECN.h
@@ -19,11 +19,11 @@
 #define IPT_ECN_OP_MASK		0xce
 
 struct ipt_ECN_info {
-	u_int8_t operation;	/* bitset of operations */
-	u_int8_t ip_ect;	/* ECT codepoint of IPv4 header, pre-shifted */
+	__u8 operation;	/* bitset of operations */
+	__u8 ip_ect;	/* ECT codepoint of IPv4 header, pre-shifted */
 	union {
 		struct {
-			u_int8_t ece:1, cwr:1; /* TCP ECT bits */
+			__u8 ece:1, cwr:1; /* TCP ECT bits */
 		} tcp;
 	} proto;
 };
diff --git a/include/linux/netfilter_ipv4/ipt_SAME.h b/include/linux/netfilter_ipv4/ipt_SAME.h
index 2529660..fa0ebec 100644
--- a/include/linux/netfilter_ipv4/ipt_SAME.h
+++ b/include/linux/netfilter_ipv4/ipt_SAME.h
@@ -7,9 +7,9 @@
 
 struct ipt_same_info {
 	unsigned char info;
-	u_int32_t rangesize;
-	u_int32_t ipnum;
-	u_int32_t *iparray;
+	__u32 rangesize;
+	__u32 ipnum;
+	__u32 *iparray;
 
 	/* hangs off end. */
 	struct nf_nat_range range[IPT_SAME_MAX_RANGE];
diff --git a/include/linux/netfilter_ipv4/ipt_TTL.h b/include/linux/netfilter_ipv4/ipt_TTL.h
index ee6611e..f6250e4 100644
--- a/include/linux/netfilter_ipv4/ipt_TTL.h
+++ b/include/linux/netfilter_ipv4/ipt_TTL.h
@@ -13,8 +13,8 @@ enum {
 #define IPT_TTL_MAXMODE	IPT_TTL_DEC
 
 struct ipt_TTL_info {
-	u_int8_t	mode;
-	u_int8_t	ttl;
+	__u8	mode;
+	__u8	ttl;
 };
 
 
diff --git a/include/linux/netfilter_ipv4/ipt_addrtype.h b/include/linux/netfilter_ipv4/ipt_addrtype.h
index 446de6a..f29c3cf 100644
--- a/include/linux/netfilter_ipv4/ipt_addrtype.h
+++ b/include/linux/netfilter_ipv4/ipt_addrtype.h
@@ -9,17 +9,17 @@ enum {
 };
 
 struct ipt_addrtype_info_v1 {
-	u_int16_t	source;		/* source-type mask */
-	u_int16_t	dest;		/* dest-type mask */
-	u_int32_t	flags;
+	__u16	source;		/* source-type mask */
+	__u16	dest;		/* dest-type mask */
+	__u32	flags;
 };
 
 /* revision 0 */
 struct ipt_addrtype_info {
-	u_int16_t	source;		/* source-type mask */
-	u_int16_t	dest;		/* dest-type mask */
-	u_int32_t	invert_source;
-	u_int32_t	invert_dest;
+	__u16	source;		/* source-type mask */
+	__u16	dest;		/* dest-type mask */
+	__u32	invert_source;
+	__u32	invert_dest;
 };
 
 #endif
diff --git a/include/linux/netfilter_ipv4/ipt_ah.h b/include/linux/netfilter_ipv4/ipt_ah.h
index 2e555b4..8fea283 100644
--- a/include/linux/netfilter_ipv4/ipt_ah.h
+++ b/include/linux/netfilter_ipv4/ipt_ah.h
@@ -2,8 +2,8 @@
 #define _IPT_AH_H
 
 struct ipt_ah {
-	u_int32_t spis[2];			/* Security Parameter Index */
-	u_int8_t  invflags;			/* Inverse flags */
+	__u32 spis[2];			/* Security Parameter Index */
+	__u8  invflags;			/* Inverse flags */
 };
 
 
diff --git a/include/linux/netfilter_ipv4/ipt_ecn.h b/include/linux/netfilter_ipv4/ipt_ecn.h
index 9945baa..78b98aa 100644
--- a/include/linux/netfilter_ipv4/ipt_ecn.h
+++ b/include/linux/netfilter_ipv4/ipt_ecn.h
@@ -20,12 +20,12 @@
 
 /* match info */
 struct ipt_ecn_info {
-	u_int8_t operation;
-	u_int8_t invert;
-	u_int8_t ip_ect;
+	__u8 operation;
+	__u8 invert;
+	__u8 ip_ect;
 	union {
 		struct {
-			u_int8_t ect;
+			__u8 ect;
 		} tcp;
 	} proto;
 };
diff --git a/include/linux/netfilter_ipv4/ipt_ttl.h b/include/linux/netfilter_ipv4/ipt_ttl.h
index ee24fd8..93d9a06 100644
--- a/include/linux/netfilter_ipv4/ipt_ttl.h
+++ b/include/linux/netfilter_ipv4/ipt_ttl.h
@@ -13,8 +13,8 @@ enum {
 
 
 struct ipt_ttl_info {
-	u_int8_t	mode;
-	u_int8_t	ttl;
+	__u8	mode;
+	__u8	ttl;
 };
 
 
diff --git a/include/linux/netfilter_ipv6/ip6t_HL.h b/include/linux/netfilter_ipv6/ip6t_HL.h
index afb7813..81cdaf0 100644
--- a/include/linux/netfilter_ipv6/ip6t_HL.h
+++ b/include/linux/netfilter_ipv6/ip6t_HL.h
@@ -14,8 +14,8 @@ enum {
 #define IP6T_HL_MAXMODE	IP6T_HL_DEC
 
 struct ip6t_HL_info {
-	u_int8_t	mode;
-	u_int8_t	hop_limit;
+	__u8	mode;
+	__u8	hop_limit;
 };
 
 
diff --git a/include/linux/netfilter_ipv6/ip6t_REJECT.h b/include/linux/netfilter_ipv6/ip6t_REJECT.h
index 6be6504..b999aa4 100644
--- a/include/linux/netfilter_ipv6/ip6t_REJECT.h
+++ b/include/linux/netfilter_ipv6/ip6t_REJECT.h
@@ -12,7 +12,7 @@ enum ip6t_reject_with {
 };
 
 struct ip6t_reject_info {
-	u_int32_t	with;	/* reject type */
+	__u32	with;	/* reject type */
 };
 
 #endif /*_IP6T_REJECT_H*/
diff --git a/include/linux/netfilter_ipv6/ip6t_ah.h b/include/linux/netfilter_ipv6/ip6t_ah.h
index 17a745c..a602c16 100644
--- a/include/linux/netfilter_ipv6/ip6t_ah.h
+++ b/include/linux/netfilter_ipv6/ip6t_ah.h
@@ -2,10 +2,10 @@
 #define _IP6T_AH_H
 
 struct ip6t_ah {
-	u_int32_t spis[2];			/* Security Parameter Index */
-	u_int32_t hdrlen;			/* Header Length */
-	u_int8_t  hdrres;			/* Test of the Reserved Filed */
-	u_int8_t  invflags;			/* Inverse flags */
+	__u32 spis[2];			/* Security Parameter Index */
+	__u32 hdrlen;			/* Header Length */
+	__u8  hdrres;			/* Test of the Reserved Filed */
+	__u8  invflags;			/* Inverse flags */
 };
 
 #define IP6T_AH_SPI 0x01
diff --git a/include/linux/netfilter_ipv6/ip6t_frag.h b/include/linux/netfilter_ipv6/ip6t_frag.h
index 3724d08..538b31e 100644
--- a/include/linux/netfilter_ipv6/ip6t_frag.h
+++ b/include/linux/netfilter_ipv6/ip6t_frag.h
@@ -2,10 +2,10 @@
 #define _IP6T_FRAG_H
 
 struct ip6t_frag {
-	u_int32_t ids[2];			/* Security Parameter Index */
-	u_int32_t hdrlen;			/* Header Length */
-	u_int8_t  flags;			/*  */
-	u_int8_t  invflags;			/* Inverse flags */
+	__u32 ids[2];			/* Security Parameter Index */
+	__u32 hdrlen;			/* Header Length */
+	__u8  flags;			/*  */
+	__u8  invflags;			/* Inverse flags */
 };
 
 #define IP6T_FRAG_IDS 		0x01
diff --git a/include/linux/netfilter_ipv6/ip6t_hl.h b/include/linux/netfilter_ipv6/ip6t_hl.h
index 5ef91b8..c6fddcb 100644
--- a/include/linux/netfilter_ipv6/ip6t_hl.h
+++ b/include/linux/netfilter_ipv6/ip6t_hl.h
@@ -14,8 +14,8 @@ enum {
 
 
 struct ip6t_hl_info {
-	u_int8_t	mode;
-	u_int8_t	hop_limit;
+	__u8	mode;
+	__u8	hop_limit;
 };
 
 
diff --git a/include/linux/netfilter_ipv6/ip6t_ipv6header.h b/include/linux/netfilter_ipv6/ip6t_ipv6header.h
index 01dfd44..73d53bd 100644
--- a/include/linux/netfilter_ipv6/ip6t_ipv6header.h
+++ b/include/linux/netfilter_ipv6/ip6t_ipv6header.h
@@ -9,9 +9,9 @@ on whether they contain certain headers */
 #define __IPV6HEADER_H
 
 struct ip6t_ipv6header_info {
-	u_int8_t matchflags;
-	u_int8_t invflags;
-	u_int8_t modeflag;
+	__u8 matchflags;
+	__u8 invflags;
+	__u8 modeflag;
 };
 
 #define MASK_HOPOPTS    128
diff --git a/include/linux/netfilter_ipv6/ip6t_mh.h b/include/linux/netfilter_ipv6/ip6t_mh.h
index 18549bc..98c8cf6 100644
--- a/include/linux/netfilter_ipv6/ip6t_mh.h
+++ b/include/linux/netfilter_ipv6/ip6t_mh.h
@@ -3,8 +3,8 @@
 
 /* MH matching stuff */
 struct ip6t_mh {
-	u_int8_t types[2];	/* MH type range */
-	u_int8_t invflags;	/* Inverse flags */
+	__u8 types[2];	/* MH type range */
+	__u8 invflags;	/* Inverse flags */
 };
 
 /* Values for "invflags" field in struct ip6t_mh. */
diff --git a/include/linux/netfilter_ipv6/ip6t_opts.h b/include/linux/netfilter_ipv6/ip6t_opts.h
index 62d89bc..405d309 100644
--- a/include/linux/netfilter_ipv6/ip6t_opts.h
+++ b/include/linux/netfilter_ipv6/ip6t_opts.h
@@ -4,11 +4,11 @@
 #define IP6T_OPTS_OPTSNR 16
 
 struct ip6t_opts {
-	u_int32_t hdrlen;			/* Header Length */
-	u_int8_t flags;				/*  */
-	u_int8_t invflags;			/* Inverse flags */
-	u_int16_t opts[IP6T_OPTS_OPTSNR];	/* opts */
-	u_int8_t optsnr;			/* Nr of OPts */
+	__u32 hdrlen;			/* Header Length */
+	__u8 flags;				/*  */
+	__u8 invflags;			/* Inverse flags */
+	__u16 opts[IP6T_OPTS_OPTSNR];	/* opts */
+	__u8 optsnr;			/* Nr of OPts */
 };
 
 #define IP6T_OPTS_LEN 		0x01
diff --git a/include/linux/netfilter_ipv6/ip6t_rt.h b/include/linux/netfilter_ipv6/ip6t_rt.h
index ab91bfd..e8dad20 100644
--- a/include/linux/netfilter_ipv6/ip6t_rt.h
+++ b/include/linux/netfilter_ipv6/ip6t_rt.h
@@ -6,13 +6,13 @@
 #define IP6T_RT_HOPS 16
 
 struct ip6t_rt {
-	u_int32_t rt_type;			/* Routing Type */
-	u_int32_t segsleft[2];			/* Segments Left */
-	u_int32_t hdrlen;			/* Header Length */
-	u_int8_t  flags;			/*  */
-	u_int8_t  invflags;			/* Inverse flags */
+	__u32 rt_type;			/* Routing Type */
+	__u32 segsleft[2];			/* Segments Left */
+	__u32 hdrlen;			/* Header Length */
+	__u8  flags;			/*  */
+	__u8  invflags;			/* Inverse flags */
 	struct in6_addr addrs[IP6T_RT_HOPS];	/* Hops */
-	u_int8_t addrnr;			/* Nr of Addresses */
+	__u8 addrnr;			/* Nr of Addresses */
 };
 
 #define IP6T_RT_TYP 		0x01
-- 
1.7.2.3

