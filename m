From: kaber@trash.net
Subject: [PATCH 5/7] netfilter: xtables: add missing header inclusions for headers_check
Date: Thu, 20 Jan 2011 21:22:44 +0100
Message-ID: <1295554966-5263-6-git-send-email-kaber@trash.net>
References: <1295554966-5263-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Jan Engelhardt <jengelh@medozas.de>
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1295554966-5263-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>

Resolve these warnings on `make headers_check`:

usr/include/linux/netfilter/xt_CT.h:7: found __[us]{8,16,32,64} type
without #include <linux/types.h>
...

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 include/linux/netfilter/xt_CT.h                |    2 ++
 include/linux/netfilter/xt_TCPOPTSTRIP.h       |    2 ++
 include/linux/netfilter/xt_TPROXY.h            |    2 ++
 include/linux/netfilter/xt_cluster.h           |    2 ++
 include/linux/netfilter/xt_connlimit.h         |    2 ++
 include/linux/netfilter/xt_quota.h             |    2 ++
 include/linux/netfilter/xt_socket.h            |    2 ++
 include/linux/netfilter/xt_time.h              |    2 ++
 include/linux/netfilter/xt_u32.h               |    2 ++
 include/linux/netfilter_bridge/ebt_802_3.h     |    2 ++
 include/linux/netfilter_bridge/ebt_among.h     |    2 ++
 include/linux/netfilter_bridge/ebt_arp.h       |    2 ++
 include/linux/netfilter_bridge/ebt_ip.h        |    2 ++
 include/linux/netfilter_bridge/ebt_ip6.h       |    2 ++
 include/linux/netfilter_bridge/ebt_limit.h     |    2 ++
 include/linux/netfilter_bridge/ebt_log.h       |    2 ++
 include/linux/netfilter_bridge/ebt_mark_m.h    |    2 ++
 include/linux/netfilter_bridge/ebt_nflog.h     |    2 ++
 include/linux/netfilter_bridge/ebt_pkttype.h   |    2 ++
 include/linux/netfilter_bridge/ebt_stp.h       |    2 ++
 include/linux/netfilter_bridge/ebt_ulog.h      |    2 ++
 include/linux/netfilter_bridge/ebt_vlan.h      |    2 ++
 include/linux/netfilter_ipv4/ipt_CLUSTERIP.h   |    2 ++
 include/linux/netfilter_ipv4/ipt_ECN.h         |    2 ++
 include/linux/netfilter_ipv4/ipt_SAME.h        |    2 ++
 include/linux/netfilter_ipv4/ipt_TTL.h         |    2 ++
 include/linux/netfilter_ipv4/ipt_addrtype.h    |    2 ++
 include/linux/netfilter_ipv4/ipt_ah.h          |    2 ++
 include/linux/netfilter_ipv4/ipt_ecn.h         |    2 ++
 include/linux/netfilter_ipv4/ipt_ttl.h         |    2 ++
 include/linux/netfilter_ipv6/ip6t_HL.h         |    2 ++
 include/linux/netfilter_ipv6/ip6t_REJECT.h     |    2 ++
 include/linux/netfilter_ipv6/ip6t_ah.h         |    2 ++
 include/linux/netfilter_ipv6/ip6t_frag.h       |    2 ++
 include/linux/netfilter_ipv6/ip6t_hl.h         |    2 ++
 include/linux/netfilter_ipv6/ip6t_ipv6header.h |    2 ++
 include/linux/netfilter_ipv6/ip6t_mh.h         |    2 ++
 include/linux/netfilter_ipv6/ip6t_opts.h       |    2 ++
 include/linux/netfilter_ipv6/ip6t_rt.h         |    1 +
 39 files changed, 77 insertions(+), 0 deletions(-)

diff --git a/include/linux/netfilter/xt_CT.h b/include/linux/netfilter/xt_CT.h
index fbf4c56..b56e768 100644
--- a/include/linux/netfilter/xt_CT.h
+++ b/include/linux/netfilter/xt_CT.h
@@ -1,6 +1,8 @@
 #ifndef _XT_CT_H
 #define _XT_CT_H
 
+#include <linux/types.h>
+
 #define XT_CT_NOTRACK	0x1
 
 struct xt_ct_target_info {
diff --git a/include/linux/netfilter/xt_TCPOPTSTRIP.h b/include/linux/netfilter/xt_TCPOPTSTRIP.h
index 342ef14..7157318 100644
--- a/include/linux/netfilter/xt_TCPOPTSTRIP.h
+++ b/include/linux/netfilter/xt_TCPOPTSTRIP.h
@@ -1,6 +1,8 @@
 #ifndef _XT_TCPOPTSTRIP_H
 #define _XT_TCPOPTSTRIP_H
 
+#include <linux/types.h>
+
 #define tcpoptstrip_set_bit(bmap, idx) \
 	(bmap[(idx) >> 5] |= 1U << (idx & 31))
 #define tcpoptstrip_test_bit(bmap, idx) \
diff --git a/include/linux/netfilter/xt_TPROXY.h b/include/linux/netfilter/xt_TPROXY.h
index 8097e0b..902043c 100644
--- a/include/linux/netfilter/xt_TPROXY.h
+++ b/include/linux/netfilter/xt_TPROXY.h
@@ -1,6 +1,8 @@
 #ifndef _XT_TPROXY_H
 #define _XT_TPROXY_H
 
+#include <linux/types.h>
+
 /* TPROXY target is capable of marking the packet to perform
  * redirection. We can get rid of that whenever we get support for
  * mutliple targets in the same rule. */
diff --git a/include/linux/netfilter/xt_cluster.h b/include/linux/netfilter/xt_cluster.h
index 66cfa3c..9b883c8 100644
--- a/include/linux/netfilter/xt_cluster.h
+++ b/include/linux/netfilter/xt_cluster.h
@@ -1,6 +1,8 @@
 #ifndef _XT_CLUSTER_MATCH_H
 #define _XT_CLUSTER_MATCH_H
 
+#include <linux/types.h>
+
 enum xt_cluster_flags {
 	XT_CLUSTER_F_INV	= (1 << 0)
 };
diff --git a/include/linux/netfilter/xt_connlimit.h b/include/linux/netfilter/xt_connlimit.h
index ab1d3b5..0ca66e9 100644
--- a/include/linux/netfilter/xt_connlimit.h
+++ b/include/linux/netfilter/xt_connlimit.h
@@ -1,6 +1,8 @@
 #ifndef _XT_CONNLIMIT_H
 #define _XT_CONNLIMIT_H
 
+#include <linux/types.h>
+
 struct xt_connlimit_data;
 
 enum {
diff --git a/include/linux/netfilter/xt_quota.h b/include/linux/netfilter/xt_quota.h
index 8bda65f..ca6e03e 100644
--- a/include/linux/netfilter/xt_quota.h
+++ b/include/linux/netfilter/xt_quota.h
@@ -1,6 +1,8 @@
 #ifndef _XT_QUOTA_H
 #define _XT_QUOTA_H
 
+#include <linux/types.h>
+
 enum xt_quota_flags {
 	XT_QUOTA_INVERT		= 0x1,
 };
diff --git a/include/linux/netfilter/xt_socket.h b/include/linux/netfilter/xt_socket.h
index 6f475b8..26d7217 100644
--- a/include/linux/netfilter/xt_socket.h
+++ b/include/linux/netfilter/xt_socket.h
@@ -1,6 +1,8 @@
 #ifndef _XT_SOCKET_H
 #define _XT_SOCKET_H
 
+#include <linux/types.h>
+
 enum {
 	XT_SOCKET_TRANSPARENT = 1 << 0,
 };
diff --git a/include/linux/netfilter/xt_time.h b/include/linux/netfilter/xt_time.h
index b8bd456..7c37fac 100644
--- a/include/linux/netfilter/xt_time.h
+++ b/include/linux/netfilter/xt_time.h
@@ -1,6 +1,8 @@
 #ifndef _XT_TIME_H
 #define _XT_TIME_H 1
 
+#include <linux/types.h>
+
 struct xt_time_info {
 	__u32 date_start;
 	__u32 date_stop;
diff --git a/include/linux/netfilter/xt_u32.h b/include/linux/netfilter/xt_u32.h
index e8c3d87..04d1bfe 100644
--- a/include/linux/netfilter/xt_u32.h
+++ b/include/linux/netfilter/xt_u32.h
@@ -1,6 +1,8 @@
 #ifndef _XT_U32_H
 #define _XT_U32_H 1
 
+#include <linux/types.h>
+
 enum xt_u32_ops {
 	XT_U32_AND,
 	XT_U32_LEFTSH,
diff --git a/include/linux/netfilter_bridge/ebt_802_3.h b/include/linux/netfilter_bridge/ebt_802_3.h
index c427764..be5be15 100644
--- a/include/linux/netfilter_bridge/ebt_802_3.h
+++ b/include/linux/netfilter_bridge/ebt_802_3.h
@@ -1,6 +1,8 @@
 #ifndef __LINUX_BRIDGE_EBT_802_3_H
 #define __LINUX_BRIDGE_EBT_802_3_H
 
+#include <linux/types.h>
+
 #define EBT_802_3_SAP 0x01
 #define EBT_802_3_TYPE 0x02
 
diff --git a/include/linux/netfilter_bridge/ebt_among.h b/include/linux/netfilter_bridge/ebt_among.h
index 686c961..bd4e3ad 100644
--- a/include/linux/netfilter_bridge/ebt_among.h
+++ b/include/linux/netfilter_bridge/ebt_among.h
@@ -1,6 +1,8 @@
 #ifndef __LINUX_BRIDGE_EBT_AMONG_H
 #define __LINUX_BRIDGE_EBT_AMONG_H
 
+#include <linux/types.h>
+
 #define EBT_AMONG_DST 0x01
 #define EBT_AMONG_SRC 0x02
 
diff --git a/include/linux/netfilter_bridge/ebt_arp.h b/include/linux/netfilter_bridge/ebt_arp.h
index e62b5af..522f3e4 100644
--- a/include/linux/netfilter_bridge/ebt_arp.h
+++ b/include/linux/netfilter_bridge/ebt_arp.h
@@ -1,6 +1,8 @@
 #ifndef __LINUX_BRIDGE_EBT_ARP_H
 #define __LINUX_BRIDGE_EBT_ARP_H
 
+#include <linux/types.h>
+
 #define EBT_ARP_OPCODE 0x01
 #define EBT_ARP_HTYPE 0x02
 #define EBT_ARP_PTYPE 0x04
diff --git a/include/linux/netfilter_bridge/ebt_ip.h b/include/linux/netfilter_bridge/ebt_ip.h
index d99de58..c4bbc41 100644
--- a/include/linux/netfilter_bridge/ebt_ip.h
+++ b/include/linux/netfilter_bridge/ebt_ip.h
@@ -15,6 +15,8 @@
 #ifndef __LINUX_BRIDGE_EBT_IP_H
 #define __LINUX_BRIDGE_EBT_IP_H
 
+#include <linux/types.h>
+
 #define EBT_IP_SOURCE 0x01
 #define EBT_IP_DEST 0x02
 #define EBT_IP_TOS 0x04
diff --git a/include/linux/netfilter_bridge/ebt_ip6.h b/include/linux/netfilter_bridge/ebt_ip6.h
index 998e9d5..42b8896 100644
--- a/include/linux/netfilter_bridge/ebt_ip6.h
+++ b/include/linux/netfilter_bridge/ebt_ip6.h
@@ -12,6 +12,8 @@
 #ifndef __LINUX_BRIDGE_EBT_IP6_H
 #define __LINUX_BRIDGE_EBT_IP6_H
 
+#include <linux/types.h>
+
 #define EBT_IP6_SOURCE 0x01
 #define EBT_IP6_DEST 0x02
 #define EBT_IP6_TCLASS 0x04
diff --git a/include/linux/netfilter_bridge/ebt_limit.h b/include/linux/netfilter_bridge/ebt_limit.h
index 721d51f..66d80b3 100644
--- a/include/linux/netfilter_bridge/ebt_limit.h
+++ b/include/linux/netfilter_bridge/ebt_limit.h
@@ -1,6 +1,8 @@
 #ifndef __LINUX_BRIDGE_EBT_LIMIT_H
 #define __LINUX_BRIDGE_EBT_LIMIT_H
 
+#include <linux/types.h>
+
 #define EBT_LIMIT_MATCH "limit"
 
 /* timings are in milliseconds. */
diff --git a/include/linux/netfilter_bridge/ebt_log.h b/include/linux/netfilter_bridge/ebt_log.h
index 564beb4..7e7f1d1 100644
--- a/include/linux/netfilter_bridge/ebt_log.h
+++ b/include/linux/netfilter_bridge/ebt_log.h
@@ -1,6 +1,8 @@
 #ifndef __LINUX_BRIDGE_EBT_LOG_H
 #define __LINUX_BRIDGE_EBT_LOG_H
 
+#include <linux/types.h>
+
 #define EBT_LOG_IP 0x01 /* if the frame is made by ip, log the ip information */
 #define EBT_LOG_ARP 0x02
 #define EBT_LOG_NFLOG 0x04
diff --git a/include/linux/netfilter_bridge/ebt_mark_m.h b/include/linux/netfilter_bridge/ebt_mark_m.h
index 97b96c4..410f9e5 100644
--- a/include/linux/netfilter_bridge/ebt_mark_m.h
+++ b/include/linux/netfilter_bridge/ebt_mark_m.h
@@ -1,6 +1,8 @@
 #ifndef __LINUX_BRIDGE_EBT_MARK_M_H
 #define __LINUX_BRIDGE_EBT_MARK_M_H
 
+#include <linux/types.h>
+
 #define EBT_MARK_AND 0x01
 #define EBT_MARK_OR 0x02
 #define EBT_MARK_MASK (EBT_MARK_AND | EBT_MARK_OR)
diff --git a/include/linux/netfilter_bridge/ebt_nflog.h b/include/linux/netfilter_bridge/ebt_nflog.h
index 477315b..df829fc 100644
--- a/include/linux/netfilter_bridge/ebt_nflog.h
+++ b/include/linux/netfilter_bridge/ebt_nflog.h
@@ -1,6 +1,8 @@
 #ifndef __LINUX_BRIDGE_EBT_NFLOG_H
 #define __LINUX_BRIDGE_EBT_NFLOG_H
 
+#include <linux/types.h>
+
 #define EBT_NFLOG_MASK 0x0
 
 #define EBT_NFLOG_PREFIX_SIZE 64
diff --git a/include/linux/netfilter_bridge/ebt_pkttype.h b/include/linux/netfilter_bridge/ebt_pkttype.h
index 7c0fb0f..c241bad 100644
--- a/include/linux/netfilter_bridge/ebt_pkttype.h
+++ b/include/linux/netfilter_bridge/ebt_pkttype.h
@@ -1,6 +1,8 @@
 #ifndef __LINUX_BRIDGE_EBT_PKTTYPE_H
 #define __LINUX_BRIDGE_EBT_PKTTYPE_H
 
+#include <linux/types.h>
+
 struct ebt_pkttype_info {
 	__u8 pkt_type;
 	__u8 invert;
diff --git a/include/linux/netfilter_bridge/ebt_stp.h b/include/linux/netfilter_bridge/ebt_stp.h
index 13a0bd4..1025b9f 100644
--- a/include/linux/netfilter_bridge/ebt_stp.h
+++ b/include/linux/netfilter_bridge/ebt_stp.h
@@ -1,6 +1,8 @@
 #ifndef __LINUX_BRIDGE_EBT_STP_H
 #define __LINUX_BRIDGE_EBT_STP_H
 
+#include <linux/types.h>
+
 #define EBT_STP_TYPE		0x0001
 
 #define EBT_STP_FLAGS		0x0002
diff --git a/include/linux/netfilter_bridge/ebt_ulog.h b/include/linux/netfilter_bridge/ebt_ulog.h
index de35a51..89a6bec 100644
--- a/include/linux/netfilter_bridge/ebt_ulog.h
+++ b/include/linux/netfilter_bridge/ebt_ulog.h
@@ -1,6 +1,8 @@
 #ifndef _EBT_ULOG_H
 #define _EBT_ULOG_H
 
+#include <linux/types.h>
+
 #define EBT_ULOG_DEFAULT_NLGROUP 0
 #define EBT_ULOG_DEFAULT_QTHRESHOLD 1
 #define EBT_ULOG_MAXNLGROUPS 32 /* hardcoded netlink max */
diff --git a/include/linux/netfilter_bridge/ebt_vlan.h b/include/linux/netfilter_bridge/ebt_vlan.h
index 48dffc1..967d1d5 100644
--- a/include/linux/netfilter_bridge/ebt_vlan.h
+++ b/include/linux/netfilter_bridge/ebt_vlan.h
@@ -1,6 +1,8 @@
 #ifndef __LINUX_BRIDGE_EBT_VLAN_H
 #define __LINUX_BRIDGE_EBT_VLAN_H
 
+#include <linux/types.h>
+
 #define EBT_VLAN_ID	0x01
 #define EBT_VLAN_PRIO	0x02
 #define EBT_VLAN_ENCAP	0x04
diff --git a/include/linux/netfilter_ipv4/ipt_CLUSTERIP.h b/include/linux/netfilter_ipv4/ipt_CLUSTERIP.h
index 3114f06..c6a204c 100644
--- a/include/linux/netfilter_ipv4/ipt_CLUSTERIP.h
+++ b/include/linux/netfilter_ipv4/ipt_CLUSTERIP.h
@@ -1,6 +1,8 @@
 #ifndef _IPT_CLUSTERIP_H_target
 #define _IPT_CLUSTERIP_H_target
 
+#include <linux/types.h>
+
 enum clusterip_hashmode {
     CLUSTERIP_HASHMODE_SIP = 0,
     CLUSTERIP_HASHMODE_SIP_SPT,
diff --git a/include/linux/netfilter_ipv4/ipt_ECN.h b/include/linux/netfilter_ipv4/ipt_ECN.h
index c6e3e01..bb88d53 100644
--- a/include/linux/netfilter_ipv4/ipt_ECN.h
+++ b/include/linux/netfilter_ipv4/ipt_ECN.h
@@ -8,6 +8,8 @@
 */
 #ifndef _IPT_ECN_TARGET_H
 #define _IPT_ECN_TARGET_H
+
+#include <linux/types.h>
 #include <linux/netfilter/xt_DSCP.h>
 
 #define IPT_ECN_IP_MASK	(~XT_DSCP_MASK)
diff --git a/include/linux/netfilter_ipv4/ipt_SAME.h b/include/linux/netfilter_ipv4/ipt_SAME.h
index fa0ebec..5bca782 100644
--- a/include/linux/netfilter_ipv4/ipt_SAME.h
+++ b/include/linux/netfilter_ipv4/ipt_SAME.h
@@ -1,6 +1,8 @@
 #ifndef _IPT_SAME_H
 #define _IPT_SAME_H
 
+#include <linux/types.h>
+
 #define IPT_SAME_MAX_RANGE	10
 
 #define IPT_SAME_NODST		0x01
diff --git a/include/linux/netfilter_ipv4/ipt_TTL.h b/include/linux/netfilter_ipv4/ipt_TTL.h
index f6250e4..f6ac169 100644
--- a/include/linux/netfilter_ipv4/ipt_TTL.h
+++ b/include/linux/netfilter_ipv4/ipt_TTL.h
@@ -4,6 +4,8 @@
 #ifndef _IPT_TTL_H
 #define _IPT_TTL_H
 
+#include <linux/types.h>
+
 enum {
 	IPT_TTL_SET = 0,
 	IPT_TTL_INC,
diff --git a/include/linux/netfilter_ipv4/ipt_addrtype.h b/include/linux/netfilter_ipv4/ipt_addrtype.h
index f29c3cf..0da4223 100644
--- a/include/linux/netfilter_ipv4/ipt_addrtype.h
+++ b/include/linux/netfilter_ipv4/ipt_addrtype.h
@@ -1,6 +1,8 @@
 #ifndef _IPT_ADDRTYPE_H
 #define _IPT_ADDRTYPE_H
 
+#include <linux/types.h>
+
 enum {
 	IPT_ADDRTYPE_INVERT_SOURCE	= 0x0001,
 	IPT_ADDRTYPE_INVERT_DEST	= 0x0002,
diff --git a/include/linux/netfilter_ipv4/ipt_ah.h b/include/linux/netfilter_ipv4/ipt_ah.h
index 8fea283..4e02bb0 100644
--- a/include/linux/netfilter_ipv4/ipt_ah.h
+++ b/include/linux/netfilter_ipv4/ipt_ah.h
@@ -1,6 +1,8 @@
 #ifndef _IPT_AH_H
 #define _IPT_AH_H
 
+#include <linux/types.h>
+
 struct ipt_ah {
 	__u32 spis[2];			/* Security Parameter Index */
 	__u8  invflags;			/* Inverse flags */
diff --git a/include/linux/netfilter_ipv4/ipt_ecn.h b/include/linux/netfilter_ipv4/ipt_ecn.h
index 78b98aa..eabf95f 100644
--- a/include/linux/netfilter_ipv4/ipt_ecn.h
+++ b/include/linux/netfilter_ipv4/ipt_ecn.h
@@ -8,6 +8,8 @@
 */
 #ifndef _IPT_ECN_H
 #define _IPT_ECN_H
+
+#include <linux/types.h>
 #include <linux/netfilter/xt_dscp.h>
 
 #define IPT_ECN_IP_MASK	(~XT_DSCP_MASK)
diff --git a/include/linux/netfilter_ipv4/ipt_ttl.h b/include/linux/netfilter_ipv4/ipt_ttl.h
index 93d9a06..37bee44 100644
--- a/include/linux/netfilter_ipv4/ipt_ttl.h
+++ b/include/linux/netfilter_ipv4/ipt_ttl.h
@@ -4,6 +4,8 @@
 #ifndef _IPT_TTL_H
 #define _IPT_TTL_H
 
+#include <linux/types.h>
+
 enum {
 	IPT_TTL_EQ = 0,		/* equals */
 	IPT_TTL_NE,		/* not equals */
diff --git a/include/linux/netfilter_ipv6/ip6t_HL.h b/include/linux/netfilter_ipv6/ip6t_HL.h
index 81cdaf0..ebd8ead 100644
--- a/include/linux/netfilter_ipv6/ip6t_HL.h
+++ b/include/linux/netfilter_ipv6/ip6t_HL.h
@@ -5,6 +5,8 @@
 #ifndef _IP6T_HL_H
 #define _IP6T_HL_H
 
+#include <linux/types.h>
+
 enum {
 	IP6T_HL_SET = 0,
 	IP6T_HL_INC,
diff --git a/include/linux/netfilter_ipv6/ip6t_REJECT.h b/include/linux/netfilter_ipv6/ip6t_REJECT.h
index b999aa4..205ed62 100644
--- a/include/linux/netfilter_ipv6/ip6t_REJECT.h
+++ b/include/linux/netfilter_ipv6/ip6t_REJECT.h
@@ -1,6 +1,8 @@
 #ifndef _IP6T_REJECT_H
 #define _IP6T_REJECT_H
 
+#include <linux/types.h>
+
 enum ip6t_reject_with {
 	IP6T_ICMP6_NO_ROUTE,
 	IP6T_ICMP6_ADM_PROHIBITED,
diff --git a/include/linux/netfilter_ipv6/ip6t_ah.h b/include/linux/netfilter_ipv6/ip6t_ah.h
index a602c16..5da2b65 100644
--- a/include/linux/netfilter_ipv6/ip6t_ah.h
+++ b/include/linux/netfilter_ipv6/ip6t_ah.h
@@ -1,6 +1,8 @@
 #ifndef _IP6T_AH_H
 #define _IP6T_AH_H
 
+#include <linux/types.h>
+
 struct ip6t_ah {
 	__u32 spis[2];			/* Security Parameter Index */
 	__u32 hdrlen;			/* Header Length */
diff --git a/include/linux/netfilter_ipv6/ip6t_frag.h b/include/linux/netfilter_ipv6/ip6t_frag.h
index 538b31e..b47f61b 100644
--- a/include/linux/netfilter_ipv6/ip6t_frag.h
+++ b/include/linux/netfilter_ipv6/ip6t_frag.h
@@ -1,6 +1,8 @@
 #ifndef _IP6T_FRAG_H
 #define _IP6T_FRAG_H
 
+#include <linux/types.h>
+
 struct ip6t_frag {
 	__u32 ids[2];			/* Security Parameter Index */
 	__u32 hdrlen;			/* Header Length */
diff --git a/include/linux/netfilter_ipv6/ip6t_hl.h b/include/linux/netfilter_ipv6/ip6t_hl.h
index c6fddcb..6e76dbc 100644
--- a/include/linux/netfilter_ipv6/ip6t_hl.h
+++ b/include/linux/netfilter_ipv6/ip6t_hl.h
@@ -5,6 +5,8 @@
 #ifndef _IP6T_HL_H
 #define _IP6T_HL_H
 
+#include <linux/types.h>
+
 enum {
 	IP6T_HL_EQ = 0,		/* equals */
 	IP6T_HL_NE,		/* not equals */
diff --git a/include/linux/netfilter_ipv6/ip6t_ipv6header.h b/include/linux/netfilter_ipv6/ip6t_ipv6header.h
index 73d53bd..efae3a2 100644
--- a/include/linux/netfilter_ipv6/ip6t_ipv6header.h
+++ b/include/linux/netfilter_ipv6/ip6t_ipv6header.h
@@ -8,6 +8,8 @@ on whether they contain certain headers */
 #ifndef __IPV6HEADER_H
 #define __IPV6HEADER_H
 
+#include <linux/types.h>
+
 struct ip6t_ipv6header_info {
 	__u8 matchflags;
 	__u8 invflags;
diff --git a/include/linux/netfilter_ipv6/ip6t_mh.h b/include/linux/netfilter_ipv6/ip6t_mh.h
index 98c8cf6..a7729a5 100644
--- a/include/linux/netfilter_ipv6/ip6t_mh.h
+++ b/include/linux/netfilter_ipv6/ip6t_mh.h
@@ -1,6 +1,8 @@
 #ifndef _IP6T_MH_H
 #define _IP6T_MH_H
 
+#include <linux/types.h>
+
 /* MH matching stuff */
 struct ip6t_mh {
 	__u8 types[2];	/* MH type range */
diff --git a/include/linux/netfilter_ipv6/ip6t_opts.h b/include/linux/netfilter_ipv6/ip6t_opts.h
index 405d309..17d419a 100644
--- a/include/linux/netfilter_ipv6/ip6t_opts.h
+++ b/include/linux/netfilter_ipv6/ip6t_opts.h
@@ -1,6 +1,8 @@
 #ifndef _IP6T_OPTS_H
 #define _IP6T_OPTS_H
 
+#include <linux/types.h>
+
 #define IP6T_OPTS_OPTSNR 16
 
 struct ip6t_opts {
diff --git a/include/linux/netfilter_ipv6/ip6t_rt.h b/include/linux/netfilter_ipv6/ip6t_rt.h
index e8dad20..7605a5f 100644
--- a/include/linux/netfilter_ipv6/ip6t_rt.h
+++ b/include/linux/netfilter_ipv6/ip6t_rt.h
@@ -1,6 +1,7 @@
 #ifndef _IP6T_RT_H
 #define _IP6T_RT_H
 
+#include <linux/types.h>
 /*#include <linux/in6.h>*/
 
 #define IP6T_RT_HOPS 16
-- 
1.7.3.4

