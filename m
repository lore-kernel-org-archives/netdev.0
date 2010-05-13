From: kaber@trash.net
Subject: [PATCH 05/12] netfilter: xtables: substitute temporary defines by final name
Date: Thu, 13 May 2010 18:16:18 +0200
Message-ID: <1273767385-18225-6-git-send-email-kaber@trash.net>
References: <1273767385-18225-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273767385-18225-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 include/linux/netfilter/x_tables.h   |    2 --
 net/bridge/netfilter/ebt_802_3.c     |    2 +-
 net/bridge/netfilter/ebt_among.c     |    2 +-
 net/bridge/netfilter/ebt_arp.c       |    2 +-
 net/bridge/netfilter/ebt_arpreply.c  |    2 +-
 net/bridge/netfilter/ebt_dnat.c      |    2 +-
 net/bridge/netfilter/ebt_ip.c        |    2 +-
 net/bridge/netfilter/ebt_ip6.c       |    2 +-
 net/bridge/netfilter/ebt_limit.c     |    2 +-
 net/bridge/netfilter/ebt_log.c       |    2 +-
 net/bridge/netfilter/ebt_mark.c      |    2 +-
 net/bridge/netfilter/ebt_mark_m.c    |    2 +-
 net/bridge/netfilter/ebt_nflog.c     |    2 +-
 net/bridge/netfilter/ebt_pkttype.c   |    2 +-
 net/bridge/netfilter/ebt_redirect.c  |    2 +-
 net/bridge/netfilter/ebt_snat.c      |    2 +-
 net/bridge/netfilter/ebt_stp.c       |    2 +-
 net/bridge/netfilter/ebt_ulog.c      |    2 +-
 net/bridge/netfilter/ebt_vlan.c      |    2 +-
 net/ipv4/netfilter/arp_tables.c      |    2 +-
 net/ipv4/netfilter/arpt_mangle.c     |    2 +-
 net/ipv4/netfilter/ip_tables.c       |    4 ++--
 net/ipv4/netfilter/ipt_CLUSTERIP.c   |    2 +-
 net/ipv4/netfilter/ipt_ECN.c         |    2 +-
 net/ipv4/netfilter/ipt_LOG.c         |    2 +-
 net/ipv4/netfilter/ipt_MASQUERADE.c  |    2 +-
 net/ipv4/netfilter/ipt_NETMAP.c      |    2 +-
 net/ipv4/netfilter/ipt_REDIRECT.c    |    2 +-
 net/ipv4/netfilter/ipt_REJECT.c      |    2 +-
 net/ipv4/netfilter/ipt_ULOG.c        |    2 +-
 net/ipv4/netfilter/ipt_addrtype.c    |    4 ++--
 net/ipv4/netfilter/ipt_ah.c          |    2 +-
 net/ipv4/netfilter/ipt_ecn.c         |    3 ++-
 net/ipv4/netfilter/nf_nat_rule.c     |    4 ++--
 net/ipv6/netfilter/ip6_tables.c      |    4 ++--
 net/ipv6/netfilter/ip6t_LOG.c        |    2 +-
 net/ipv6/netfilter/ip6t_REJECT.c     |    2 +-
 net/ipv6/netfilter/ip6t_ah.c         |    3 ++-
 net/ipv6/netfilter/ip6t_eui64.c      |    2 +-
 net/ipv6/netfilter/ip6t_frag.c       |    2 +-
 net/ipv6/netfilter/ip6t_hbh.c        |    2 +-
 net/ipv6/netfilter/ip6t_ipv6header.c |    2 +-
 net/ipv6/netfilter/ip6t_mh.c         |    3 ++-
 net/ipv6/netfilter/ip6t_rt.c         |    3 ++-
 net/netfilter/xt_CLASSIFY.c          |    2 +-
 net/netfilter/xt_CONNSECMARK.c       |    2 +-
 net/netfilter/xt_CT.c                |    2 +-
 net/netfilter/xt_DSCP.c              |    8 ++++----
 net/netfilter/xt_HL.c                |    4 ++--
 net/netfilter/xt_LED.c               |    2 +-
 net/netfilter/xt_NFLOG.c             |    2 +-
 net/netfilter/xt_NFQUEUE.c           |    4 ++--
 net/netfilter/xt_NOTRACK.c           |    2 +-
 net/netfilter/xt_RATEEST.c           |    2 +-
 net/netfilter/xt_SECMARK.c           |    2 +-
 net/netfilter/xt_TCPMSS.c            |    4 ++--
 net/netfilter/xt_TCPOPTSTRIP.c       |    4 ++--
 net/netfilter/xt_TEE.c               |    4 ++--
 net/netfilter/xt_TPROXY.c            |    2 +-
 net/netfilter/xt_TRACE.c             |    2 +-
 net/netfilter/xt_cluster.c           |    2 +-
 net/netfilter/xt_comment.c           |    2 +-
 net/netfilter/xt_connbytes.c         |    2 +-
 net/netfilter/xt_connlimit.c         |    2 +-
 net/netfilter/xt_connmark.c          |    4 ++--
 net/netfilter/xt_conntrack.c         |    6 +++---
 net/netfilter/xt_dccp.c              |    2 +-
 net/netfilter/xt_dscp.c              |    7 ++++---
 net/netfilter/xt_esp.c               |    3 ++-
 net/netfilter/xt_hashlimit.c         |    2 +-
 net/netfilter/xt_helper.c            |    2 +-
 net/netfilter/xt_hl.c                |    6 ++++--
 net/netfilter/xt_iprange.c           |    4 ++--
 net/netfilter/xt_length.c            |    4 ++--
 net/netfilter/xt_limit.c             |    2 +-
 net/netfilter/xt_mac.c               |    3 ++-
 net/netfilter/xt_mark.c              |    4 ++--
 net/netfilter/xt_multiport.c         |    2 +-
 net/netfilter/xt_osf.c               |    4 ++--
 net/netfilter/xt_owner.c             |    2 +-
 net/netfilter/xt_physdev.c           |    2 +-
 net/netfilter/xt_pkttype.c           |    2 +-
 net/netfilter/xt_policy.c            |    2 +-
 net/netfilter/xt_quota.c             |    2 +-
 net/netfilter/xt_rateest.c           |    2 +-
 net/netfilter/xt_realm.c             |    2 +-
 net/netfilter/xt_recent.c            |    2 +-
 net/netfilter/xt_sctp.c              |    2 +-
 net/netfilter/xt_socket.c            |    6 +++---
 net/netfilter/xt_state.c             |    2 +-
 net/netfilter/xt_statistic.c         |    2 +-
 net/netfilter/xt_string.c            |    2 +-
 net/netfilter/xt_tcpmss.c            |    2 +-
 net/netfilter/xt_tcpudp.c            |    6 ++++--
 net/netfilter/xt_time.c              |    2 +-
 net/netfilter/xt_u32.c               |    3 ++-
 net/sched/act_ipt.c                  |    2 +-
 97 files changed, 133 insertions(+), 123 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 5efa375..6d1f9a6 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -182,8 +182,6 @@ struct xt_counters_info {
 
 #include <linux/netdevice.h>
 
-#define xt_match_param xt_action_param
-#define xt_target_param xt_action_param
 /**
  * struct xt_action_param - parameters for matches/targets
  *
diff --git a/net/bridge/netfilter/ebt_802_3.c b/net/bridge/netfilter/ebt_802_3.c
index f7de8db..4b0df00 100644
--- a/net/bridge/netfilter/ebt_802_3.c
+++ b/net/bridge/netfilter/ebt_802_3.c
@@ -13,7 +13,7 @@
 #include <linux/netfilter_bridge/ebt_802_3.h>
 
 static bool
-ebt_802_3_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+ebt_802_3_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct ebt_802_3_info *info = par->matchinfo;
 	const struct ebt_802_3_hdr *hdr = ebt_802_3_hdr(skb);
diff --git a/net/bridge/netfilter/ebt_among.c b/net/bridge/netfilter/ebt_among.c
index 20068e0..c04f946 100644
--- a/net/bridge/netfilter/ebt_among.c
+++ b/net/bridge/netfilter/ebt_among.c
@@ -129,7 +129,7 @@ static int get_ip_src(const struct sk_buff *skb, __be32 *addr)
 }
 
 static bool
-ebt_among_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+ebt_among_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct ebt_among_info *info = par->matchinfo;
 	const char *dmac, *smac;
diff --git a/net/bridge/netfilter/ebt_arp.c b/net/bridge/netfilter/ebt_arp.c
index 952150c..6203f4d 100644
--- a/net/bridge/netfilter/ebt_arp.c
+++ b/net/bridge/netfilter/ebt_arp.c
@@ -16,7 +16,7 @@
 #include <linux/netfilter_bridge/ebt_arp.h>
 
 static bool
-ebt_arp_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+ebt_arp_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct ebt_arp_info *info = par->matchinfo;
 	const struct arphdr *ah;
diff --git a/net/bridge/netfilter/ebt_arpreply.c b/net/bridge/netfilter/ebt_arpreply.c
index 4581adb..070cf13 100644
--- a/net/bridge/netfilter/ebt_arpreply.c
+++ b/net/bridge/netfilter/ebt_arpreply.c
@@ -16,7 +16,7 @@
 #include <linux/netfilter_bridge/ebt_arpreply.h>
 
 static unsigned int
-ebt_arpreply_tg(struct sk_buff *skb, const struct xt_target_param *par)
+ebt_arpreply_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct ebt_arpreply_info *info = par->targinfo;
 	const __be32 *siptr, *diptr;
diff --git a/net/bridge/netfilter/ebt_dnat.c b/net/bridge/netfilter/ebt_dnat.c
index 59d5b7c..c59f7bf 100644
--- a/net/bridge/netfilter/ebt_dnat.c
+++ b/net/bridge/netfilter/ebt_dnat.c
@@ -15,7 +15,7 @@
 #include <linux/netfilter_bridge/ebt_nat.h>
 
 static unsigned int
-ebt_dnat_tg(struct sk_buff *skb, const struct xt_target_param *par)
+ebt_dnat_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct ebt_nat_info *info = par->targinfo;
 
diff --git a/net/bridge/netfilter/ebt_ip.c b/net/bridge/netfilter/ebt_ip.c
index a1c76c7..a0cde74 100644
--- a/net/bridge/netfilter/ebt_ip.c
+++ b/net/bridge/netfilter/ebt_ip.c
@@ -25,7 +25,7 @@ struct tcpudphdr {
 };
 
 static bool
-ebt_ip_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+ebt_ip_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct ebt_ip_info *info = par->matchinfo;
 	const struct iphdr *ih;
diff --git a/net/bridge/netfilter/ebt_ip6.c b/net/bridge/netfilter/ebt_ip6.c
index 33f8413..c451dc2 100644
--- a/net/bridge/netfilter/ebt_ip6.c
+++ b/net/bridge/netfilter/ebt_ip6.c
@@ -28,7 +28,7 @@ struct tcpudphdr {
 };
 
 static bool
-ebt_ip6_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+ebt_ip6_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct ebt_ip6_info *info = par->matchinfo;
 	const struct ipv6hdr *ih6;
diff --git a/net/bridge/netfilter/ebt_limit.c b/net/bridge/netfilter/ebt_limit.c
index 4b0e2e5..760923f 100644
--- a/net/bridge/netfilter/ebt_limit.c
+++ b/net/bridge/netfilter/ebt_limit.c
@@ -32,7 +32,7 @@ static DEFINE_SPINLOCK(limit_lock);
 #define CREDITS_PER_JIFFY POW2_BELOW32(MAX_CPJ)
 
 static bool
-ebt_limit_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+ebt_limit_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	struct ebt_limit_info *info = (void *)par->matchinfo;
 	unsigned long now = jiffies;
diff --git a/net/bridge/netfilter/ebt_log.c b/net/bridge/netfilter/ebt_log.c
index c460241..6e5a8bb 100644
--- a/net/bridge/netfilter/ebt_log.c
+++ b/net/bridge/netfilter/ebt_log.c
@@ -171,7 +171,7 @@ out:
 }
 
 static unsigned int
-ebt_log_tg(struct sk_buff *skb, const struct xt_target_param *par)
+ebt_log_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct ebt_log_info *info = par->targinfo;
 	struct nf_loginfo li;
diff --git a/net/bridge/netfilter/ebt_mark.c b/net/bridge/netfilter/ebt_mark.c
index 126e536..66697cb 100644
--- a/net/bridge/netfilter/ebt_mark.c
+++ b/net/bridge/netfilter/ebt_mark.c
@@ -19,7 +19,7 @@
 #include <linux/netfilter_bridge/ebt_mark_t.h>
 
 static unsigned int
-ebt_mark_tg(struct sk_buff *skb, const struct xt_target_param *par)
+ebt_mark_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct ebt_mark_t_info *info = par->targinfo;
 	int action = info->target & -16;
diff --git a/net/bridge/netfilter/ebt_mark_m.c b/net/bridge/netfilter/ebt_mark_m.c
index e4366c0..de90163 100644
--- a/net/bridge/netfilter/ebt_mark_m.c
+++ b/net/bridge/netfilter/ebt_mark_m.c
@@ -13,7 +13,7 @@
 #include <linux/netfilter_bridge/ebt_mark_m.h>
 
 static bool
-ebt_mark_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+ebt_mark_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct ebt_mark_m_info *info = par->matchinfo;
 
diff --git a/net/bridge/netfilter/ebt_nflog.c b/net/bridge/netfilter/ebt_nflog.c
index 22e2ad5..5be68bb 100644
--- a/net/bridge/netfilter/ebt_nflog.c
+++ b/net/bridge/netfilter/ebt_nflog.c
@@ -20,7 +20,7 @@
 #include <net/netfilter/nf_log.h>
 
 static unsigned int
-ebt_nflog_tg(struct sk_buff *skb, const struct xt_target_param *par)
+ebt_nflog_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct ebt_nflog_info *info = par->targinfo;
 	struct nf_loginfo li;
diff --git a/net/bridge/netfilter/ebt_pkttype.c b/net/bridge/netfilter/ebt_pkttype.c
index f34bcc3..7ba67c4 100644
--- a/net/bridge/netfilter/ebt_pkttype.c
+++ b/net/bridge/netfilter/ebt_pkttype.c
@@ -13,7 +13,7 @@
 #include <linux/netfilter_bridge/ebt_pkttype.h>
 
 static bool
-ebt_pkttype_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+ebt_pkttype_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct ebt_pkttype_info *info = par->matchinfo;
 
diff --git a/net/bridge/netfilter/ebt_redirect.c b/net/bridge/netfilter/ebt_redirect.c
index a6044a6..9e19166 100644
--- a/net/bridge/netfilter/ebt_redirect.c
+++ b/net/bridge/netfilter/ebt_redirect.c
@@ -16,7 +16,7 @@
 #include <linux/netfilter_bridge/ebt_redirect.h>
 
 static unsigned int
-ebt_redirect_tg(struct sk_buff *skb, const struct xt_target_param *par)
+ebt_redirect_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct ebt_redirect_info *info = par->targinfo;
 
diff --git a/net/bridge/netfilter/ebt_snat.c b/net/bridge/netfilter/ebt_snat.c
index 79caca3..f8f0bd1 100644
--- a/net/bridge/netfilter/ebt_snat.c
+++ b/net/bridge/netfilter/ebt_snat.c
@@ -17,7 +17,7 @@
 #include <linux/netfilter_bridge/ebt_nat.h>
 
 static unsigned int
-ebt_snat_tg(struct sk_buff *skb, const struct xt_target_param *par)
+ebt_snat_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct ebt_nat_info *info = par->targinfo;
 
diff --git a/net/bridge/netfilter/ebt_stp.c b/net/bridge/netfilter/ebt_stp.c
index 02f28fd..3cd6070 100644
--- a/net/bridge/netfilter/ebt_stp.c
+++ b/net/bridge/netfilter/ebt_stp.c
@@ -120,7 +120,7 @@ static bool ebt_filter_config(const struct ebt_stp_info *info,
 }
 
 static bool
-ebt_stp_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+ebt_stp_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct ebt_stp_info *info = par->matchinfo;
 	const struct stp_header *sp;
diff --git a/net/bridge/netfilter/ebt_ulog.c b/net/bridge/netfilter/ebt_ulog.c
index 852f37c..ae3c7ce 100644
--- a/net/bridge/netfilter/ebt_ulog.c
+++ b/net/bridge/netfilter/ebt_ulog.c
@@ -243,7 +243,7 @@ static void ebt_log_packet(u_int8_t pf, unsigned int hooknum,
 }
 
 static unsigned int
-ebt_ulog_tg(struct sk_buff *skb, const struct xt_target_param *par)
+ebt_ulog_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	ebt_ulog_packet(par->hooknum, skb, par->in, par->out,
 	                par->targinfo, NULL);
diff --git a/net/bridge/netfilter/ebt_vlan.c b/net/bridge/netfilter/ebt_vlan.c
index bf8ae5c..e4ab625 100644
--- a/net/bridge/netfilter/ebt_vlan.c
+++ b/net/bridge/netfilter/ebt_vlan.c
@@ -36,7 +36,7 @@ MODULE_LICENSE("GPL");
 #define EXIT_ON_MISMATCH(_MATCH_,_MASK_) {if (!((info->_MATCH_ == _MATCH_)^!!(info->invflags & _MASK_))) return false; }
 
 static bool
-ebt_vlan_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+ebt_vlan_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct ebt_vlan_info *info = par->matchinfo;
 	const struct vlan_hdr *fp;
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 73d924b..9e7d089 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -224,7 +224,7 @@ static inline int arp_checkentry(const struct arpt_arp *arp)
 }
 
 static unsigned int
-arpt_error(struct sk_buff *skb, const struct xt_target_param *par)
+arpt_error(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	if (net_ratelimit())
 		printk("arp_tables: error: '%s'\n",
diff --git a/net/ipv4/netfilter/arpt_mangle.c b/net/ipv4/netfilter/arpt_mangle.c
index 4b51a02..e1be7dd 100644
--- a/net/ipv4/netfilter/arpt_mangle.c
+++ b/net/ipv4/netfilter/arpt_mangle.c
@@ -9,7 +9,7 @@ MODULE_AUTHOR("Bart De Schuymer <bdschuym@pandora.be>");
 MODULE_DESCRIPTION("arptables arp payload mangle target");
 
 static unsigned int
-target(struct sk_buff *skb, const struct xt_target_param *par)
+target(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct arpt_mangle *mangle = par->targinfo;
 	const struct arphdr *arp;
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index e1a53c2..3ab1b81 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -165,7 +165,7 @@ ip_checkentry(const struct ipt_ip *ip)
 }
 
 static unsigned int
-ipt_error(struct sk_buff *skb, const struct xt_target_param *par)
+ipt_error(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	if (net_ratelimit())
 		pr_info("error: `%s'\n", (const char *)par->targinfo);
@@ -2138,7 +2138,7 @@ icmp_type_code_match(u_int8_t test_type, u_int8_t min_code, u_int8_t max_code,
 }
 
 static bool
-icmp_match(const struct sk_buff *skb, const struct xt_match_param *par)
+icmp_match(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct icmphdr *ic;
 	struct icmphdr _icmph;
diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 8815d45..f91c94b 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -282,7 +282,7 @@ clusterip_responsible(const struct clusterip_config *config, u_int32_t hash)
  ***********************************************************************/
 
 static unsigned int
-clusterip_tg(struct sk_buff *skb, const struct xt_target_param *par)
+clusterip_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct ipt_clusterip_tgt_info *cipinfo = par->targinfo;
 	struct nf_conn *ct;
diff --git a/net/ipv4/netfilter/ipt_ECN.c b/net/ipv4/netfilter/ipt_ECN.c
index 563049f..4bf3dc4 100644
--- a/net/ipv4/netfilter/ipt_ECN.c
+++ b/net/ipv4/netfilter/ipt_ECN.c
@@ -77,7 +77,7 @@ set_ect_tcp(struct sk_buff *skb, const struct ipt_ECN_info *einfo)
 }
 
 static unsigned int
-ecn_tg(struct sk_buff *skb, const struct xt_target_param *par)
+ecn_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct ipt_ECN_info *einfo = par->targinfo;
 
diff --git a/net/ipv4/netfilter/ipt_LOG.c b/net/ipv4/netfilter/ipt_LOG.c
index 3bd35f3..5234f4f 100644
--- a/net/ipv4/netfilter/ipt_LOG.c
+++ b/net/ipv4/netfilter/ipt_LOG.c
@@ -425,7 +425,7 @@ ipt_log_packet(u_int8_t pf,
 }
 
 static unsigned int
-log_tg(struct sk_buff *skb, const struct xt_target_param *par)
+log_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct ipt_log_info *loginfo = par->targinfo;
 	struct nf_loginfo li;
diff --git a/net/ipv4/netfilter/ipt_MASQUERADE.c b/net/ipv4/netfilter/ipt_MASQUERADE.c
index 02b1bc4..d2ed9dc 100644
--- a/net/ipv4/netfilter/ipt_MASQUERADE.c
+++ b/net/ipv4/netfilter/ipt_MASQUERADE.c
@@ -44,7 +44,7 @@ static int masquerade_tg_check(const struct xt_tgchk_param *par)
 }
 
 static unsigned int
-masquerade_tg(struct sk_buff *skb, const struct xt_target_param *par)
+masquerade_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	struct nf_conn *ct;
 	struct nf_conn_nat *nat;
diff --git a/net/ipv4/netfilter/ipt_NETMAP.c b/net/ipv4/netfilter/ipt_NETMAP.c
index 708c7f8..f43867d 100644
--- a/net/ipv4/netfilter/ipt_NETMAP.c
+++ b/net/ipv4/netfilter/ipt_NETMAP.c
@@ -38,7 +38,7 @@ static int netmap_tg_check(const struct xt_tgchk_param *par)
 }
 
 static unsigned int
-netmap_tg(struct sk_buff *skb, const struct xt_target_param *par)
+netmap_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	struct nf_conn *ct;
 	enum ip_conntrack_info ctinfo;
diff --git a/net/ipv4/netfilter/ipt_REDIRECT.c b/net/ipv4/netfilter/ipt_REDIRECT.c
index 3cf1019..18a0656 100644
--- a/net/ipv4/netfilter/ipt_REDIRECT.c
+++ b/net/ipv4/netfilter/ipt_REDIRECT.c
@@ -42,7 +42,7 @@ static int redirect_tg_check(const struct xt_tgchk_param *par)
 }
 
 static unsigned int
-redirect_tg(struct sk_buff *skb, const struct xt_target_param *par)
+redirect_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	struct nf_conn *ct;
 	enum ip_conntrack_info ctinfo;
diff --git a/net/ipv4/netfilter/ipt_REJECT.c b/net/ipv4/netfilter/ipt_REJECT.c
index a86135a..f5f4a88 100644
--- a/net/ipv4/netfilter/ipt_REJECT.c
+++ b/net/ipv4/netfilter/ipt_REJECT.c
@@ -136,7 +136,7 @@ static inline void send_unreach(struct sk_buff *skb_in, int code)
 }
 
 static unsigned int
-reject_tg(struct sk_buff *skb, const struct xt_target_param *par)
+reject_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct ipt_reject_info *reject = par->targinfo;
 
diff --git a/net/ipv4/netfilter/ipt_ULOG.c b/net/ipv4/netfilter/ipt_ULOG.c
index 8f60749..446e0f4 100644
--- a/net/ipv4/netfilter/ipt_ULOG.c
+++ b/net/ipv4/netfilter/ipt_ULOG.c
@@ -276,7 +276,7 @@ alloc_failure:
 }
 
 static unsigned int
-ulog_tg(struct sk_buff *skb, const struct xt_target_param *par)
+ulog_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	ipt_ulog_packet(par->hooknum, skb, par->in, par->out,
 	                par->targinfo, NULL);
diff --git a/net/ipv4/netfilter/ipt_addrtype.c b/net/ipv4/netfilter/ipt_addrtype.c
index e4b8f2b..24ec548 100644
--- a/net/ipv4/netfilter/ipt_addrtype.c
+++ b/net/ipv4/netfilter/ipt_addrtype.c
@@ -30,7 +30,7 @@ static inline bool match_type(struct net *net, const struct net_device *dev,
 }
 
 static bool
-addrtype_mt_v0(const struct sk_buff *skb, const struct xt_match_param *par)
+addrtype_mt_v0(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	struct net *net = dev_net(par->in ? par->in : par->out);
 	const struct ipt_addrtype_info *info = par->matchinfo;
@@ -48,7 +48,7 @@ addrtype_mt_v0(const struct sk_buff *skb, const struct xt_match_param *par)
 }
 
 static bool
-addrtype_mt_v1(const struct sk_buff *skb, const struct xt_match_param *par)
+addrtype_mt_v1(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	struct net *net = dev_net(par->in ? par->in : par->out);
 	const struct ipt_addrtype_info_v1 *info = par->matchinfo;
diff --git a/net/ipv4/netfilter/ipt_ah.c b/net/ipv4/netfilter/ipt_ah.c
index 9f98102..48a8293 100644
--- a/net/ipv4/netfilter/ipt_ah.c
+++ b/net/ipv4/netfilter/ipt_ah.c
@@ -30,7 +30,7 @@ spi_match(u_int32_t min, u_int32_t max, u_int32_t spi, bool invert)
 	return r;
 }
 
-static bool ah_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+static bool ah_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	struct ip_auth_hdr _ahdr;
 	const struct ip_auth_hdr *ah;
diff --git a/net/ipv4/netfilter/ipt_ecn.c b/net/ipv4/netfilter/ipt_ecn.c
index 32e2410..744d13e 100644
--- a/net/ipv4/netfilter/ipt_ecn.c
+++ b/net/ipv4/netfilter/ipt_ecn.c
@@ -67,7 +67,8 @@ static inline bool match_tcp(const struct sk_buff *skb,
 	return true;
 }
 
-static bool ecn_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+static bool ecn_mt(const struct sk_buff *skb,
+		   const struct xt_action_param *par)
 {
 	const struct ipt_ecn_info *info = par->matchinfo;
 
diff --git a/net/ipv4/netfilter/nf_nat_rule.c b/net/ipv4/netfilter/nf_nat_rule.c
index b48a0fc..98ed782 100644
--- a/net/ipv4/netfilter/nf_nat_rule.c
+++ b/net/ipv4/netfilter/nf_nat_rule.c
@@ -39,7 +39,7 @@ static const struct xt_table nat_table = {
 
 /* Source NAT */
 static unsigned int
-ipt_snat_target(struct sk_buff *skb, const struct xt_target_param *par)
+ipt_snat_target(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	struct nf_conn *ct;
 	enum ip_conntrack_info ctinfo;
@@ -58,7 +58,7 @@ ipt_snat_target(struct sk_buff *skb, const struct xt_target_param *par)
 }
 
 static unsigned int
-ipt_dnat_target(struct sk_buff *skb, const struct xt_target_param *par)
+ipt_dnat_target(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	struct nf_conn *ct;
 	enum ip_conntrack_info ctinfo;
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 076308c..c3bc999 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -197,7 +197,7 @@ ip6_checkentry(const struct ip6t_ip6 *ipv6)
 }
 
 static unsigned int
-ip6t_error(struct sk_buff *skb, const struct xt_target_param *par)
+ip6t_error(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	if (net_ratelimit())
 		pr_info("error: `%s'\n", (const char *)par->targinfo);
@@ -2154,7 +2154,7 @@ icmp6_type_code_match(u_int8_t test_type, u_int8_t min_code, u_int8_t max_code,
 }
 
 static bool
-icmp6_match(const struct sk_buff *skb, const struct xt_match_param *par)
+icmp6_match(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct icmp6hdr *ic;
 	struct icmp6hdr _icmph;
diff --git a/net/ipv6/netfilter/ip6t_LOG.c b/net/ipv6/netfilter/ip6t_LOG.c
index 1f47a52..af4ee11 100644
--- a/net/ipv6/netfilter/ip6t_LOG.c
+++ b/net/ipv6/netfilter/ip6t_LOG.c
@@ -436,7 +436,7 @@ ip6t_log_packet(u_int8_t pf,
 }
 
 static unsigned int
-log_tg6(struct sk_buff *skb, const struct xt_target_param *par)
+log_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct ip6t_log_info *loginfo = par->targinfo;
 	struct nf_loginfo li;
diff --git a/net/ipv6/netfilter/ip6t_REJECT.c b/net/ipv6/netfilter/ip6t_REJECT.c
index af1d649..47d2277 100644
--- a/net/ipv6/netfilter/ip6t_REJECT.c
+++ b/net/ipv6/netfilter/ip6t_REJECT.c
@@ -175,7 +175,7 @@ send_unreach(struct net *net, struct sk_buff *skb_in, unsigned char code,
 }
 
 static unsigned int
-reject_tg6(struct sk_buff *skb, const struct xt_target_param *par)
+reject_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct ip6t_reject_info *reject = par->targinfo;
 	struct net *net = dev_net((par->in != NULL) ? par->in : par->out);
diff --git a/net/ipv6/netfilter/ip6t_ah.c b/net/ipv6/netfilter/ip6t_ah.c
index 1580693..4fe7189 100644
--- a/net/ipv6/netfilter/ip6t_ah.c
+++ b/net/ipv6/netfilter/ip6t_ah.c
@@ -36,7 +36,8 @@ spi_match(u_int32_t min, u_int32_t max, u_int32_t spi, bool invert)
 	return r;
 }
 
-static bool ah_mt6(const struct sk_buff *skb, const struct xt_match_param *par)
+static bool ah_mt6(const struct sk_buff *skb,
+		   const struct xt_action_param *par)
 {
 	struct ip_auth_hdr _ah;
 	const struct ip_auth_hdr *ah;
diff --git a/net/ipv6/netfilter/ip6t_eui64.c b/net/ipv6/netfilter/ip6t_eui64.c
index ca287f6..2fd2be1 100644
--- a/net/ipv6/netfilter/ip6t_eui64.c
+++ b/net/ipv6/netfilter/ip6t_eui64.c
@@ -20,7 +20,7 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Andras Kis-Szabo <kisza@sch.bme.hu>");
 
 static bool
-eui64_mt6(const struct sk_buff *skb, const struct xt_match_param *par)
+eui64_mt6(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	unsigned char eui64[8];
 
diff --git a/net/ipv6/netfilter/ip6t_frag.c b/net/ipv6/netfilter/ip6t_frag.c
index a5daf0f..8401aa8 100644
--- a/net/ipv6/netfilter/ip6t_frag.c
+++ b/net/ipv6/netfilter/ip6t_frag.c
@@ -35,7 +35,7 @@ id_match(u_int32_t min, u_int32_t max, u_int32_t id, bool invert)
 }
 
 static bool
-frag_mt6(const struct sk_buff *skb, const struct xt_match_param *par)
+frag_mt6(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	struct frag_hdr _frag;
 	const struct frag_hdr *fh;
diff --git a/net/ipv6/netfilter/ip6t_hbh.c b/net/ipv6/netfilter/ip6t_hbh.c
index e424e7c..d19d5cf 100644
--- a/net/ipv6/netfilter/ip6t_hbh.c
+++ b/net/ipv6/netfilter/ip6t_hbh.c
@@ -44,7 +44,7 @@ MODULE_ALIAS("ip6t_dst");
 static struct xt_match hbh_mt6_reg[] __read_mostly;
 
 static bool
-hbh_mt6(const struct sk_buff *skb, const struct xt_match_param *par)
+hbh_mt6(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	struct ipv6_opt_hdr _optsh;
 	const struct ipv6_opt_hdr *oh;
diff --git a/net/ipv6/netfilter/ip6t_ipv6header.c b/net/ipv6/netfilter/ip6t_ipv6header.c
index 46fbabb..8e88bb8 100644
--- a/net/ipv6/netfilter/ip6t_ipv6header.c
+++ b/net/ipv6/netfilter/ip6t_ipv6header.c
@@ -27,7 +27,7 @@ MODULE_DESCRIPTION("Xtables: IPv6 header types match");
 MODULE_AUTHOR("Andras Kis-Szabo <kisza@sch.bme.hu>");
 
 static bool
-ipv6header_mt6(const struct sk_buff *skb, const struct xt_match_param *par)
+ipv6header_mt6(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct ip6t_ipv6header_info *info = par->matchinfo;
 	unsigned int temp;
diff --git a/net/ipv6/netfilter/ip6t_mh.c b/net/ipv6/netfilter/ip6t_mh.c
index c9f443e..4a60788 100644
--- a/net/ipv6/netfilter/ip6t_mh.c
+++ b/net/ipv6/netfilter/ip6t_mh.c
@@ -32,7 +32,8 @@ type_match(u_int8_t min, u_int8_t max, u_int8_t type, bool invert)
 	return (type >= min && type <= max) ^ invert;
 }
 
-static bool mh_mt6(const struct sk_buff *skb, const struct xt_match_param *par)
+static bool mh_mt6(const struct sk_buff *skb,
+		   const struct xt_action_param *par)
 {
 	struct ip6_mh _mh;
 	const struct ip6_mh *mh;
diff --git a/net/ipv6/netfilter/ip6t_rt.c b/net/ipv6/netfilter/ip6t_rt.c
index 0932272..793c272 100644
--- a/net/ipv6/netfilter/ip6t_rt.c
+++ b/net/ipv6/netfilter/ip6t_rt.c
@@ -36,7 +36,8 @@ segsleft_match(u_int32_t min, u_int32_t max, u_int32_t id, bool invert)
 	return r;
 }
 
-static bool rt_mt6(const struct sk_buff *skb, const struct xt_match_param *par)
+static bool rt_mt6(const struct sk_buff *skb,
+		   const struct xt_action_param *par)
 {
 	struct ipv6_rt_hdr _route;
 	const struct ipv6_rt_hdr *rh;
diff --git a/net/netfilter/xt_CLASSIFY.c b/net/netfilter/xt_CLASSIFY.c
index 011bc80..c2c0e4a 100644
--- a/net/netfilter/xt_CLASSIFY.c
+++ b/net/netfilter/xt_CLASSIFY.c
@@ -27,7 +27,7 @@ MODULE_ALIAS("ipt_CLASSIFY");
 MODULE_ALIAS("ip6t_CLASSIFY");
 
 static unsigned int
-classify_tg(struct sk_buff *skb, const struct xt_target_param *par)
+classify_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_classify_target_info *clinfo = par->targinfo;
 
diff --git a/net/netfilter/xt_CONNSECMARK.c b/net/netfilter/xt_CONNSECMARK.c
index e953e30..e04dc28 100644
--- a/net/netfilter/xt_CONNSECMARK.c
+++ b/net/netfilter/xt_CONNSECMARK.c
@@ -64,7 +64,7 @@ static void secmark_restore(struct sk_buff *skb)
 }
 
 static unsigned int
-connsecmark_tg(struct sk_buff *skb, const struct xt_target_param *par)
+connsecmark_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_connsecmark_target_info *info = par->targinfo;
 
diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index c8f5478..562bf32 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -20,7 +20,7 @@
 #include <net/netfilter/nf_conntrack_zones.h>
 
 static unsigned int xt_ct_target(struct sk_buff *skb,
-				 const struct xt_target_param *par)
+				 const struct xt_action_param *par)
 {
 	const struct xt_ct_target_info *info = par->targinfo;
 	struct nf_conn *ct = info->ct;
diff --git a/net/netfilter/xt_DSCP.c b/net/netfilter/xt_DSCP.c
index 969634f..0a22919 100644
--- a/net/netfilter/xt_DSCP.c
+++ b/net/netfilter/xt_DSCP.c
@@ -28,7 +28,7 @@ MODULE_ALIAS("ipt_TOS");
 MODULE_ALIAS("ip6t_TOS");
 
 static unsigned int
-dscp_tg(struct sk_buff *skb, const struct xt_target_param *par)
+dscp_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_DSCP_info *dinfo = par->targinfo;
 	u_int8_t dscp = ipv4_get_dsfield(ip_hdr(skb)) >> XT_DSCP_SHIFT;
@@ -45,7 +45,7 @@ dscp_tg(struct sk_buff *skb, const struct xt_target_param *par)
 }
 
 static unsigned int
-dscp_tg6(struct sk_buff *skb, const struct xt_target_param *par)
+dscp_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_DSCP_info *dinfo = par->targinfo;
 	u_int8_t dscp = ipv6_get_dsfield(ipv6_hdr(skb)) >> XT_DSCP_SHIFT;
@@ -72,7 +72,7 @@ static int dscp_tg_check(const struct xt_tgchk_param *par)
 }
 
 static unsigned int
-tos_tg(struct sk_buff *skb, const struct xt_target_param *par)
+tos_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_tos_target_info *info = par->targinfo;
 	struct iphdr *iph = ip_hdr(skb);
@@ -92,7 +92,7 @@ tos_tg(struct sk_buff *skb, const struct xt_target_param *par)
 }
 
 static unsigned int
-tos_tg6(struct sk_buff *skb, const struct xt_target_param *par)
+tos_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_tos_target_info *info = par->targinfo;
 	struct ipv6hdr *iph = ipv6_hdr(skb);
diff --git a/net/netfilter/xt_HL.c b/net/netfilter/xt_HL.c
index 77b99f7..95b0848 100644
--- a/net/netfilter/xt_HL.c
+++ b/net/netfilter/xt_HL.c
@@ -26,7 +26,7 @@ MODULE_DESCRIPTION("Xtables: Hoplimit/TTL Limit field modification target");
 MODULE_LICENSE("GPL");
 
 static unsigned int
-ttl_tg(struct sk_buff *skb, const struct xt_target_param *par)
+ttl_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	struct iphdr *iph;
 	const struct ipt_TTL_info *info = par->targinfo;
@@ -66,7 +66,7 @@ ttl_tg(struct sk_buff *skb, const struct xt_target_param *par)
 }
 
 static unsigned int
-hl_tg6(struct sk_buff *skb, const struct xt_target_param *par)
+hl_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	struct ipv6hdr *ip6h;
 	const struct ip6t_HL_info *info = par->targinfo;
diff --git a/net/netfilter/xt_LED.c b/net/netfilter/xt_LED.c
index ab6f8ff..a414050 100644
--- a/net/netfilter/xt_LED.c
+++ b/net/netfilter/xt_LED.c
@@ -49,7 +49,7 @@ struct xt_led_info_internal {
 };
 
 static unsigned int
-led_tg(struct sk_buff *skb, const struct xt_target_param *par)
+led_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_led_info *ledinfo = par->targinfo;
 	struct xt_led_info_internal *ledinternal = ledinfo->internal_data;
diff --git a/net/netfilter/xt_NFLOG.c b/net/netfilter/xt_NFLOG.c
index 42dd874..a17dd0f 100644
--- a/net/netfilter/xt_NFLOG.c
+++ b/net/netfilter/xt_NFLOG.c
@@ -22,7 +22,7 @@ MODULE_ALIAS("ipt_NFLOG");
 MODULE_ALIAS("ip6t_NFLOG");
 
 static unsigned int
-nflog_tg(struct sk_buff *skb, const struct xt_target_param *par)
+nflog_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_nflog_info *info = par->targinfo;
 	struct nf_loginfo li;
diff --git a/net/netfilter/xt_NFQUEUE.c b/net/netfilter/xt_NFQUEUE.c
index f9217cb..039cce1 100644
--- a/net/netfilter/xt_NFQUEUE.c
+++ b/net/netfilter/xt_NFQUEUE.c
@@ -31,7 +31,7 @@ static u32 jhash_initval __read_mostly;
 static bool rnd_inited __read_mostly;
 
 static unsigned int
-nfqueue_tg(struct sk_buff *skb, const struct xt_target_param *par)
+nfqueue_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_NFQ_info *tinfo = par->targinfo;
 
@@ -65,7 +65,7 @@ static u32 hash_v6(const struct sk_buff *skb)
 #endif
 
 static unsigned int
-nfqueue_tg_v1(struct sk_buff *skb, const struct xt_target_param *par)
+nfqueue_tg_v1(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_NFQ_info_v1 *info = par->targinfo;
 	u32 queue = info->queuenum;
diff --git a/net/netfilter/xt_NOTRACK.c b/net/netfilter/xt_NOTRACK.c
index e7a0a54..512b912 100644
--- a/net/netfilter/xt_NOTRACK.c
+++ b/net/netfilter/xt_NOTRACK.c
@@ -13,7 +13,7 @@ MODULE_ALIAS("ipt_NOTRACK");
 MODULE_ALIAS("ip6t_NOTRACK");
 
 static unsigned int
-notrack_tg(struct sk_buff *skb, const struct xt_target_param *par)
+notrack_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	/* Previously seen (loopback)? Ignore. */
 	if (skb->nfct != NULL)
diff --git a/net/netfilter/xt_RATEEST.c b/net/netfilter/xt_RATEEST.c
index a02193f..69c01e1 100644
--- a/net/netfilter/xt_RATEEST.c
+++ b/net/netfilter/xt_RATEEST.c
@@ -73,7 +73,7 @@ void xt_rateest_put(struct xt_rateest *est)
 EXPORT_SYMBOL_GPL(xt_rateest_put);
 
 static unsigned int
-xt_rateest_tg(struct sk_buff *skb, const struct xt_target_param *par)
+xt_rateest_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_rateest_target_info *info = par->targinfo;
 	struct gnet_stats_basic_packed *stats = &info->est->bstats;
diff --git a/net/netfilter/xt_SECMARK.c b/net/netfilter/xt_SECMARK.c
index a91d4a7..23b2d6c 100644
--- a/net/netfilter/xt_SECMARK.c
+++ b/net/netfilter/xt_SECMARK.c
@@ -30,7 +30,7 @@ MODULE_ALIAS("ip6t_SECMARK");
 static u8 mode;
 
 static unsigned int
-secmark_tg(struct sk_buff *skb, const struct xt_target_param *par)
+secmark_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	u32 secmark = 0;
 	const struct xt_secmark_target_info *info = par->targinfo;
diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index d046064..62ec021 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -172,7 +172,7 @@ static u_int32_t tcpmss_reverse_mtu(const struct sk_buff *skb,
 }
 
 static unsigned int
-tcpmss_tg4(struct sk_buff *skb, const struct xt_target_param *par)
+tcpmss_tg4(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	struct iphdr *iph = ip_hdr(skb);
 	__be16 newlen;
@@ -195,7 +195,7 @@ tcpmss_tg4(struct sk_buff *skb, const struct xt_target_param *par)
 
 #if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_MODULE)
 static unsigned int
-tcpmss_tg6(struct sk_buff *skb, const struct xt_target_param *par)
+tcpmss_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	struct ipv6hdr *ipv6h = ipv6_hdr(skb);
 	u8 nexthdr;
diff --git a/net/netfilter/xt_TCPOPTSTRIP.c b/net/netfilter/xt_TCPOPTSTRIP.c
index e8b5760..9dc9ecf 100644
--- a/net/netfilter/xt_TCPOPTSTRIP.c
+++ b/net/netfilter/xt_TCPOPTSTRIP.c
@@ -74,7 +74,7 @@ tcpoptstrip_mangle_packet(struct sk_buff *skb,
 }
 
 static unsigned int
-tcpoptstrip_tg4(struct sk_buff *skb, const struct xt_target_param *par)
+tcpoptstrip_tg4(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	return tcpoptstrip_mangle_packet(skb, par->targinfo, ip_hdrlen(skb),
 	       sizeof(struct iphdr) + sizeof(struct tcphdr));
@@ -82,7 +82,7 @@ tcpoptstrip_tg4(struct sk_buff *skb, const struct xt_target_param *par)
 
 #if defined(CONFIG_IP6_NF_MANGLE) || defined(CONFIG_IP6_NF_MANGLE_MODULE)
 static unsigned int
-tcpoptstrip_tg6(struct sk_buff *skb, const struct xt_target_param *par)
+tcpoptstrip_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	struct ipv6hdr *ipv6h = ipv6_hdr(skb);
 	int tcphoff;
diff --git a/net/netfilter/xt_TEE.c b/net/netfilter/xt_TEE.c
index 49da6c0..d7920d9 100644
--- a/net/netfilter/xt_TEE.c
+++ b/net/netfilter/xt_TEE.c
@@ -84,7 +84,7 @@ tee_tg_route4(struct sk_buff *skb, const struct xt_tee_tginfo *info)
 }
 
 static unsigned int
-tee_tg4(struct sk_buff *skb, const struct xt_target_param *par)
+tee_tg4(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_tee_tginfo *info = par->targinfo;
 	struct iphdr *iph;
@@ -165,7 +165,7 @@ tee_tg_route6(struct sk_buff *skb, const struct xt_tee_tginfo *info)
 }
 
 static unsigned int
-tee_tg6(struct sk_buff *skb, const struct xt_target_param *par)
+tee_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_tee_tginfo *info = par->targinfo;
 
diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index 4f246dd..e1a0ded 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -25,7 +25,7 @@
 #include <net/netfilter/nf_tproxy_core.h>
 
 static unsigned int
-tproxy_tg(struct sk_buff *skb, const struct xt_target_param *par)
+tproxy_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct iphdr *iph = ip_hdr(skb);
 	const struct xt_tproxy_target_info *tgi = par->targinfo;
diff --git a/net/netfilter/xt_TRACE.c b/net/netfilter/xt_TRACE.c
index fbb04b8..df48967 100644
--- a/net/netfilter/xt_TRACE.c
+++ b/net/netfilter/xt_TRACE.c
@@ -11,7 +11,7 @@ MODULE_ALIAS("ipt_TRACE");
 MODULE_ALIAS("ip6t_TRACE");
 
 static unsigned int
-trace_tg(struct sk_buff *skb, const struct xt_target_param *par)
+trace_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	skb->nf_trace = 1;
 	return XT_CONTINUE;
diff --git a/net/netfilter/xt_cluster.c b/net/netfilter/xt_cluster.c
index 6c941e1..67fc317 100644
--- a/net/netfilter/xt_cluster.c
+++ b/net/netfilter/xt_cluster.c
@@ -86,7 +86,7 @@ xt_cluster_is_multicast_addr(const struct sk_buff *skb, u_int8_t family)
 }
 
 static bool
-xt_cluster_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+xt_cluster_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	struct sk_buff *pskb = (struct sk_buff *)skb;
 	const struct xt_cluster_match_info *info = par->matchinfo;
diff --git a/net/netfilter/xt_comment.c b/net/netfilter/xt_comment.c
index e821798..1dbb3e1 100644
--- a/net/netfilter/xt_comment.c
+++ b/net/netfilter/xt_comment.c
@@ -16,7 +16,7 @@ MODULE_ALIAS("ipt_comment");
 MODULE_ALIAS("ip6t_comment");
 
 static bool
-comment_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+comment_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	/* We always match */
 	return true;
diff --git a/net/netfilter/xt_connbytes.c b/net/netfilter/xt_connbytes.c
index ff738a5..5e5cf15 100644
--- a/net/netfilter/xt_connbytes.c
+++ b/net/netfilter/xt_connbytes.c
@@ -18,7 +18,7 @@ MODULE_ALIAS("ipt_connbytes");
 MODULE_ALIAS("ip6t_connbytes");
 
 static bool
-connbytes_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+connbytes_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_connbytes_info *sinfo = par->matchinfo;
 	const struct nf_conn *ct;
diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index 326bc1b..6eec191 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -173,7 +173,7 @@ static int count_them(struct net *net,
 }
 
 static bool
-connlimit_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+connlimit_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	struct net *net = dev_net(par->in ? par->in : par->out);
 	const struct xt_connlimit_info *info = par->matchinfo;
diff --git a/net/netfilter/xt_connmark.c b/net/netfilter/xt_connmark.c
index ae10154..b43cfc7 100644
--- a/net/netfilter/xt_connmark.c
+++ b/net/netfilter/xt_connmark.c
@@ -37,7 +37,7 @@ MODULE_ALIAS("ipt_connmark");
 MODULE_ALIAS("ip6t_connmark");
 
 static unsigned int
-connmark_tg(struct sk_buff *skb, const struct xt_target_param *par)
+connmark_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_connmark_tginfo1 *info = par->targinfo;
 	enum ip_conntrack_info ctinfo;
@@ -91,7 +91,7 @@ static void connmark_tg_destroy(const struct xt_tgdtor_param *par)
 }
 
 static bool
-connmark_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+connmark_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_connmark_mtinfo1 *info = par->matchinfo;
 	enum ip_conntrack_info ctinfo;
diff --git a/net/netfilter/xt_conntrack.c b/net/netfilter/xt_conntrack.c
index 3348706..14a96f4 100644
--- a/net/netfilter/xt_conntrack.c
+++ b/net/netfilter/xt_conntrack.c
@@ -113,7 +113,7 @@ ct_proto_port_check(const struct xt_conntrack_mtinfo2 *info,
 }
 
 static bool
-conntrack_mt(const struct sk_buff *skb, const struct xt_match_param *par,
+conntrack_mt(const struct sk_buff *skb, const struct xt_action_param *par,
              u16 state_mask, u16 status_mask)
 {
 	const struct xt_conntrack_mtinfo2 *info = par->matchinfo;
@@ -191,7 +191,7 @@ conntrack_mt(const struct sk_buff *skb, const struct xt_match_param *par,
 }
 
 static bool
-conntrack_mt_v1(const struct sk_buff *skb, const struct xt_match_param *par)
+conntrack_mt_v1(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_conntrack_mtinfo1 *info = par->matchinfo;
 
@@ -199,7 +199,7 @@ conntrack_mt_v1(const struct sk_buff *skb, const struct xt_match_param *par)
 }
 
 static bool
-conntrack_mt_v2(const struct sk_buff *skb, const struct xt_match_param *par)
+conntrack_mt_v2(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_conntrack_mtinfo2 *info = par->matchinfo;
 
diff --git a/net/netfilter/xt_dccp.c b/net/netfilter/xt_dccp.c
index 0d260ae..7a4d4e8 100644
--- a/net/netfilter/xt_dccp.c
+++ b/net/netfilter/xt_dccp.c
@@ -96,7 +96,7 @@ match_option(u_int8_t option, const struct sk_buff *skb, unsigned int protoff,
 }
 
 static bool
-dccp_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+dccp_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_dccp_info *info = par->matchinfo;
 	const struct dccp_hdr *dh;
diff --git a/net/netfilter/xt_dscp.c b/net/netfilter/xt_dscp.c
index 9db51fd..2133b50 100644
--- a/net/netfilter/xt_dscp.c
+++ b/net/netfilter/xt_dscp.c
@@ -25,7 +25,7 @@ MODULE_ALIAS("ipt_tos");
 MODULE_ALIAS("ip6t_tos");
 
 static bool
-dscp_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+dscp_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_dscp_info *info = par->matchinfo;
 	u_int8_t dscp = ipv4_get_dsfield(ip_hdr(skb)) >> XT_DSCP_SHIFT;
@@ -34,7 +34,7 @@ dscp_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 }
 
 static bool
-dscp_mt6(const struct sk_buff *skb, const struct xt_match_param *par)
+dscp_mt6(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_dscp_info *info = par->matchinfo;
 	u_int8_t dscp = ipv6_get_dsfield(ipv6_hdr(skb)) >> XT_DSCP_SHIFT;
@@ -54,7 +54,8 @@ static int dscp_mt_check(const struct xt_mtchk_param *par)
 	return 0;
 }
 
-static bool tos_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+static bool tos_mt(const struct sk_buff *skb,
+		   const struct xt_action_param *par)
 {
 	const struct xt_tos_match_info *info = par->matchinfo;
 
diff --git a/net/netfilter/xt_esp.c b/net/netfilter/xt_esp.c
index 143bfdc..39caaff 100644
--- a/net/netfilter/xt_esp.c
+++ b/net/netfilter/xt_esp.c
@@ -36,7 +36,8 @@ spi_match(u_int32_t min, u_int32_t max, u_int32_t spi, bool invert)
 	return r;
 }
 
-static bool esp_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+static bool esp_mt(const struct sk_buff *skb,
+		   const struct xt_action_param *par)
 {
 	const struct ip_esp_hdr *eh;
 	struct ip_esp_hdr _esp;
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 0c366d3..700c21e 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -516,7 +516,7 @@ hashlimit_init_dst(const struct xt_hashlimit_htable *hinfo,
 }
 
 static bool
-hashlimit_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+hashlimit_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_hashlimit_mtinfo1 *info = par->matchinfo;
 	struct xt_hashlimit_htable *hinfo = info->hinfo;
diff --git a/net/netfilter/xt_helper.c b/net/netfilter/xt_helper.c
index b8b3e13..e941bd2 100644
--- a/net/netfilter/xt_helper.c
+++ b/net/netfilter/xt_helper.c
@@ -24,7 +24,7 @@ MODULE_ALIAS("ip6t_helper");
 
 
 static bool
-helper_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+helper_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_helper_info *info = par->matchinfo;
 	const struct nf_conn *ct;
diff --git a/net/netfilter/xt_hl.c b/net/netfilter/xt_hl.c
index be53f72..335c34a 100644
--- a/net/netfilter/xt_hl.c
+++ b/net/netfilter/xt_hl.c
@@ -25,7 +25,8 @@ MODULE_LICENSE("GPL");
 MODULE_ALIAS("ipt_ttl");
 MODULE_ALIAS("ip6t_hl");
 
-static bool ttl_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+static bool ttl_mt(const struct sk_buff *skb,
+		   const struct xt_action_param *par)
 {
 	const struct ipt_ttl_info *info = par->matchinfo;
 	const u8 ttl = ip_hdr(skb)->ttl;
@@ -44,7 +45,8 @@ static bool ttl_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	return false;
 }
 
-static bool hl_mt6(const struct sk_buff *skb, const struct xt_match_param *par)
+static bool hl_mt6(const struct sk_buff *skb,
+		   const struct xt_action_param *par)
 {
 	const struct ip6t_hl_info *info = par->matchinfo;
 	const struct ipv6hdr *ip6h = ipv6_hdr(skb);
diff --git a/net/netfilter/xt_iprange.c b/net/netfilter/xt_iprange.c
index 8471d97..9578860 100644
--- a/net/netfilter/xt_iprange.c
+++ b/net/netfilter/xt_iprange.c
@@ -17,7 +17,7 @@
 #include <linux/netfilter/xt_iprange.h>
 
 static bool
-iprange_mt4(const struct sk_buff *skb, const struct xt_match_param *par)
+iprange_mt4(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_iprange_mtinfo *info = par->matchinfo;
 	const struct iphdr *iph = ip_hdr(skb);
@@ -68,7 +68,7 @@ iprange_ipv6_sub(const struct in6_addr *a, const struct in6_addr *b)
 }
 
 static bool
-iprange_mt6(const struct sk_buff *skb, const struct xt_match_param *par)
+iprange_mt6(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_iprange_mtinfo *info = par->matchinfo;
 	const struct ipv6hdr *iph = ipv6_hdr(skb);
diff --git a/net/netfilter/xt_length.c b/net/netfilter/xt_length.c
index c4871ca..842149b 100644
--- a/net/netfilter/xt_length.c
+++ b/net/netfilter/xt_length.c
@@ -21,7 +21,7 @@ MODULE_ALIAS("ipt_length");
 MODULE_ALIAS("ip6t_length");
 
 static bool
-length_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+length_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_length_info *info = par->matchinfo;
 	u_int16_t pktlen = ntohs(ip_hdr(skb)->tot_len);
@@ -30,7 +30,7 @@ length_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 }
 
 static bool
-length_mt6(const struct sk_buff *skb, const struct xt_match_param *par)
+length_mt6(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_length_info *info = par->matchinfo;
 	const u_int16_t pktlen = ntohs(ipv6_hdr(skb)->payload_len) +
diff --git a/net/netfilter/xt_limit.c b/net/netfilter/xt_limit.c
index 88215dc..7dcfe86 100644
--- a/net/netfilter/xt_limit.c
+++ b/net/netfilter/xt_limit.c
@@ -65,7 +65,7 @@ static DEFINE_SPINLOCK(limit_lock);
 #define CREDITS_PER_JIFFY POW2_BELOW32(MAX_CPJ)
 
 static bool
-limit_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+limit_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_rateinfo *r = par->matchinfo;
 	struct xt_limit_priv *priv = r->master;
diff --git a/net/netfilter/xt_mac.c b/net/netfilter/xt_mac.c
index b971ce9..36c4964 100644
--- a/net/netfilter/xt_mac.c
+++ b/net/netfilter/xt_mac.c
@@ -25,7 +25,8 @@ MODULE_DESCRIPTION("Xtables: MAC address match");
 MODULE_ALIAS("ipt_mac");
 MODULE_ALIAS("ip6t_mac");
 
-static bool mac_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+static bool mac_mt(const struct sk_buff *skb,
+		   const struct xt_action_param *par)
 {
 	const struct xt_mac_info *info = par->matchinfo;
 	bool ret;
diff --git a/net/netfilter/xt_mark.c b/net/netfilter/xt_mark.c
index 035c468..3c83470 100644
--- a/net/netfilter/xt_mark.c
+++ b/net/netfilter/xt_mark.c
@@ -25,7 +25,7 @@ MODULE_ALIAS("ipt_MARK");
 MODULE_ALIAS("ip6t_MARK");
 
 static unsigned int
-mark_tg(struct sk_buff *skb, const struct xt_target_param *par)
+mark_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_mark_tginfo2 *info = par->targinfo;
 
@@ -34,7 +34,7 @@ mark_tg(struct sk_buff *skb, const struct xt_target_param *par)
 }
 
 static bool
-mark_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+mark_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_mark_mtinfo1 *info = par->matchinfo;
 
diff --git a/net/netfilter/xt_multiport.c b/net/netfilter/xt_multiport.c
index b21f904..3140fd4 100644
--- a/net/netfilter/xt_multiport.c
+++ b/net/netfilter/xt_multiport.c
@@ -72,7 +72,7 @@ ports_match_v1(const struct xt_multiport_v1 *minfo,
 }
 
 static bool
-multiport_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+multiport_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const __be16 *pptr;
 	__be16 _ports[2];
diff --git a/net/netfilter/xt_osf.c b/net/netfilter/xt_osf.c
index 8dcde13..37aa558 100644
--- a/net/netfilter/xt_osf.c
+++ b/net/netfilter/xt_osf.c
@@ -193,8 +193,8 @@ static inline int xt_osf_ttl(const struct sk_buff *skb, const struct xt_osf_info
 	return ip->ttl == f_ttl;
 }
 
-static bool xt_osf_match_packet(const struct sk_buff *skb,
-		const struct xt_match_param *p)
+static bool
+xt_osf_match_packet(const struct sk_buff *skb, const struct xt_action_param *p)
 {
 	const struct xt_osf_info *info = p->matchinfo;
 	const struct iphdr *ip = ip_hdr(skb);
diff --git a/net/netfilter/xt_owner.c b/net/netfilter/xt_owner.c
index d24c76d..3dd1391 100644
--- a/net/netfilter/xt_owner.c
+++ b/net/netfilter/xt_owner.c
@@ -18,7 +18,7 @@
 #include <linux/netfilter/xt_owner.h>
 
 static bool
-owner_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+owner_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_owner_match_info *info = par->matchinfo;
 	const struct file *filp;
diff --git a/net/netfilter/xt_physdev.c b/net/netfilter/xt_physdev.c
index d0bdf3d..298cd29 100644
--- a/net/netfilter/xt_physdev.c
+++ b/net/netfilter/xt_physdev.c
@@ -22,7 +22,7 @@ MODULE_ALIAS("ip6t_physdev");
 
 
 static bool
-physdev_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+physdev_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	static const char nulldevname[IFNAMSIZ] __attribute__((aligned(sizeof(long))));
 	const struct xt_physdev_info *info = par->matchinfo;
diff --git a/net/netfilter/xt_pkttype.c b/net/netfilter/xt_pkttype.c
index 69da1d3..d95f214 100644
--- a/net/netfilter/xt_pkttype.c
+++ b/net/netfilter/xt_pkttype.c
@@ -23,7 +23,7 @@ MODULE_ALIAS("ipt_pkttype");
 MODULE_ALIAS("ip6t_pkttype");
 
 static bool
-pkttype_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+pkttype_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_pkttype_info *info = par->matchinfo;
 	u_int8_t type;
diff --git a/net/netfilter/xt_policy.c b/net/netfilter/xt_policy.c
index 1fa239c..1abfc7a 100644
--- a/net/netfilter/xt_policy.c
+++ b/net/netfilter/xt_policy.c
@@ -110,7 +110,7 @@ match_policy_out(const struct sk_buff *skb, const struct xt_policy_info *info,
 }
 
 static bool
-policy_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+policy_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_policy_info *info = par->matchinfo;
 	int ret;
diff --git a/net/netfilter/xt_quota.c b/net/netfilter/xt_quota.c
index 7c95d69..e79e07c 100644
--- a/net/netfilter/xt_quota.c
+++ b/net/netfilter/xt_quota.c
@@ -23,7 +23,7 @@ MODULE_ALIAS("ip6t_quota");
 static DEFINE_SPINLOCK(quota_lock);
 
 static bool
-quota_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+quota_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	struct xt_quota_info *q = (void *)par->matchinfo;
 	struct xt_quota_priv *priv = q->master;
diff --git a/net/netfilter/xt_rateest.c b/net/netfilter/xt_rateest.c
index 23805f8..53f7a4d 100644
--- a/net/netfilter/xt_rateest.c
+++ b/net/netfilter/xt_rateest.c
@@ -15,7 +15,7 @@
 
 
 static bool
-xt_rateest_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+xt_rateest_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_rateest_match_info *info = par->matchinfo;
 	struct gnet_stats_rate_est *r;
diff --git a/net/netfilter/xt_realm.c b/net/netfilter/xt_realm.c
index 484d168..b063c78 100644
--- a/net/netfilter/xt_realm.c
+++ b/net/netfilter/xt_realm.c
@@ -22,7 +22,7 @@ MODULE_DESCRIPTION("Xtables: Routing realm match");
 MODULE_ALIAS("ipt_realm");
 
 static bool
-realm_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+realm_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_realm_info *info = par->matchinfo;
 	const struct dst_entry *dst = skb_dst(skb);
diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index b88d63b..503b7f1 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -224,7 +224,7 @@ static void recent_table_flush(struct recent_table *t)
 }
 
 static bool
-recent_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+recent_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	struct net *net = dev_net(par->in ? par->in : par->out);
 	struct recent_net *recent_net = recent_pernet(net);
diff --git a/net/netfilter/xt_sctp.c b/net/netfilter/xt_sctp.c
index c3694df..da4c3cb 100644
--- a/net/netfilter/xt_sctp.c
+++ b/net/netfilter/xt_sctp.c
@@ -114,7 +114,7 @@ match_packet(const struct sk_buff *skb,
 }
 
 static bool
-sctp_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+sctp_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_sctp_info *info = par->matchinfo;
 	const sctp_sctphdr_t *sh;
diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index a9b1686..2665e32 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -88,7 +88,7 @@ extract_icmp_fields(const struct sk_buff *skb,
 
 
 static bool
-socket_match(const struct sk_buff *skb, const struct xt_match_param *par,
+socket_match(const struct sk_buff *skb, const struct xt_action_param *par,
 	     const struct xt_socket_mtinfo1 *info)
 {
 	const struct iphdr *iph = ip_hdr(skb);
@@ -174,13 +174,13 @@ socket_match(const struct sk_buff *skb, const struct xt_match_param *par,
 }
 
 static bool
-socket_mt_v0(const struct sk_buff *skb, const struct xt_match_param *par)
+socket_mt_v0(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	return socket_match(skb, par, NULL);
 }
 
 static bool
-socket_mt_v1(const struct sk_buff *skb, const struct xt_match_param *par)
+socket_mt_v1(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	return socket_match(skb, par, par->matchinfo);
 }
diff --git a/net/netfilter/xt_state.c b/net/netfilter/xt_state.c
index bb12718..344cca6 100644
--- a/net/netfilter/xt_state.c
+++ b/net/netfilter/xt_state.c
@@ -21,7 +21,7 @@ MODULE_ALIAS("ipt_state");
 MODULE_ALIAS("ip6t_state");
 
 static bool
-state_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+state_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_state_info *sinfo = par->matchinfo;
 	enum ip_conntrack_info ctinfo;
diff --git a/net/netfilter/xt_statistic.c b/net/netfilter/xt_statistic.c
index 5aeca1d..ee4540a 100644
--- a/net/netfilter/xt_statistic.c
+++ b/net/netfilter/xt_statistic.c
@@ -30,7 +30,7 @@ MODULE_ALIAS("ip6t_statistic");
 static DEFINE_SPINLOCK(nth_lock);
 
 static bool
-statistic_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+statistic_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_statistic_info *info = par->matchinfo;
 	bool ret = info->flags & XT_STATISTIC_INVERT;
diff --git a/net/netfilter/xt_string.c b/net/netfilter/xt_string.c
index f6d5112..fd5dc50 100644
--- a/net/netfilter/xt_string.c
+++ b/net/netfilter/xt_string.c
@@ -23,7 +23,7 @@ MODULE_ALIAS("ipt_string");
 MODULE_ALIAS("ip6t_string");
 
 static bool
-string_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+string_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_string_info *conf = par->matchinfo;
 	struct ts_state state;
diff --git a/net/netfilter/xt_tcpmss.c b/net/netfilter/xt_tcpmss.c
index 4809b34..5c8a7b4 100644
--- a/net/netfilter/xt_tcpmss.c
+++ b/net/netfilter/xt_tcpmss.c
@@ -25,7 +25,7 @@ MODULE_ALIAS("ipt_tcpmss");
 MODULE_ALIAS("ip6t_tcpmss");
 
 static bool
-tcpmss_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+tcpmss_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_tcpmss_match_info *info = par->matchinfo;
 	const struct tcphdr *th;
diff --git a/net/netfilter/xt_tcpudp.c b/net/netfilter/xt_tcpudp.c
index efa2ede..19c31d4 100644
--- a/net/netfilter/xt_tcpudp.c
+++ b/net/netfilter/xt_tcpudp.c
@@ -62,7 +62,8 @@ tcp_find_option(u_int8_t option,
 	return invert;
 }
 
-static bool tcp_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+static bool tcp_mt(const struct sk_buff *skb,
+		   const struct xt_action_param *par)
 {
 	const struct tcphdr *th;
 	struct tcphdr _tcph;
@@ -128,7 +129,8 @@ static int tcp_mt_check(const struct xt_mtchk_param *par)
 	return (tcpinfo->invflags & ~XT_TCP_INV_MASK) ? -EINVAL : 0;
 }
 
-static bool udp_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+static bool udp_mt(const struct sk_buff *skb,
+		   const struct xt_action_param *par)
 {
 	const struct udphdr *uh;
 	struct udphdr _udph;
diff --git a/net/netfilter/xt_time.c b/net/netfilter/xt_time.c
index d8556fd..ffdb8fa 100644
--- a/net/netfilter/xt_time.c
+++ b/net/netfilter/xt_time.c
@@ -152,7 +152,7 @@ static void localtime_3(struct xtm *r, time_t time)
 }
 
 static bool
-time_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+time_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_time_info *info = par->matchinfo;
 	unsigned int packet_time;
diff --git a/net/netfilter/xt_u32.c b/net/netfilter/xt_u32.c
index d7c05f0..f62797b 100644
--- a/net/netfilter/xt_u32.c
+++ b/net/netfilter/xt_u32.c
@@ -86,7 +86,8 @@ static bool u32_match_it(const struct xt_u32 *data,
 	return true;
 }
 
-static bool u32_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+static bool u32_mt(const struct sk_buff *skb,
+		   const struct xt_action_param *par)
 {
 	const struct xt_u32 *data = par->matchinfo;
 	bool ret;
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index 03f80a0..1f95954 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -199,7 +199,7 @@ static int tcf_ipt(struct sk_buff *skb, struct tc_action *a,
 {
 	int ret = 0, result = 0;
 	struct tcf_ipt *ipt = a->priv;
-	struct xt_target_param par;
+	struct xt_action_param par;
 
 	if (skb_cloned(skb)) {
 		if (pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
-- 
1.7.0.4

