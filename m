From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH nf-next] netfilter: Line layout whitespace fixes
Date: Thu, 24 Sep 2015 11:10:06 +0100
Message-ID: <1443089406-8996-1-git-send-email-ipm@chirality.org.uk>
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	Ian Morris <ipm@chirality.org.uk>
To: netfilter-devel@vger.kernel.org, coreteam@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-gw.chirality.org.uk ([88.97.209.22]:42271 "EHLO
	cedar.ipmorris.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752259AbbIXKaj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 06:30:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes various whitespace issues detected by checkpatch (e.g. adding spaces between operations, replacing spaces with tabs, etc)

No changes detected by objdiff.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
---
 net/bridge/netfilter/ebt_among.c               |   2 +-
 net/ipv4/netfilter/arp_tables.c                |  12 +--
 net/ipv4/netfilter/arptable_filter.c           |   2 +-
 net/ipv4/netfilter/ip_tables.c                 |  20 ++--
 net/ipv4/netfilter/ipt_CLUSTERIP.c             |   8 +-
 net/ipv4/netfilter/ipt_ECN.c                   |   2 +-
 net/ipv4/netfilter/ipt_SYNPROXY.c              |   2 +-
 net/ipv4/netfilter/ipt_ah.c                    |   2 +-
 net/ipv4/netfilter/iptable_security.c          |   2 +-
 net/ipv4/netfilter/nf_nat_pptp.c               |   2 +-
 net/ipv4/netfilter/nf_nat_snmp_basic.c         |   4 +-
 net/ipv6/netfilter/ip6_tables.c                |  22 ++---
 net/ipv6/netfilter/ip6t_SYNPROXY.c             |   2 +-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |   4 +-
 net/ipv6/netfilter/nf_conntrack_reasm.c        |   4 +-
 net/ipv6/netfilter/nf_reject_ipv6.c            |   4 +-
 net/ipv6/netfilter/nft_chain_route_ipv6.c      |   6 +-
 net/netfilter/nf_conntrack_expect.c            |   2 +-
 net/netfilter/nf_conntrack_ftp.c               |   2 +-
 net/netfilter/nf_conntrack_h323_asn1.c         |  26 +++---
 net/netfilter/nf_conntrack_h323_main.c         | 122 ++++++++++++-------------
 net/netfilter/nf_conntrack_netlink.c           |  20 ++--
 net/netfilter/nf_conntrack_pptp.c              |  10 +-
 net/netfilter/nf_conntrack_proto_dccp.c        |  12 +--
 net/netfilter/nf_conntrack_proto_generic.c     |   2 +-
 net/netfilter/nf_conntrack_proto_gre.c         |   2 +-
 net/netfilter/nf_conntrack_proto_sctp.c        |  46 +++++-----
 net/netfilter/nf_conntrack_proto_tcp.c         |  64 ++++++-------
 net/netfilter/nf_conntrack_proto_udp.c         |   4 +-
 net/netfilter/nf_conntrack_proto_udplite.c     |   2 +-
 net/netfilter/nf_conntrack_standalone.c        |   4 +-
 net/netfilter/nf_queue.c                       |   2 +-
 net/netfilter/nf_tables_api.c                  |  32 +++----
 net/netfilter/nf_tables_core.c                 |   2 +-
 net/netfilter/nf_tables_netdev.c               |   2 +-
 net/netfilter/nfnetlink_acct.c                 |  16 ++--
 net/netfilter/nfnetlink_cthelper.c             |  10 +-
 net/netfilter/nfnetlink_cttimeout.c            |  30 +++---
 net/netfilter/nfnetlink_log.c                  |  14 +--
 net/netfilter/nfnetlink_queue_core.c           |  26 +++---
 net/netfilter/nft_compat.c                     |   2 +-
 net/netfilter/nft_counter.c                    |   2 +-
 net/netfilter/nft_masq.c                       |   2 +-
 net/netfilter/x_tables.c                       |  19 ++--
 net/netfilter/xt_CLASSIFY.c                    |   2 +-
 net/netfilter/xt_CT.c                          |   4 +-
 net/netfilter/xt_NETMAP.c                      |  12 +--
 net/netfilter/xt_REDIRECT.c                    |   4 +-
 net/netfilter/xt_cluster.c                     |   6 +-
 net/netfilter/xt_connlimit.c                   |   4 +-
 net/netfilter/xt_connmark.c                    |   4 +-
 net/netfilter/xt_conntrack.c                   |  16 ++--
 net/netfilter/xt_dccp.c                        |   8 +-
 net/netfilter/xt_ecn.c                         |   2 +-
 net/netfilter/xt_hashlimit.c                   |   6 +-
 net/netfilter/xt_iprange.c                     |  16 ++--
 net/netfilter/xt_mac.c                         |   2 +-
 net/netfilter/xt_multiport.c                   |   9 +-
 net/netfilter/xt_osf.c                         |  10 +-
 net/netfilter/xt_owner.c                       |   2 +-
 net/netfilter/xt_policy.c                      |   6 +-
 net/netfilter/xt_recent.c                      |   2 +-
 net/netfilter/xt_tcpudp.c                      |   2 +-
 net/netfilter/xt_time.c                        |   4 +-
 64 files changed, 348 insertions(+), 350 deletions(-)

diff --git a/net/bridge/netfilter/ebt_among.c b/net/bridge/netfilter/ebt_among.c
index 9024283..60fa548 100644
--- a/net/bridge/netfilter/ebt_among.c
+++ b/net/bridge/netfilter/ebt_among.c
@@ -20,7 +20,7 @@ static bool ebt_mac_wormhash_contains(const struct ebt_mac_wormhash *wh,
 {
 	/* You may be puzzled as to how this code works.
 	 * Some tricks were used, refer to
-	 * 	include/linux/netfilter_bridge/ebt_among.h
+	 *	include/linux/netfilter_bridge/ebt_among.h
 	 * as there you can find a solution of this mystery.
 	 */
 	const struct ebt_mac_wormhash_tuple *p;
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 8f87fc3..efb9e81 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -186,7 +186,7 @@ static inline int arp_packet_match(const struct arphdr *arphdr,
 	if (FWINV(ret != 0, ARPT_INV_VIA_IN)) {
 		dprintf("VIA in mismatch (%s vs %s).%s\n",
 			indev, arpinfo->iniface,
-			arpinfo->invflags&ARPT_INV_VIA_IN ?" (INV)":"");
+			arpinfo->invflags & ARPT_INV_VIA_IN ? " (INV)" : "");
 		return 0;
 	}
 
@@ -195,7 +195,7 @@ static inline int arp_packet_match(const struct arphdr *arphdr,
 	if (FWINV(ret != 0, ARPT_INV_VIA_OUT)) {
 		dprintf("VIA out mismatch (%s vs %s).%s\n",
 			outdev, arpinfo->outiface,
-			arpinfo->invflags&ARPT_INV_VIA_OUT ?" (INV)":"");
+			arpinfo->invflags & ARPT_INV_VIA_OUT ? " (INV)" : "");
 		return 0;
 	}
 
@@ -467,7 +467,7 @@ static int mark_source_chains(const struct xt_table_info *newinfo,
 				pos = newpos;
 			}
 		}
-		next:
+next:
 		duprintf("Finished chain %u\n", hook);
 	}
 	return 1;
@@ -631,7 +631,7 @@ static inline void cleanup_entry(struct arpt_entry *e)
  * newinfo).
  */
 static int translate_table(struct xt_table_info *newinfo, void *entry0,
-                           const struct arpt_replace *repl)
+			   const struct arpt_replace *repl)
 {
 	struct arpt_entry *iter;
 	unsigned int i;
@@ -891,7 +891,7 @@ static int compat_table_info(const struct xt_table_info *info,
 #endif
 
 static int get_info(struct net *net, void __user *user,
-                    const int *len, int compat)
+		    const int *len, int compat)
 {
 	char name[XT_TABLE_MAXNAMELEN];
 	struct xt_table *t;
@@ -1068,7 +1068,7 @@ static int __do_replace(struct net *net, const char *name,
 }
 
 static int do_replace(struct net *net, const void __user *user,
-                      unsigned int len)
+		      unsigned int len)
 {
 	int ret;
 	struct arpt_replace tmp;
diff --git a/net/ipv4/netfilter/arptable_filter.c b/net/ipv4/netfilter/arptable_filter.c
index 93876d0..96da7f0 100644
--- a/net/ipv4/netfilter/arptable_filter.c
+++ b/net/ipv4/netfilter/arptable_filter.c
@@ -41,7 +41,7 @@ static struct nf_hook_ops *arpfilter_ops __read_mostly;
 static int __net_init arptable_filter_net_init(struct net *net)
 {
 	struct arpt_replace *repl;
-	
+
 	repl = arpt_alloc_initial_table(&packet_filter);
 	if (repl == NULL)
 		return -ENOMEM;
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index b0a86e7..3089d30 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -102,7 +102,7 @@ ip_packet_match(const struct iphdr *ip,
 	if (FWINV(ret != 0, IPT_INV_VIA_IN)) {
 		dprintf("VIA in mismatch (%s vs %s).%s\n",
 			indev, ipinfo->iniface,
-			ipinfo->invflags&IPT_INV_VIA_IN ?" (INV)":"");
+			ipinfo->invflags & IPT_INV_VIA_IN ? " (INV)" : "");
 		return false;
 	}
 
@@ -111,7 +111,7 @@ ip_packet_match(const struct iphdr *ip,
 	if (FWINV(ret != 0, IPT_INV_VIA_OUT)) {
 		dprintf("VIA out mismatch (%s vs %s).%s\n",
 			outdev, ipinfo->outiface,
-			ipinfo->invflags&IPT_INV_VIA_OUT ?" (INV)":"");
+			ipinfo->invflags & IPT_INV_VIA_OUT ? " (INV)" : "");
 		return false;
 	}
 
@@ -120,7 +120,7 @@ ip_packet_match(const struct iphdr *ip,
 	    FWINV(ip->protocol != ipinfo->proto, IPT_INV_PROTO)) {
 		dprintf("Packet protocol %hi does not match %hi.%s\n",
 			ip->protocol, ipinfo->proto,
-			ipinfo->invflags&IPT_INV_PROTO ? " (INV)":"");
+			ipinfo->invflags & IPT_INV_PROTO ? " (INV)" : "");
 		return false;
 	}
 
@@ -430,8 +430,8 @@ ipt_do_table(struct sk_buff *skb,
 	} while (!acpar.hotdrop);
 	pr_debug("Exiting %s; sp at %u\n", __func__, stackidx);
 
- 	xt_write_recseq_end(addend);
- 	local_bh_enable();
+	xt_write_recseq_end(addend);
+	local_bh_enable();
 
 #ifdef DEBUG_ALLOW_ALL
 	return NF_ACCEPT;
@@ -483,7 +483,7 @@ mark_source_chains(const struct xt_table_info *newinfo,
 				unsigned int oldpos, size;
 
 				if ((strcmp(t->target.u.user.name,
-			    		    XT_STANDARD_TARGET) == 0) &&
+					    XT_STANDARD_TARGET) == 0) &&
 				    t->verdict < -NF_MAX_VERDICT - 1) {
 					duprintf("mark_source_chains: bad "
 						"negative verdict (%i)\n",
@@ -548,7 +548,7 @@ mark_source_chains(const struct xt_table_info *newinfo,
 				pos = newpos;
 			}
 		}
-		next:
+next:
 		duprintf("Finished chain %u\n", hook);
 	}
 	return 1;
@@ -803,7 +803,7 @@ cleanup_entry(struct ipt_entry *e, struct net *net)
    newinfo) */
 static int
 translate_table(struct net *net, struct xt_table_info *newinfo, void *entry0,
-                const struct ipt_replace *repl)
+		const struct ipt_replace *repl)
 {
 	struct ipt_entry *iter;
 	unsigned int i;
@@ -1077,7 +1077,7 @@ static int compat_table_info(const struct xt_table_info *info,
 #endif
 
 static int get_info(struct net *net, void __user *user,
-                    const int *len, int compat)
+		    const int *len, int compat)
 {
 	char name[XT_TABLE_MAXNAMELEN];
 	struct xt_table *t;
@@ -1303,7 +1303,7 @@ do_replace(struct net *net, const void __user *user, unsigned int len)
 
 static int
 do_add_counters(struct net *net, const void __user *user,
-                unsigned int len, int compat)
+		unsigned int len, int compat)
 {
 	unsigned int i;
 	struct xt_counters_info tmp;
diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 45cb16a..26cd955 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -492,14 +492,14 @@ static void arp_print(struct arp_payload *payload)
 {
 #define HBUFFERLEN 30
 	char hbuffer[HBUFFERLEN];
-	int j,k;
+	int j, k;
 
-	for (k=0, j=0; k < HBUFFERLEN-3 && j < ETH_ALEN; j++) {
+	for (k = 0, j = 0; k < HBUFFERLEN - 3 && j < ETH_ALEN; j++) {
 		hbuffer[k++] = hex_asc_hi(payload->src_hw[j]);
 		hbuffer[k++] = hex_asc_lo(payload->src_hw[j]);
-		hbuffer[k++]=':';
+		hbuffer[k++] = ':';
 	}
-	hbuffer[--k]='\0';
+	hbuffer[--k] = '\0';
 
 	pr_debug("src %pI4@%s, dst %pI4\n",
 		 &payload->src_ip, hbuffer, &payload->dst_ip);
diff --git a/net/ipv4/netfilter/ipt_ECN.c b/net/ipv4/netfilter/ipt_ECN.c
index 2707652..6592708 100644
--- a/net/ipv4/netfilter/ipt_ECN.c
+++ b/net/ipv4/netfilter/ipt_ECN.c
@@ -24,7 +24,7 @@ MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
 MODULE_DESCRIPTION("Xtables: Explicit Congestion Notification (ECN) flag modification");
 
 /* set ECT codepoint from IP header.
- * 	return false if there was an error. */
+ *	return false if there was an error. */
 static inline bool
 set_ect_ip(struct sk_buff *skb, const struct ipt_ECN_info *einfo)
 {
diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
index 95ea633e..f02dfbb 100644
--- a/net/ipv4/netfilter/ipt_SYNPROXY.c
+++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
@@ -227,7 +227,7 @@ synproxy_send_client_ack(const struct synproxy_net *snet,
 	synproxy_build_options(nth, opts);
 
 	synproxy_send_tcp(skb, nskb, skb->nfct, IP_CT_ESTABLISHED_REPLY,
-	                  niph, nth, tcp_hdr_size);
+			  niph, nth, tcp_hdr_size);
 }
 
 static bool
diff --git a/net/ipv4/netfilter/ipt_ah.c b/net/ipv4/netfilter/ipt_ah.c
index 14a2aa8..a787d07 100644
--- a/net/ipv4/netfilter/ipt_ah.c
+++ b/net/ipv4/netfilter/ipt_ah.c
@@ -25,7 +25,7 @@ spi_match(u_int32_t min, u_int32_t max, u_int32_t spi, bool invert)
 	bool r;
 	pr_debug("spi_match:%c 0x%x <= 0x%x <= 0x%x\n",
 		 invert ? '!' : ' ', min, spi, max);
-	r=(spi >= min && spi <= max) ^ invert;
+	r = (spi >= min && spi <= max) ^ invert;
 	pr_debug(" result %s\n", r ? "PASS" : "FAILED");
 	return r;
 }
diff --git a/net/ipv4/netfilter/iptable_security.c b/net/ipv4/netfilter/iptable_security.c
index 4bce398..a92f28e 100644
--- a/net/ipv4/netfilter/iptable_security.c
+++ b/net/ipv4/netfilter/iptable_security.c
@@ -83,7 +83,7 @@ static int __init iptable_security_init(void)
 	int ret;
 
 	ret = register_pernet_subsys(&iptable_security_net_ops);
-        if (ret < 0)
+	if (ret < 0)
 		return ret;
 
 	sectbl_ops = xt_hook_link(&security_table, iptable_security_hook);
diff --git a/net/ipv4/netfilter/nf_nat_pptp.c b/net/ipv4/netfilter/nf_nat_pptp.c
index 657d230..d5726f7 100644
--- a/net/ipv4/netfilter/nf_nat_pptp.c
+++ b/net/ipv4/netfilter/nf_nat_pptp.c
@@ -16,7 +16,7 @@
  * (C) 2006-2012 Patrick McHardy <kaber@trash.net>
  *
  * TODO: - NAT to a unique tuple, not to TCP source port
- * 	   (needs netfilter tuple reservation)
+ *	   (needs netfilter tuple reservation)
  */
 
 #include <linux/module.h>
diff --git a/net/ipv4/netfilter/nf_nat_snmp_basic.c b/net/ipv4/netfilter/nf_nat_snmp_basic.c
index 7c67667..89be5c5 100644
--- a/net/ipv4/netfilter/nf_nat_snmp_basic.c
+++ b/net/ipv4/netfilter/nf_nat_snmp_basic.c
@@ -891,7 +891,7 @@ static void fast_csum(__sum16 *csum,
 
 /*
  * Mangle IP address.
- * 	- begin points to the start of the snmp messgae
+ *	- begin points to the start of the snmp messgae
  *      - addr points to the start of the address
  */
 static inline void mangle_address(unsigned char *begin,
@@ -1156,7 +1156,7 @@ static int snmp_parse_mangle(unsigned char *msg,
 		}
 
 		if (obj->type == SNMP_IPADDR)
-			mangle_address(ctx.begin, ctx.pointer - 4 , map, check);
+			mangle_address(ctx.begin, ctx.pointer - 4, map, check);
 
 		kfree(obj->id);
 		kfree(obj);
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 0771991..d52659e 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -117,7 +117,7 @@ ip6_packet_match(const struct sk_buff *skb,
 	if (FWINV(ret != 0, IP6T_INV_VIA_IN)) {
 		dprintf("VIA in mismatch (%s vs %s).%s\n",
 			indev, ip6info->iniface,
-			ip6info->invflags&IP6T_INV_VIA_IN ?" (INV)":"");
+			ip6info->invflags & IP6T_INV_VIA_IN ? " (INV)" : "");
 		return false;
 	}
 
@@ -126,14 +126,14 @@ ip6_packet_match(const struct sk_buff *skb,
 	if (FWINV(ret != 0, IP6T_INV_VIA_OUT)) {
 		dprintf("VIA out mismatch (%s vs %s).%s\n",
 			outdev, ip6info->outiface,
-			ip6info->invflags&IP6T_INV_VIA_OUT ?" (INV)":"");
+			ip6info->invflags & IP6T_INV_VIA_OUT ? " (INV)" : "");
 		return false;
 	}
 
 /* ... might want to do something with class and flowlabel here ... */
 
 	/* look for the desired protocol header */
-	if((ip6info->flags & IP6T_F_PROTO)) {
+	if (ip6info->flags & IP6T_F_PROTO) {
 		int protohdr;
 		unsigned short _frag_off;
 
@@ -147,11 +147,11 @@ ip6_packet_match(const struct sk_buff *skb,
 
 		dprintf("Packet protocol %hi ?= %s%hi.\n",
 				protohdr,
-				ip6info->invflags & IP6T_INV_PROTO ? "!":"",
+				ip6info->invflags & IP6T_INV_PROTO ? "!" : "",
 				ip6info->proto);
 
 		if (ip6info->proto == protohdr) {
-			if(ip6info->invflags & IP6T_INV_PROTO) {
+			if (ip6info->invflags & IP6T_INV_PROTO) {
 				return false;
 			}
 			return true;
@@ -442,8 +442,8 @@ ip6t_do_table(struct sk_buff *skb,
 			break;
 	} while (!acpar.hotdrop);
 
- 	xt_write_recseq_end(addend);
- 	local_bh_enable();
+	xt_write_recseq_end(addend);
+	local_bh_enable();
 
 #ifdef DEBUG_ALLOW_ALL
 	return NF_ACCEPT;
@@ -560,7 +560,7 @@ mark_source_chains(const struct xt_table_info *newinfo,
 				pos = newpos;
 			}
 		}
-		next:
+next:
 		duprintf("Finished chain %u\n", hook);
 	}
 	return 1;
@@ -815,7 +815,7 @@ static void cleanup_entry(struct ip6t_entry *e, struct net *net)
    newinfo) */
 static int
 translate_table(struct net *net, struct xt_table_info *newinfo, void *entry0,
-                const struct ip6t_replace *repl)
+		const struct ip6t_replace *repl)
 {
 	struct ip6t_entry *iter;
 	unsigned int i;
@@ -1089,7 +1089,7 @@ static int compat_table_info(const struct xt_table_info *info,
 #endif
 
 static int get_info(struct net *net, void __user *user,
-                    const int *len, int compat)
+		    const int *len, int compat)
 {
 	char name[XT_TABLE_MAXNAMELEN];
 	struct xt_table *t;
@@ -1151,7 +1151,7 @@ static int get_info(struct net *net, void __user *user,
 
 static int
 get_entries(struct net *net, struct ip6t_get_entries __user *uptr,
-            const int *len)
+	    const int *len)
 {
 	int ret;
 	struct ip6t_get_entries get;
diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
index 1e4bf99..de02eae 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -244,7 +244,7 @@ synproxy_send_client_ack(const struct synproxy_net *snet,
 	synproxy_build_options(nth, opts);
 
 	synproxy_send_tcp(snet, skb, nskb, skb->nfct, IP_CT_ESTABLISHED_REPLY,
-	                  niph, nth, tcp_hdr_size);
+			  niph, nth, tcp_hdr_size);
 }
 
 static bool
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index 0e6fae1..171daf0 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -56,12 +56,12 @@ static const u_int8_t invmap[] = {
 	[ICMPV6_ECHO_REQUEST - 128]	= ICMPV6_ECHO_REPLY + 1,
 	[ICMPV6_ECHO_REPLY - 128]	= ICMPV6_ECHO_REQUEST + 1,
 	[ICMPV6_NI_QUERY - 128]		= ICMPV6_NI_REPLY + 1,
-	[ICMPV6_NI_REPLY - 128]		= ICMPV6_NI_QUERY +1
+	[ICMPV6_NI_REPLY - 128]		= ICMPV6_NI_QUERY + 1
 };
 
 static const u_int8_t noct_valid_new[] = {
 	[ICMPV6_MGM_QUERY - 130] = 1,
-	[ICMPV6_MGM_REPORT -130] = 1,
+	[ICMPV6_MGM_REPORT - 130] = 1,
 	[ICMPV6_MGM_REDUCTION - 130] = 1,
 	[NDISC_ROUTER_SOLICITATION - 130] = 1,
 	[NDISC_ROUTER_ADVERTISEMENT - 130] = 1,
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 6d02498..1e681c0 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -59,7 +59,7 @@ struct nf_ct_frag6_skb_cb
 	struct sk_buff		*orig;
 };
 
-#define NFCT_FRAG6_CB(skb)	((struct nf_ct_frag6_skb_cb*)((skb)->cb))
+#define NFCT_FRAG6_CB(skb)	((struct nf_ct_frag6_skb_cb *)((skb)->cb))
 
 static struct inet_frags nf_frags;
 
@@ -445,7 +445,7 @@ nf_ct_frag6_reasm(struct frag_queue *fq, struct net_device *dev)
 	skb_reset_transport_header(head);
 	skb_push(head, head->data - skb_network_header(head));
 
-	for (fp=head->next; fp; fp = fp->next) {
+	for (fp = head->next; fp; fp = fp->next) {
 		head->data_len += fp->len;
 		head->len += fp->len;
 		if (head->ip_summed != fp->ip_summed)
diff --git a/net/ipv6/netfilter/nf_reject_ipv6.c b/net/ipv6/netfilter/nf_reject_ipv6.c
index 94b4c6d..5629db8 100644
--- a/net/ipv6/netfilter/nf_reject_ipv6.c
+++ b/net/ipv6/netfilter/nf_reject_ipv6.c
@@ -26,7 +26,7 @@ const struct tcphdr *nf_reject_ip6_tcphdr_get(struct sk_buff *oldskb,
 	int tcphoff;
 
 	proto = oip6h->nexthdr;
-	tcphoff = ipv6_skip_exthdr(oldskb, ((u8*)(oip6h+1) - oldskb->data),
+	tcphoff = ipv6_skip_exthdr(oldskb, ((u8 *)(oip6h + 1) - oldskb->data),
 				   &proto, &frag_off);
 
 	if ((tcphoff < 0) || (tcphoff > oldskb->len)) {
@@ -224,7 +224,7 @@ static bool reject6_csum_ok(struct sk_buff *skb, int hook)
 		return true;
 
 	proto = ip6h->nexthdr;
-	thoff = ipv6_skip_exthdr(skb, ((u8*)(ip6h+1) - skb->data), &proto, &fo);
+	thoff = ipv6_skip_exthdr(skb, ((u8 *)(ip6h + 1) - skb->data), &proto, &fo);
 
 	if (thoff < 0 || thoff >= skb->len || (fo & htons(~0x7)) != 0)
 		return false;
diff --git a/net/ipv6/netfilter/nft_chain_route_ipv6.c b/net/ipv6/netfilter/nft_chain_route_ipv6.c
index 0dafdaa..2ed4048 100644
--- a/net/ipv6/netfilter/nft_chain_route_ipv6.c
+++ b/net/ipv6/netfilter/nft_chain_route_ipv6.c
@@ -61,11 +61,11 @@ static const struct nf_chain_type nft_chain_route_ipv6 = {
 	.name		= "route",
 	.type		= NFT_CHAIN_T_ROUTE,
 	.family		= NFPROTO_IPV6,
-        .owner		= THIS_MODULE,
+	.owner		= THIS_MODULE,
 	.hook_mask	= (1 << NF_INET_LOCAL_OUT),
 	.hooks		= {
-                [NF_INET_LOCAL_OUT]	= nf_route_table_hook,
-        },
+		[NF_INET_LOCAL_OUT]	= nf_route_table_hook,
+	},
 };
 
 static int __init nft_chain_route_init(void)
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index acf5c7b..106e33c 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -217,7 +217,7 @@ static inline int expect_clash(const struct nf_conntrack_expect *a,
 
 	intersect_mask.src.u.all = a->mask.src.u.all & b->mask.src.u.all;
 
-	for (count = 0; count < NF_CT_TUPLE_L3SIZE; count++){
+	for (count = 0; count < NF_CT_TUPLE_L3SIZE; count++) {
 		intersect_mask.src.u3.all[count] =
 			a->mask.src.u3.all[count] & b->mask.src.u3.all[count];
 	}
diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntrack_ftp.c
index b666959..b89582c 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -472,7 +472,7 @@ skip_nl_seq:
 		   However, it is necessary for accurate tracking in
 		   this case. */
 		nf_ct_helper_log(skb, ct, "partial matching of `%s'",
-			         search[dir][i].pattern);
+				 search[dir][i].pattern);
 		ret = NF_DROP;
 		goto out;
 	} else if (found == 0) { /* No match */
diff --git a/net/netfilter/nf_conntrack_h323_asn1.c b/net/netfilter/nf_conntrack_h323_asn1.c
index bcd5ed6..d08c548 100644
--- a/net/netfilter/nf_conntrack_h323_asn1.c
+++ b/net/netfilter/nf_conntrack_h323_asn1.c
@@ -1,6 +1,6 @@
 /****************************************************************************
  * ip_conntrack_helper_h323_asn1.c - BER and PER decoding library for H.323
- * 			      	     conntrack/NAT module.
+ *				     conntrack/NAT module.
  *
  * Copyright (c) 2006 by Jing Min Zhao <zhaojingmin@users.sourceforge.net>
  *
@@ -265,7 +265,7 @@ static unsigned int get_uint(bitstr_t *bs, int b)
 
 /****************************************************************************/
 static int decode_nul(bitstr_t *bs, const struct field_t *f,
-                      char *base, int level)
+		      char *base, int level)
 {
 	PRINT("%*.s%s\n", level * TAB_SIZE, " ", f->name);
 
@@ -274,7 +274,7 @@ static int decode_nul(bitstr_t *bs, const struct field_t *f,
 
 /****************************************************************************/
 static int decode_bool(bitstr_t *bs, const struct field_t *f,
-                       char *base, int level)
+		       char *base, int level)
 {
 	PRINT("%*.s%s\n", level * TAB_SIZE, " ", f->name);
 
@@ -286,7 +286,7 @@ static int decode_bool(bitstr_t *bs, const struct field_t *f,
 
 /****************************************************************************/
 static int decode_oid(bitstr_t *bs, const struct field_t *f,
-                      char *base, int level)
+		      char *base, int level)
 {
 	int len;
 
@@ -303,7 +303,7 @@ static int decode_oid(bitstr_t *bs, const struct field_t *f,
 
 /****************************************************************************/
 static int decode_int(bitstr_t *bs, const struct field_t *f,
-                      char *base, int level)
+		      char *base, int level)
 {
 	unsigned int len;
 
@@ -347,7 +347,7 @@ static int decode_int(bitstr_t *bs, const struct field_t *f,
 
 /****************************************************************************/
 static int decode_enum(bitstr_t *bs, const struct field_t *f,
-                       char *base, int level)
+		       char *base, int level)
 {
 	PRINT("%*.s%s\n", level * TAB_SIZE, " ", f->name);
 
@@ -363,7 +363,7 @@ static int decode_enum(bitstr_t *bs, const struct field_t *f,
 
 /****************************************************************************/
 static int decode_bitstr(bitstr_t *bs, const struct field_t *f,
-                         char *base, int level)
+			 char *base, int level)
 {
 	unsigned int len;
 
@@ -397,7 +397,7 @@ static int decode_bitstr(bitstr_t *bs, const struct field_t *f,
 
 /****************************************************************************/
 static int decode_numstr(bitstr_t *bs, const struct field_t *f,
-                         char *base, int level)
+			 char *base, int level)
 {
 	unsigned int len;
 
@@ -415,7 +415,7 @@ static int decode_numstr(bitstr_t *bs, const struct field_t *f,
 
 /****************************************************************************/
 static int decode_octstr(bitstr_t *bs, const struct field_t *f,
-                         char *base, int level)
+			 char *base, int level)
 {
 	unsigned int len;
 
@@ -464,7 +464,7 @@ static int decode_octstr(bitstr_t *bs, const struct field_t *f,
 
 /****************************************************************************/
 static int decode_bmpstr(bitstr_t *bs, const struct field_t *f,
-                         char *base, int level)
+			 char *base, int level)
 {
 	unsigned int len;
 
@@ -490,7 +490,7 @@ static int decode_bmpstr(bitstr_t *bs, const struct field_t *f,
 
 /****************************************************************************/
 static int decode_seq(bitstr_t *bs, const struct field_t *f,
-                      char *base, int level)
+		      char *base, int level)
 {
 	unsigned int ext, bmp, i, opt, len = 0, bmp2, bmp2_len;
 	int err;
@@ -607,7 +607,7 @@ static int decode_seq(bitstr_t *bs, const struct field_t *f,
 
 /****************************************************************************/
 static int decode_seqof(bitstr_t *bs, const struct field_t *f,
-                        char *base, int level)
+			char *base, int level)
 {
 	unsigned int count, effective_count = 0, i, len = 0;
 	int err;
@@ -697,7 +697,7 @@ static int decode_seqof(bitstr_t *bs, const struct field_t *f,
 
 /****************************************************************************/
 static int decode_choice(bitstr_t *bs, const struct field_t *f,
-                         char *base, int level)
+			 char *base, int level)
 {
 	unsigned int type, ext, len = 0;
 	int err;
diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index 9511af0..d5773dd 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -50,63 +50,63 @@ MODULE_PARM_DESC(callforward_filter, "only create call forwarding expectations "
 				     "(determined by routing information)");
 
 /* Hooks for NAT */
-int (*set_h245_addr_hook) (struct sk_buff *skb, unsigned int protoff,
-			   unsigned char **data, int dataoff,
-			   H245_TransportAddress *taddr,
-			   union nf_inet_addr *addr, __be16 port)
-			   __read_mostly;
-int (*set_h225_addr_hook) (struct sk_buff *skb, unsigned int protoff,
-			   unsigned char **data, int dataoff,
-			   TransportAddress *taddr,
-			   union nf_inet_addr *addr, __be16 port)
-			   __read_mostly;
-int (*set_sig_addr_hook) (struct sk_buff *skb,
-			  struct nf_conn *ct,
-			  enum ip_conntrack_info ctinfo,
-			  unsigned int protoff, unsigned char **data,
-			  TransportAddress *taddr, int count) __read_mostly;
-int (*set_ras_addr_hook) (struct sk_buff *skb,
-			  struct nf_conn *ct,
-			  enum ip_conntrack_info ctinfo,
-			  unsigned int protoff, unsigned char **data,
-			  TransportAddress *taddr, int count) __read_mostly;
-int (*nat_rtp_rtcp_hook) (struct sk_buff *skb,
-			  struct nf_conn *ct,
-			  enum ip_conntrack_info ctinfo,
-			  unsigned int protoff,
+int (*set_h245_addr_hook)(struct sk_buff *skb, unsigned int protoff,
 			  unsigned char **data, int dataoff,
 			  H245_TransportAddress *taddr,
-			  __be16 port, __be16 rtp_port,
-			  struct nf_conntrack_expect *rtp_exp,
-			  struct nf_conntrack_expect *rtcp_exp) __read_mostly;
-int (*nat_t120_hook) (struct sk_buff *skb,
-		      struct nf_conn *ct,
-		      enum ip_conntrack_info ctinfo,
-		      unsigned int protoff,
-		      unsigned char **data, int dataoff,
-		      H245_TransportAddress *taddr, __be16 port,
-		      struct nf_conntrack_expect *exp) __read_mostly;
-int (*nat_h245_hook) (struct sk_buff *skb,
-		      struct nf_conn *ct,
-		      enum ip_conntrack_info ctinfo,
-		      unsigned int protoff,
-		      unsigned char **data, int dataoff,
-		      TransportAddress *taddr, __be16 port,
-		      struct nf_conntrack_expect *exp) __read_mostly;
-int (*nat_callforwarding_hook) (struct sk_buff *skb,
-				struct nf_conn *ct,
-				enum ip_conntrack_info ctinfo,
-				unsigned int protoff,
-				unsigned char **data, int dataoff,
-				TransportAddress *taddr, __be16 port,
-				struct nf_conntrack_expect *exp) __read_mostly;
-int (*nat_q931_hook) (struct sk_buff *skb,
-		      struct nf_conn *ct,
-		      enum ip_conntrack_info ctinfo,
-		      unsigned int protoff,
-		      unsigned char **data, TransportAddress *taddr, int idx,
-		      __be16 port, struct nf_conntrack_expect *exp)
-		      __read_mostly;
+			  union nf_inet_addr *addr, __be16 port)
+			  __read_mostly;
+int (*set_h225_addr_hook)(struct sk_buff *skb, unsigned int protoff,
+			  unsigned char **data, int dataoff,
+			  TransportAddress *taddr,
+			  union nf_inet_addr *addr, __be16 port)
+			  __read_mostly;
+int (*set_sig_addr_hook)(struct sk_buff *skb,
+			 struct nf_conn *ct,
+			 enum ip_conntrack_info ctinfo,
+			 unsigned int protoff, unsigned char **data,
+			 TransportAddress *taddr, int count) __read_mostly;
+int (*set_ras_addr_hook)(struct sk_buff *skb,
+			 struct nf_conn *ct,
+			 enum ip_conntrack_info ctinfo,
+			 unsigned int protoff, unsigned char **data,
+			 TransportAddress *taddr, int count) __read_mostly;
+int (*nat_rtp_rtcp_hook)(struct sk_buff *skb,
+			 struct nf_conn *ct,
+			 enum ip_conntrack_info ctinfo,
+			 unsigned int protoff,
+			 unsigned char **data, int dataoff,
+			 H245_TransportAddress *taddr,
+			 __be16 port, __be16 rtp_port,
+			 struct nf_conntrack_expect *rtp_exp,
+			 struct nf_conntrack_expect *rtcp_exp) __read_mostly;
+int (*nat_t120_hook)(struct sk_buff *skb,
+		     struct nf_conn *ct,
+		     enum ip_conntrack_info ctinfo,
+		     unsigned int protoff,
+		     unsigned char **data, int dataoff,
+		     H245_TransportAddress *taddr, __be16 port,
+		     struct nf_conntrack_expect *exp) __read_mostly;
+int (*nat_h245_hook)(struct sk_buff *skb,
+		     struct nf_conn *ct,
+		     enum ip_conntrack_info ctinfo,
+		     unsigned int protoff,
+		     unsigned char **data, int dataoff,
+		     TransportAddress *taddr, __be16 port,
+		     struct nf_conntrack_expect *exp) __read_mostly;
+int (*nat_callforwarding_hook)(struct sk_buff *skb,
+			       struct nf_conn *ct,
+			       enum ip_conntrack_info ctinfo,
+			       unsigned int protoff,
+			       unsigned char **data, int dataoff,
+			       TransportAddress *taddr, __be16 port,
+			       struct nf_conntrack_expect *exp) __read_mostly;
+int (*nat_q931_hook)(struct sk_buff *skb,
+		     struct nf_conn *ct,
+		     enum ip_conntrack_info ctinfo,
+		     unsigned int protoff,
+		     unsigned char **data, TransportAddress *taddr, int idx,
+		     __be16 port, struct nf_conntrack_expect *exp)
+		     __read_mostly;
 
 static DEFINE_SPINLOCK(nf_h323_lock);
 static char *h323_buffer;
@@ -209,12 +209,12 @@ static int get_tpkt_data(struct sk_buff *skb, unsigned int protoff,
 	*datalen = tpktlen - 4;
 	*dataoff = tpktoff + 4;
 
-      out:
+out:
 	/* Clear TPKT length */
 	info->tpkt_len[dir] = 0;
 	return 1;
 
-      clear_out:
+clear_out:
 	info->tpkt_len[dir] = 0;
 	return 0;
 }
@@ -622,7 +622,7 @@ static int h245_help(struct sk_buff *skb, unsigned int protoff,
 	spin_unlock_bh(&nf_h323_lock);
 	return NF_ACCEPT;
 
-      drop:
+drop:
 	spin_unlock_bh(&nf_h323_lock);
 	nf_ct_helper_log(skb, ct, "cannot process H.245 message");
 	return NF_DROP;
@@ -1198,7 +1198,7 @@ static int q931_help(struct sk_buff *skb, unsigned int protoff,
 	spin_unlock_bh(&nf_h323_lock);
 	return NF_ACCEPT;
 
-      drop:
+drop:
 	spin_unlock_bh(&nf_h323_lock);
 	nf_ct_helper_log(skb, ct, "cannot process Q.931 message");
 	return NF_DROP;
@@ -1792,11 +1792,11 @@ static int ras_help(struct sk_buff *skb, unsigned int protoff,
 	if (process_ras(skb, ct, ctinfo, protoff, &data, &ras) < 0)
 		goto drop;
 
-      accept:
+accept:
 	spin_unlock_bh(&nf_h323_lock);
 	return NF_ACCEPT;
 
-      drop:
+drop:
 	spin_unlock_bh(&nf_h323_lock);
 	nf_ct_helper_log(skb, ct, "cannot process RAS message");
 	return NF_DROP;
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 94a6654..a8f711e 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -228,7 +228,7 @@ static int
 dump_counters(struct sk_buff *skb, struct nf_conn_acct *acct,
 	      enum ip_conntrack_dir dir, int type)
 {
-	enum ctattr_type attr = dir ? CTA_COUNTERS_REPLY: CTA_COUNTERS_ORIG;
+	enum ctattr_type attr = dir ? CTA_COUNTERS_REPLY : CTA_COUNTERS_ORIG;
 	struct nf_conn_counter *counter = acct->counter;
 	struct nlattr *nest_count;
 	u64 pkts, bytes;
@@ -1075,11 +1075,11 @@ ctnetlink_parse_help(const struct nlattr *attr, char **helper_name,
 static const struct nla_policy ct_nla_policy[CTA_MAX+1] = {
 	[CTA_TUPLE_ORIG]	= { .type = NLA_NESTED },
 	[CTA_TUPLE_REPLY]	= { .type = NLA_NESTED },
-	[CTA_STATUS] 		= { .type = NLA_U32 },
+	[CTA_STATUS]		= { .type = NLA_U32 },
 	[CTA_PROTOINFO]		= { .type = NLA_NESTED },
 	[CTA_HELP]		= { .type = NLA_NESTED },
 	[CTA_NAT_SRC]		= { .type = NLA_NESTED },
-	[CTA_TIMEOUT] 		= { .type = NLA_U32 },
+	[CTA_TIMEOUT]		= { .type = NLA_U32 },
 	[CTA_MARK]		= { .type = NLA_U32 },
 	[CTA_ID]		= { .type = NLA_U32 },
 	[CTA_NAT_DST]		= { .type = NLA_NESTED },
@@ -1738,12 +1738,12 @@ ctnetlink_create_conntrack(struct net *net,
 	ct->timeout.expires = jiffies + ct->timeout.expires * HZ;
 
 	rcu_read_lock();
- 	if (cda[CTA_HELP]) {
+	if (cda[CTA_HELP]) {
 		char *helpname = NULL;
 		struct nlattr *helpinfo = NULL;
 
 		err = ctnetlink_parse_help(cda[CTA_HELP], &helpname, &helpinfo);
- 		if (err < 0)
+		if (err < 0)
 			goto err2;
 
 		helper = __nf_conntrack_helper_find(helpname, nf_ct_l3num(ct),
@@ -2468,8 +2468,8 @@ ctnetlink_exp_dump_expect(struct sk_buff *skb,
 
 		if (ctnetlink_exp_dump_tuple(skb, &nat_tuple,
 						CTA_EXPECT_NAT_TUPLE) < 0)
-	                goto nla_put_failure;
-	        nla_nest_end(skb, nest_parms);
+			goto nla_put_failure;
+		nla_nest_end(skb, nest_parms);
 	}
 #endif
 	if (nla_put_be32(skb, CTA_EXPECT_TIMEOUT, htonl(timeout)) ||
@@ -3225,13 +3225,13 @@ static const struct nfnl_callback ctnl_cb[IPCTNL_MSG_MAX] = {
 	[IPCTNL_MSG_CT_NEW]		= { .call = ctnetlink_new_conntrack,
 					    .attr_count = CTA_MAX,
 					    .policy = ct_nla_policy },
-	[IPCTNL_MSG_CT_GET] 		= { .call = ctnetlink_get_conntrack,
+	[IPCTNL_MSG_CT_GET]		= { .call = ctnetlink_get_conntrack,
 					    .attr_count = CTA_MAX,
 					    .policy = ct_nla_policy },
-	[IPCTNL_MSG_CT_DELETE]  	= { .call = ctnetlink_del_conntrack,
+	[IPCTNL_MSG_CT_DELETE]		= { .call = ctnetlink_del_conntrack,
 					    .attr_count = CTA_MAX,
 					    .policy = ct_nla_policy },
-	[IPCTNL_MSG_CT_GET_CTRZERO] 	= { .call = ctnetlink_get_conntrack,
+	[IPCTNL_MSG_CT_GET_CTRZERO]	= { .call = ctnetlink_get_conntrack,
 					    .attr_count = CTA_MAX,
 					    .policy = ct_nla_policy },
 	[IPCTNL_MSG_CT_GET_STATS_CPU]	= { .call = ctnetlink_stat_ct_cpu },
diff --git a/net/netfilter/nf_conntrack_pptp.c b/net/netfilter/nf_conntrack_pptp.c
index 5588c7a..b0f8cce 100644
--- a/net/netfilter/nf_conntrack_pptp.c
+++ b/net/netfilter/nf_conntrack_pptp.c
@@ -14,10 +14,10 @@
  * (C) 2006-2012 Patrick McHardy <kaber@trash.net>
  *
  * Limitations:
- * 	 - We blindly assume that control connections are always
- * 	   established in PNS->PAC direction.  This is a violation
+ *	 - We blindly assume that control connections are always
+ *	   established in PNS->PAC direction.  This is a violation
  *	   of RFC 2637
- * 	 - We can only support one single call within each session
+ *	 - We can only support one single call within each session
  * TODO:
  *	 - testing of incoming PPTP calls
  */
@@ -96,8 +96,8 @@ EXPORT_SYMBOL(pptp_msg_name);
 #define MINS * 60 SECS
 #define HOURS * 60 MINS
 
-#define PPTP_GRE_TIMEOUT 		(10 MINS)
-#define PPTP_GRE_STREAM_TIMEOUT 	(5 HOURS)
+#define PPTP_GRE_TIMEOUT		(10 MINS)
+#define PPTP_GRE_STREAM_TIMEOUT		(5 HOURS)
 
 static void pptp_expectfn(struct nf_conn *ct,
 			 struct nf_conntrack_expect *exp)
diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index 6dd995c..2226175 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -112,7 +112,7 @@ static const char * const dccp_state_names[] = {
  * REQUEST:	Request seen, waiting for Response from server
  * RESPOND:	Response from server seen, waiting for Ack from client
  * PARTOPEN:	Ack after Response seen, waiting for packet other than Response,
- * 		Reset or Sync from server
+ *		Reset or Sync from server
  * OPEN:	Packet other than Response, Reset or Sync seen
  * CLOSEREQ:	CloseReq from server seen, expecting Close from client
  * CLOSING:	Close seen, expecting Reset
@@ -137,7 +137,7 @@ dccp_state_table[CT_DCCP_ROLE_MAX + 1][DCCP_PKT_SYNCACK + 1][CT_DCCP_MAX + 1] =
 		 * sNO -> sRQ		Regular Request
 		 * sRQ -> sRQ		Retransmitted Request or reincarnation
 		 * sRS -> sRS		Retransmitted Request (apparently Response
-		 * 			got lost after we saw it) or reincarnation
+		 *			got lost after we saw it) or reincarnation
 		 * sPO -> sIG		Ignore, conntrack might be out of sync
 		 * sOP -> sIG		Ignore, conntrack might be out of sync
 		 * sCR -> sIG		Ignore, conntrack might be out of sync
@@ -721,11 +721,11 @@ static int dccp_timeout_nlattr_to_obj(struct nlattr *tb[],
 	int i;
 
 	/* set default DCCP timeouts. */
-	for (i=0; i<CT_DCCP_MAX; i++)
+	for (i = 0; i < CT_DCCP_MAX; i++)
 		timeouts[i] = dn->dccp_timeout[i];
 
 	/* there's a 1:1 mapping between attributes and protocol states. */
-	for (i=CTA_TIMEOUT_DCCP_UNSPEC+1; i<CTA_TIMEOUT_DCCP_MAX+1; i++) {
+	for (i = CTA_TIMEOUT_DCCP_UNSPEC + 1; i < CTA_TIMEOUT_DCCP_MAX + 1; i++) {
 		if (tb[i]) {
 			timeouts[i] = ntohl(nla_get_be32(tb[i])) * HZ;
 		}
@@ -736,10 +736,10 @@ static int dccp_timeout_nlattr_to_obj(struct nlattr *tb[],
 static int
 dccp_timeout_obj_to_nlattr(struct sk_buff *skb, const void *data)
 {
-        const unsigned int *timeouts = data;
+	const unsigned int *timeouts = data;
 	int i;
 
-	for (i=CTA_TIMEOUT_DCCP_UNSPEC+1; i<CTA_TIMEOUT_DCCP_MAX+1; i++) {
+	for (i = CTA_TIMEOUT_DCCP_UNSPEC + 1; i < CTA_TIMEOUT_DCCP_MAX + 1; i++) {
 		if (nla_put_be32(skb, i, htonl(timeouts[i] / HZ)))
 			goto nla_put_failure;
 	}
diff --git a/net/netfilter/nf_conntrack_proto_generic.c b/net/netfilter/nf_conntrack_proto_generic.c
index 2281be4..45c8767 100644
--- a/net/netfilter/nf_conntrack_proto_generic.c
+++ b/net/netfilter/nf_conntrack_proto_generic.c
@@ -132,7 +132,7 @@ generic_timeout_obj_to_nlattr(struct sk_buff *skb, const void *data)
 	return 0;
 
 nla_put_failure:
-        return -ENOSPC;
+	return -ENOSPC;
 }
 
 static const struct nla_policy
diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index 7648674..65df67d 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -374,7 +374,7 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_gre4 __read_mostly = {
 	.packet		 = gre_packet,
 	.new		 = gre_new,
 	.destroy	 = gre_destroy,
-	.me 		 = THIS_MODULE,
+	.me		 = THIS_MODULE,
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.tuple_to_nlattr = nf_ct_port_tuple_to_nlattr,
 	.nlattr_tuple_size = nf_ct_port_nlattr_tuple_size,
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index 6719773..9bafd1e 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -610,11 +610,11 @@ static int sctp_timeout_nlattr_to_obj(struct nlattr *tb[],
 	int i;
 
 	/* set default SCTP timeouts. */
-	for (i=0; i<SCTP_CONNTRACK_MAX; i++)
+	for (i = 0; i < SCTP_CONNTRACK_MAX; i++)
 		timeouts[i] = sn->timeouts[i];
 
 	/* there's a 1:1 mapping between attributes and protocol states. */
-	for (i=CTA_TIMEOUT_SCTP_UNSPEC+1; i<CTA_TIMEOUT_SCTP_MAX+1; i++) {
+	for (i = CTA_TIMEOUT_SCTP_UNSPEC + 1; i < CTA_TIMEOUT_SCTP_MAX + 1; i++) {
 		if (tb[i]) {
 			timeouts[i] = ntohl(nla_get_be32(tb[i])) * HZ;
 		}
@@ -625,17 +625,17 @@ static int sctp_timeout_nlattr_to_obj(struct nlattr *tb[],
 static int
 sctp_timeout_obj_to_nlattr(struct sk_buff *skb, const void *data)
 {
-        const unsigned int *timeouts = data;
+	const unsigned int *timeouts = data;
 	int i;
 
-	for (i=CTA_TIMEOUT_SCTP_UNSPEC+1; i<CTA_TIMEOUT_SCTP_MAX+1; i++) {
-	        if (nla_put_be32(skb, i, htonl(timeouts[i] / HZ)))
+	for (i = CTA_TIMEOUT_SCTP_UNSPEC + 1; i < CTA_TIMEOUT_SCTP_MAX + 1; i++) {
+		if (nla_put_be32(skb, i, htonl(timeouts[i] / HZ)))
 			goto nla_put_failure;
 	}
-        return 0;
+	return 0;
 
 nla_put_failure:
-        return -ENOSPC;
+	return -ENOSPC;
 }
 
 static const struct nla_policy
@@ -839,16 +839,16 @@ static int sctp_init_net(struct net *net, u_int16_t proto)
 
 static struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp4 __read_mostly = {
 	.l3proto		= PF_INET,
-	.l4proto 		= IPPROTO_SCTP,
-	.name 			= "sctp",
-	.pkt_to_tuple 		= sctp_pkt_to_tuple,
-	.invert_tuple 		= sctp_invert_tuple,
-	.print_tuple 		= sctp_print_tuple,
+	.l4proto		= IPPROTO_SCTP,
+	.name			= "sctp",
+	.pkt_to_tuple		= sctp_pkt_to_tuple,
+	.invert_tuple		= sctp_invert_tuple,
+	.print_tuple		= sctp_print_tuple,
 	.print_conntrack	= sctp_print_conntrack,
-	.packet 		= sctp_packet,
+	.packet			= sctp_packet,
 	.get_timeouts		= sctp_get_timeouts,
-	.new 			= sctp_new,
-	.me 			= THIS_MODULE,
+	.new			= sctp_new,
+	.me			= THIS_MODULE,
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.to_nlattr		= sctp_to_nlattr,
 	.nlattr_size		= sctp_nlattr_size,
@@ -873,16 +873,16 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp4 __read_mostly = {
 
 static struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp6 __read_mostly = {
 	.l3proto		= PF_INET6,
-	.l4proto 		= IPPROTO_SCTP,
-	.name 			= "sctp",
-	.pkt_to_tuple 		= sctp_pkt_to_tuple,
-	.invert_tuple 		= sctp_invert_tuple,
-	.print_tuple 		= sctp_print_tuple,
+	.l4proto		= IPPROTO_SCTP,
+	.name			= "sctp",
+	.pkt_to_tuple		= sctp_pkt_to_tuple,
+	.invert_tuple		= sctp_invert_tuple,
+	.print_tuple		= sctp_print_tuple,
 	.print_conntrack	= sctp_print_conntrack,
-	.packet 		= sctp_packet,
+	.packet			= sctp_packet,
 	.get_timeouts		= sctp_get_timeouts,
-	.new 			= sctp_new,
-	.me 			= THIS_MODULE,
+	.new			= sctp_new,
+	.me			= THIS_MODULE,
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.to_nlattr		= sctp_to_nlattr,
 	.nlattr_size		= sctp_nlattr_size,
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 70383de..754c420 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -144,7 +144,7 @@ enum tcp_bit_set {
 static const u8 tcp_conntracks[2][6][TCP_CONNTRACK_MAX] = {
 	{
 /* ORIGINAL */
-/* 	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sS2	*/
+/*	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sS2	*/
 /*syn*/	   { sSS, sSS, sIG, sIG, sIG, sIG, sIG, sSS, sSS, sS2 },
 /*
  *	sNO -> sSS	Initialize a new connection
@@ -161,7 +161,7 @@ static const u8 tcp_conntracks[2][6][TCP_CONNTRACK_MAX] = {
  *	sTW -> sSS	Reopened connection (RFC 1122).
  *	sCL -> sSS
  */
-/* 	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sS2	*/
+/*	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sS2	*/
 /*synack*/ { sIV, sIV, sSR, sIV, sIV, sIV, sIV, sIV, sIV, sSR },
 /*
  *	sNO -> sIV	Too late and no reason to do anything
@@ -175,7 +175,7 @@ static const u8 tcp_conntracks[2][6][TCP_CONNTRACK_MAX] = {
  *	sTW -> sIV
  *	sCL -> sIV
  */
-/* 	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sS2	*/
+/*	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sS2	*/
 /*fin*/    { sIV, sIV, sFW, sFW, sLA, sLA, sLA, sTW, sCL, sIV },
 /*
  *	sNO -> sIV	Too late and no reason to do anything...
@@ -192,7 +192,7 @@ static const u8 tcp_conntracks[2][6][TCP_CONNTRACK_MAX] = {
  *	sTW -> sTW
  *	sCL -> sCL
  */
-/* 	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sS2	*/
+/*	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sS2	*/
 /*ack*/	   { sES, sIV, sES, sES, sCW, sCW, sTW, sTW, sCL, sIV },
 /*
  *	sNO -> sES	Assumed.
@@ -206,13 +206,13 @@ static const u8 tcp_conntracks[2][6][TCP_CONNTRACK_MAX] = {
  *	sTW -> sTW	Retransmitted last ACK. Remain in the same state.
  *	sCL -> sCL
  */
-/* 	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sS2	*/
+/*	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sS2	*/
 /*rst*/    { sIV, sCL, sCL, sCL, sCL, sCL, sCL, sCL, sCL, sCL },
 /*none*/   { sIV, sIV, sIV, sIV, sIV, sIV, sIV, sIV, sIV, sIV }
 	},
 	{
 /* REPLY */
-/* 	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sS2	*/
+/*	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sS2	*/
 /*syn*/	   { sIV, sS2, sIV, sIV, sIV, sIV, sIV, sSS, sIV, sS2 },
 /*
  *	sNO -> sIV	Never reached.
@@ -226,7 +226,7 @@ static const u8 tcp_conntracks[2][6][TCP_CONNTRACK_MAX] = {
  *	sTW -> sSS	Reopened connection, but server may have switched role
  *	sCL -> sIV
  */
-/* 	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sS2	*/
+/*	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sS2	*/
 /*synack*/ { sIV, sSR, sIG, sIG, sIG, sIG, sIG, sIG, sIG, sSR },
 /*
  *	sSS -> sSR	Standard open.
@@ -239,7 +239,7 @@ static const u8 tcp_conntracks[2][6][TCP_CONNTRACK_MAX] = {
  *	sTW -> sIG
  *	sCL -> sIG
  */
-/* 	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sS2	*/
+/*	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sS2	*/
 /*fin*/    { sIV, sIV, sFW, sFW, sLA, sLA, sLA, sTW, sCL, sIV },
 /*
  *	sSS -> sIV	Server might not send FIN in this state.
@@ -252,7 +252,7 @@ static const u8 tcp_conntracks[2][6][TCP_CONNTRACK_MAX] = {
  *	sTW -> sTW
  *	sCL -> sCL
  */
-/* 	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sS2	*/
+/*	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sS2	*/
 /*ack*/	   { sIV, sIG, sSR, sES, sCW, sCW, sTW, sTW, sCL, sIG },
 /*
  *	sSS -> sIG	Might be a half-open connection.
@@ -265,7 +265,7 @@ static const u8 tcp_conntracks[2][6][TCP_CONNTRACK_MAX] = {
  *	sTW -> sTW	Retransmitted last ACK.
  *	sCL -> sCL
  */
-/* 	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sS2	*/
+/*	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sS2	*/
 /*rst*/    { sIV, sCL, sCL, sCL, sCL, sCL, sCL, sCL, sCL, sCL },
 /*none*/   { sIV, sIV, sIV, sIV, sIV, sIV, sIV, sIV, sIV, sIV }
 	}
@@ -400,7 +400,7 @@ static void tcp_options(const struct sk_buff *skb,
 	state->flags = 0;
 
 	while (length > 0) {
-		int opcode=*ptr++;
+		int opcode = *ptr++;
 		int opsize;
 
 		switch (opcode) {
@@ -410,7 +410,7 @@ static void tcp_options(const struct sk_buff *skb,
 			length--;
 			continue;
 		default:
-			opsize=*ptr++;
+			opsize = *ptr++;
 			if (opsize < 2) /* "silly options" */
 				return;
 			if (opsize > length)
@@ -437,7 +437,7 @@ static void tcp_options(const struct sk_buff *skb,
 }
 
 static void tcp_sack(const struct sk_buff *skb, unsigned int dataoff,
-                     const struct tcphdr *tcph, __u32 *sack)
+		     const struct tcphdr *tcph, __u32 *sack)
 {
 	unsigned char buff[(15 * 4) - sizeof(struct tcphdr)];
 	const unsigned char *ptr;
@@ -857,7 +857,7 @@ static int tcp_packet(struct nf_conn *ct,
 		      | ct->proto.tcp.seen[!dir].flags)
 		     & IP_CT_TCP_FLAG_CLOSE_INIT)
 		    || (ct->proto.tcp.last_dir == dir
-		        && ct->proto.tcp.last_index == TCP_RST_SET)) {
+			&& ct->proto.tcp.last_index == TCP_RST_SET)) {
 			/* Attempt to reopen a closed/aborted connection.
 			 * Delete this connection and look up again. */
 			spin_unlock_bh(&ct->lock);
@@ -1038,7 +1038,7 @@ static int tcp_packet(struct nf_conn *ct,
 		spin_unlock_bh(&ct->lock);
 		return -NF_ACCEPT;
 	}
-     in_window:
+in_window:
 	/* From now on we have got in-window packets */
 	ct->proto.tcp.last_index = index;
 	ct->proto.tcp.last_dir = dir;
@@ -1302,7 +1302,7 @@ static int tcp_timeout_nlattr_to_obj(struct nlattr *tb[],
 	int i;
 
 	/* set default TCP timeouts. */
-	for (i=0; i<TCP_CONNTRACK_TIMEOUT_MAX; i++)
+	for (i = 0; i < TCP_CONNTRACK_TIMEOUT_MAX; i++)
 		timeouts[i] = tn->timeouts[i];
 
 	if (tb[CTA_TIMEOUT_TCP_SYN_SENT]) {
@@ -1667,15 +1667,15 @@ static struct nf_proto_net *tcp_get_net_proto(struct net *net)
 struct nf_conntrack_l4proto nf_conntrack_l4proto_tcp4 __read_mostly =
 {
 	.l3proto		= PF_INET,
-	.l4proto 		= IPPROTO_TCP,
-	.name 			= "tcp",
-	.pkt_to_tuple 		= tcp_pkt_to_tuple,
-	.invert_tuple 		= tcp_invert_tuple,
-	.print_tuple 		= tcp_print_tuple,
-	.print_conntrack 	= tcp_print_conntrack,
-	.packet 		= tcp_packet,
+	.l4proto		= IPPROTO_TCP,
+	.name			= "tcp",
+	.pkt_to_tuple		= tcp_pkt_to_tuple,
+	.invert_tuple		= tcp_invert_tuple,
+	.print_tuple		= tcp_print_tuple,
+	.print_conntrack	= tcp_print_conntrack,
+	.packet			= tcp_packet,
 	.get_timeouts		= tcp_get_timeouts,
-	.new 			= tcp_new,
+	.new			= tcp_new,
 	.error			= tcp_error,
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.to_nlattr		= tcp_to_nlattr,
@@ -1704,15 +1704,15 @@ EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_tcp4);
 struct nf_conntrack_l4proto nf_conntrack_l4proto_tcp6 __read_mostly =
 {
 	.l3proto		= PF_INET6,
-	.l4proto 		= IPPROTO_TCP,
-	.name 			= "tcp",
-	.pkt_to_tuple 		= tcp_pkt_to_tuple,
-	.invert_tuple 		= tcp_invert_tuple,
-	.print_tuple 		= tcp_print_tuple,
-	.print_conntrack 	= tcp_print_conntrack,
-	.packet 		= tcp_packet,
+	.l4proto		= IPPROTO_TCP,
+	.name			= "tcp",
+	.pkt_to_tuple		= tcp_pkt_to_tuple,
+	.invert_tuple		= tcp_invert_tuple,
+	.print_tuple		= tcp_print_tuple,
+	.print_conntrack	= tcp_print_conntrack,
+	.packet			= tcp_packet,
 	.get_timeouts		= tcp_get_timeouts,
-	.new 			= tcp_new,
+	.new			= tcp_new,
 	.error			= tcp_error,
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.to_nlattr		= tcp_to_nlattr,
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index 6957281..0e7e148 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -196,8 +196,8 @@ nla_put_failure:
 
 static const struct nla_policy
 udp_timeout_nla_policy[CTA_TIMEOUT_UDP_MAX+1] = {
-       [CTA_TIMEOUT_UDP_UNREPLIED]	= { .type = NLA_U32 },
-       [CTA_TIMEOUT_UDP_REPLIED]	= { .type = NLA_U32 },
+	[CTA_TIMEOUT_UDP_UNREPLIED]	= { .type = NLA_U32 },
+	[CTA_TIMEOUT_UDP_REPLIED]	= { .type = NLA_U32 },
 };
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 
diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
index c5903d1..093f7dc 100644
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -157,7 +157,7 @@ static int udplite_error(struct net *net, struct nf_conn *tmpl,
 	/* Checksum invalid? Ignore. */
 	if (net->ct.sysctl_checksum && hooknum == NF_INET_PRE_ROUTING &&
 	    nf_checksum_partial(skb, hooknum, dataoff, cscov, IPPROTO_UDP,
-	    			pf)) {
+				pf)) {
 		if (LOG_INVALID(net, IPPROTO_UDPLITE))
 			nf_log_packet(net, pf, 0, skb, NULL, NULL, NULL,
 				      "nf_ct_udplite: bad UDPLite checksum ");
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 1fb3cac..1f086884 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -38,8 +38,8 @@ MODULE_LICENSE("GPL");
 #ifdef CONFIG_NF_CONNTRACK_PROCFS
 void
 print_tuple(struct seq_file *s, const struct nf_conntrack_tuple *tuple,
-            const struct nf_conntrack_l3proto *l3proto,
-            const struct nf_conntrack_l4proto *l4proto)
+	    const struct nf_conntrack_l3proto *l3proto,
+	    const struct nf_conntrack_l4proto *l4proto)
 {
 	l3proto->print_tuple(s, tuple);
 	l4proto->print_tuple(s, tuple);
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index 96777f9..acc934b 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -206,7 +206,7 @@ void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
 	entry->state.thresh = INT_MIN;
 
 	if (verdict == NF_ACCEPT) {
-	next_hook:
+next_hook:
 		verdict = nf_iterate(entry->state.hook_list,
 				     skb, &entry->state, &elem);
 	}
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 4a41eb9..17e8a10 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -100,7 +100,7 @@ static void nft_ctx_init(struct nft_ctx *ctx,
 	ctx->afi	= afi;
 	ctx->table	= table;
 	ctx->chain	= chain;
-	ctx->nla   	= nla;
+	ctx->nla	= nla;
 	ctx->portid	= NETLINK_CB(skb).portid;
 	ctx->report	= nlmsg_report(nlh);
 	ctx->seq	= nlh->nlmsg_seq;
@@ -1226,7 +1226,7 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 			      const struct nlattr * const nla[])
 {
 	const struct nfgenmsg *nfmsg = nlmsg_data(nlh);
-	const struct nlattr * uninitialized_var(name);
+	const struct nlattr *uninitialized_var(name);
 	struct nft_af_info *afi;
 	struct nft_table *table;
 	struct nft_chain *chain;
@@ -1539,7 +1539,7 @@ EXPORT_SYMBOL_GPL(nft_register_expr);
  *	nft_unregister_expr - unregister nf_tables expr type
  *	@ops: expr type
  *
- * 	Unregisters the expr typefor use with nf_tables.
+ *	Unregisters the expr typefor use with nf_tables.
  */
 void nft_unregister_expr(struct nft_expr_type *type)
 {
@@ -2946,7 +2946,7 @@ int nf_tables_bind_set(const struct nft_ctx *ctx, struct nft_set *set,
 				goto bind;
 		}
 
-		iter.skip 	= 0;
+		iter.skip	= 0;
 		iter.count	= 0;
 		iter.err	= 0;
 		iter.fn		= nf_tables_bind_check_setelem;
@@ -3078,7 +3078,7 @@ static int nf_tables_fill_setelem(struct sk_buff *skb,
 
 	if (nft_set_ext_exists(ext, NFT_SET_EXT_FLAGS) &&
 	    nla_put_be32(skb, NFTA_SET_ELEM_FLAGS,
-		         htonl(*nft_set_ext_flags(ext))))
+			 htonl(*nft_set_ext_flags(ext))))
 		goto nla_put_failure;
 
 	if (nft_set_ext_exists(ext, NFT_SET_EXT_TIMEOUT) &&
@@ -4241,7 +4241,7 @@ static int nf_tables_check_loops(const struct nft_ctx *ctx,
 			    binding->chain != chain)
 				continue;
 
-			iter.skip 	= 0;
+			iter.skip	= 0;
 			iter.count	= 0;
 			iter.err	= 0;
 			iter.fn		= nf_tables_loop_check_setelem;
@@ -4306,8 +4306,8 @@ EXPORT_SYMBOL_GPL(nft_dump_register);
  *	@reg: the register number
  *	@len: the length of the data
  *
- * 	Validate that the input register is one of the general purpose
- * 	registers and that the length of the load is within the bounds.
+ *	Validate that the input register is one of the general purpose
+ *	registers and that the length of the load is within the bounds.
  */
 int nft_validate_register_load(enum nft_registers reg, unsigned int len)
 {
@@ -4326,15 +4326,15 @@ EXPORT_SYMBOL_GPL(nft_validate_register_load);
  *	nft_validate_register_store - validate an expressions' register store
  *
  *	@ctx: context of the expression performing the load
- * 	@reg: the destination register number
- * 	@data: the data to load
- * 	@type: the data type
- * 	@len: the length of the data
+ *	@reg: the destination register number
+ *	@data: the data to load
+ *	@type: the data type
+ *	@len: the length of the data
  *
- * 	Validate that a data load uses the appropriate data type for
- * 	the destination register and the length is within the bounds.
- * 	A value of NULL for the data means that its runtime gathered
- * 	data.
+ *	Validate that a data load uses the appropriate data type for
+ *	the destination register and the length is within the bounds.
+ *	A value of NULL for the data means that its runtime gathered
+ *	data.
  */
 int nft_validate_register_store(const struct nft_ctx *ctx,
 				enum nft_registers reg,
diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index 05d0b03..be22559 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -40,7 +40,7 @@ static struct nf_loginfo trace_loginfo = {
 		.log = {
 			.level = LOGLEVEL_WARNING,
 			.logflags = NF_LOG_MASK,
-	        },
+		},
 	},
 };
 
diff --git a/net/netfilter/nf_tables_netdev.c b/net/netfilter/nf_tables_netdev.c
index 2cae4d4..af31a70 100644
--- a/net/netfilter/nf_tables_netdev.c
+++ b/net/netfilter/nf_tables_netdev.c
@@ -73,7 +73,7 @@ __nft_netdev_set_pktinfo_ipv6(struct nft_pktinfo *pkt,
 
 	protohdr = ipv6_find_hdr(pkt->skb, &thoff, -1, &frag_off, NULL);
 	if (protohdr < 0)
-                return;
+		return;
 
 	pkt->tprot = protohdr;
 	pkt->xt.thoff = thoff;
diff --git a/net/netfilter/nfnetlink_acct.c b/net/netfilter/nfnetlink_acct.c
index fefbf5f..5636729 100644
--- a/net/netfilter/nfnetlink_acct.c
+++ b/net/netfilter/nfnetlink_acct.c
@@ -67,12 +67,12 @@ nfnl_acct_new(struct sock *nfnl, struct sk_buff *skb,
 		if (strncmp(nfacct->name, acct_name, NFACCT_NAME_MAX) != 0)
 			continue;
 
-                if (nlh->nlmsg_flags & NLM_F_EXCL)
+		if (nlh->nlmsg_flags & NLM_F_EXCL)
 			return -EEXIST;
 
 		matching = nfacct;
 		break;
-        }
+	}
 
 	if (matching) {
 		if (nlh->nlmsg_flags & NLM_F_REPLACE) {
@@ -287,7 +287,7 @@ nfnl_acct_get(struct sock *nfnl, struct sk_buff *skb,
 	list_for_each_entry(cur, &net->nfnl_acct_list, head) {
 		struct sk_buff *skb2;
 
-		if (strncmp(cur->name, acct_name, NFACCT_NAME_MAX)!= 0)
+		if (strncmp(cur->name, acct_name, NFACCT_NAME_MAX) != 0)
 			continue;
 
 		skb2 = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
@@ -376,10 +376,10 @@ static const struct nfnl_callback nfnl_acct_cb[NFNL_MSG_ACCT_MAX] = {
 	[NFNL_MSG_ACCT_NEW]		= { .call = nfnl_acct_new,
 					    .attr_count = NFACCT_MAX,
 					    .policy = nfnl_acct_policy },
-	[NFNL_MSG_ACCT_GET] 		= { .call = nfnl_acct_get,
+	[NFNL_MSG_ACCT_GET]		= { .call = nfnl_acct_get,
 					    .attr_count = NFACCT_MAX,
 					    .policy = nfnl_acct_policy },
-	[NFNL_MSG_ACCT_GET_CTRZERO] 	= { .call = nfnl_acct_get,
+	[NFNL_MSG_ACCT_GET_CTRZERO]	= { .call = nfnl_acct_get,
 					    .attr_count = NFACCT_MAX,
 					    .policy = nfnl_acct_policy },
 	[NFNL_MSG_ACCT_DEL]		= { .call = nfnl_acct_del,
@@ -402,7 +402,7 @@ struct nf_acct *nfnl_acct_find_get(struct net *net, const char *acct_name)
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(cur, &net->nfnl_acct_list, head) {
-		if (strncmp(cur->name, acct_name, NFACCT_NAME_MAX)!= 0)
+		if (strncmp(cur->name, acct_name, NFACCT_NAME_MAX) != 0)
 			continue;
 
 		if (!try_module_get(THIS_MODULE))
@@ -502,8 +502,8 @@ static void __net_exit nfnl_acct_net_exit(struct net *net)
 }
 
 static struct pernet_operations nfnl_acct_ops = {
-        .init   = nfnl_acct_net_init,
-        .exit   = nfnl_acct_net_exit,
+	.init   = nfnl_acct_net_init,
+	.exit   = nfnl_acct_net_exit,
 };
 
 static int __init nfnl_acct_init(void)
diff --git a/net/netfilter/nfnetlink_cthelper.c b/net/netfilter/nfnetlink_cthelper.c
index 54330fb..5bddb1a 100644
--- a/net/netfilter/nfnetlink_cthelper.c
+++ b/net/netfilter/nfnetlink_cthelper.c
@@ -182,7 +182,7 @@ nfnl_cthelper_parse_expect_policy(struct nf_conntrack_helper *helper,
 	if (expect_policy == NULL)
 		return -ENOMEM;
 
-	for (i=0; i<helper->expect_class_max; i++) {
+	for (i = 0; i < helper->expect_class_max; i++) {
 		if (!tb[NFCTH_POLICY_SET+i])
 			goto err;
 
@@ -233,7 +233,7 @@ nfnl_cthelper_create(const struct nlattr * const tb[],
 	if (tb[NFCTH_STATUS]) {
 		int status = ntohl(nla_get_be32(tb[NFCTH_STATUS]));
 
-		switch(status) {
+		switch (status) {
 		case NFCT_HELPER_STATUS_ENABLED:
 			helper->flags |= NF_CT_HELPER_F_CONFIGURED;
 			break;
@@ -274,7 +274,7 @@ nfnl_cthelper_update(const struct nlattr * const tb[],
 	if (tb[NFCTH_STATUS]) {
 		int status = ntohl(nla_get_be32(tb[NFCTH_STATUS]));
 
-		switch(status) {
+		switch (status) {
 		case NFCT_HELPER_STATUS_ENABLED:
 			helper->flags |= NF_CT_HELPER_F_CONFIGURED;
 			break;
@@ -380,7 +380,7 @@ nfnl_cthelper_dump_policy(struct sk_buff *skb,
 			 htonl(helper->expect_class_max)))
 		goto nla_put_failure;
 
-	for (i=0; i<helper->expect_class_max; i++) {
+	for (i = 0; i < helper->expect_class_max; i++) {
 		nest_parms2 = nla_nest_start(skb,
 				(NFCTH_POLICY_SET+i) | NLA_F_NESTED);
 		if (nest_parms2 == NULL)
@@ -667,7 +667,7 @@ static void __exit nfnl_cthelper_exit(void)
 
 	nfnetlink_subsys_unregister(&nfnl_cthelper_subsys);
 
-	for (i=0; i<nf_ct_helper_hsize; i++) {
+	for (i = 0; i < nf_ct_helper_hsize; i++) {
 		hlist_for_each_entry_safe(cur, tmp, &nf_ct_helper_hash[i],
 									hnode) {
 			/* skip non-userspace conntrack helpers. */
diff --git a/net/netfilter/nfnetlink_cttimeout.c b/net/netfilter/nfnetlink_cttimeout.c
index 476accd..aabcf9f 100644
--- a/net/netfilter/nfnetlink_cttimeout.c
+++ b/net/netfilter/nfnetlink_cttimeout.c
@@ -514,21 +514,21 @@ static void ctnl_timeout_put(struct ctnl_timeout *timeout)
 #endif /* CONFIG_NF_CONNTRACK_TIMEOUT */
 
 static const struct nfnl_callback cttimeout_cb[IPCTNL_MSG_TIMEOUT_MAX] = {
-	[IPCTNL_MSG_TIMEOUT_NEW]	= { .call = cttimeout_new_timeout,
-					    .attr_count = CTA_TIMEOUT_MAX,
-					    .policy = cttimeout_nla_policy },
-	[IPCTNL_MSG_TIMEOUT_GET]	= { .call = cttimeout_get_timeout,
-					    .attr_count = CTA_TIMEOUT_MAX,
-					    .policy = cttimeout_nla_policy },
-	[IPCTNL_MSG_TIMEOUT_DELETE]	= { .call = cttimeout_del_timeout,
-					    .attr_count = CTA_TIMEOUT_MAX,
-					    .policy = cttimeout_nla_policy },
-	[IPCTNL_MSG_TIMEOUT_DEFAULT_SET]= { .call = cttimeout_default_set,
-					    .attr_count = CTA_TIMEOUT_MAX,
-					    .policy = cttimeout_nla_policy },
-	[IPCTNL_MSG_TIMEOUT_DEFAULT_GET]= { .call = cttimeout_default_get,
-					    .attr_count = CTA_TIMEOUT_MAX,
-					    .policy = cttimeout_nla_policy },
+	[IPCTNL_MSG_TIMEOUT_NEW]	 = { .call = cttimeout_new_timeout,
+					     .attr_count = CTA_TIMEOUT_MAX,
+					     .policy = cttimeout_nla_policy },
+	[IPCTNL_MSG_TIMEOUT_GET]	 = { .call = cttimeout_get_timeout,
+					     .attr_count = CTA_TIMEOUT_MAX,
+					     .policy = cttimeout_nla_policy },
+	[IPCTNL_MSG_TIMEOUT_DELETE]	 = { .call = cttimeout_del_timeout,
+					     .attr_count = CTA_TIMEOUT_MAX,
+					     .policy = cttimeout_nla_policy },
+	[IPCTNL_MSG_TIMEOUT_DEFAULT_SET] = { .call = cttimeout_default_set,
+					     .attr_count = CTA_TIMEOUT_MAX,
+					     .policy = cttimeout_nla_policy },
+	[IPCTNL_MSG_TIMEOUT_DEFAULT_GET] = { .call = cttimeout_default_get,
+					     .attr_count = CTA_TIMEOUT_MAX,
+					     .policy = cttimeout_nla_policy },
 };
 
 static const struct nfnetlink_subsystem cttimeout_subsys = {
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 4670821..1154af3 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -45,8 +45,8 @@
 #endif
 
 #define NFULNL_NLBUFSIZ_DEFAULT	NLMSG_GOODSIZE
-#define NFULNL_TIMEOUT_DEFAULT 	100	/* every second */
-#define NFULNL_QTHRESH_DEFAULT 	100	/* 100 packets */
+#define NFULNL_TIMEOUT_DEFAULT	100	/* every second */
+#define NFULNL_QTHRESH_DEFAULT	100	/* 100 packets */
 /* max packet size is limited by 16-bit struct nfattr nfa_len field */
 #define NFULNL_COPY_RANGE_MAX	(0xFFFF - NLA_HDRLEN)
 
@@ -188,11 +188,11 @@ instance_create(struct net *net, u_int16_t group_num,
 	inst->peer_portid = portid;
 	inst->group_num = group_num;
 
-	inst->qthreshold 	= NFULNL_QTHRESH_DEFAULT;
-	inst->flushtimeout 	= NFULNL_TIMEOUT_DEFAULT;
-	inst->nlbufsiz 		= NFULNL_NLBUFSIZ_DEFAULT;
-	inst->copy_mode 	= NFULNL_COPY_PACKET;
-	inst->copy_range 	= NFULNL_COPY_RANGE_MAX;
+	inst->qthreshold	= NFULNL_QTHRESH_DEFAULT;
+	inst->flushtimeout	= NFULNL_TIMEOUT_DEFAULT;
+	inst->nlbufsiz		= NFULNL_NLBUFSIZ_DEFAULT;
+	inst->copy_mode		= NFULNL_COPY_PACKET;
+	inst->copy_range	= NFULNL_COPY_RANGE_MAX;
 
 	hlist_add_head_rcu(&inst->hlist,
 		       &log->instance_table[instance_hashfn(group_num)]);
diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 685cc6a..f019061 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -187,8 +187,8 @@ instance_destroy(struct nfnl_queue_net *q, struct nfqnl_instance *inst)
 static inline void
 __enqueue_entry(struct nfqnl_instance *queue, struct nf_queue_entry *entry)
 {
-       list_add_tail(&entry->list, &queue->queue_list);
-       queue->queue_total++;
+	list_add_tail(&entry->list, &queue->queue_list);
+	queue->queue_total++;
 }
 
 static void
@@ -1208,17 +1208,17 @@ err_out_unlock:
 }
 
 static const struct nfnl_callback nfqnl_cb[NFQNL_MSG_MAX] = {
-	[NFQNL_MSG_PACKET]	= { .call_rcu = nfqnl_recv_unsupp,
-				    .attr_count = NFQA_MAX, },
-	[NFQNL_MSG_VERDICT]	= { .call_rcu = nfqnl_recv_verdict,
-				    .attr_count = NFQA_MAX,
-				    .policy = nfqa_verdict_policy },
-	[NFQNL_MSG_CONFIG]	= { .call = nfqnl_recv_config,
-				    .attr_count = NFQA_CFG_MAX,
-				    .policy = nfqa_cfg_policy },
-	[NFQNL_MSG_VERDICT_BATCH]={ .call_rcu = nfqnl_recv_verdict_batch,
-				    .attr_count = NFQA_MAX,
-				    .policy = nfqa_verdict_batch_policy },
+	[NFQNL_MSG_PACKET]	  = { .call_rcu = nfqnl_recv_unsupp,
+				      .attr_count = NFQA_MAX, },
+	[NFQNL_MSG_VERDICT]	  = { .call_rcu = nfqnl_recv_verdict,
+				      .attr_count = NFQA_MAX,
+				      .policy = nfqa_verdict_policy },
+	[NFQNL_MSG_CONFIG]	  = { .call = nfqnl_recv_config,
+				      .attr_count = NFQA_CFG_MAX,
+				      .policy = nfqa_cfg_policy },
+	[NFQNL_MSG_VERDICT_BATCH] = { .call_rcu = nfqnl_recv_verdict_batch,
+				      .attr_count = NFQA_MAX,
+				      .policy = nfqa_verdict_batch_policy },
 };
 
 static const struct nfnetlink_subsystem nfqnl_subsys = {
diff --git a/net/netfilter/nft_compat.c b/net/netfilter/nft_compat.c
index 66def31..3b8be76 100644
--- a/net/netfilter/nft_compat.c
+++ b/net/netfilter/nft_compat.c
@@ -541,7 +541,7 @@ nfnl_compat_get(struct sock *nfnl, struct sk_buff *skb,
 
 	nfmsg = nlmsg_data(nlh);
 
-	switch(nfmsg->nfgen_family) {
+	switch (nfmsg->nfgen_family) {
 	case AF_INET:
 		fmt = "ipt_%s";
 		break;
diff --git a/net/netfilter/nft_counter.c b/net/netfilter/nft_counter.c
index 1067fb4..15f3633 100644
--- a/net/netfilter/nft_counter.c
+++ b/net/netfilter/nft_counter.c
@@ -98,7 +98,7 @@ static int nft_counter_init(const struct nft_ctx *ctx,
 	preempt_disable();
 	this_cpu = this_cpu_ptr(cpu_stats);
 	if (tb[NFTA_COUNTER_PACKETS]) {
-	        this_cpu->counter.packets =
+		this_cpu->counter.packets =
 			be64_to_cpu(nla_get_be64(tb[NFTA_COUNTER_PACKETS]));
 	}
 	if (tb[NFTA_COUNTER_BYTES]) {
diff --git a/net/netfilter/nft_masq.c b/net/netfilter/nft_masq.c
index 9aea747..2f15c64 100644
--- a/net/netfilter/nft_masq.c
+++ b/net/netfilter/nft_masq.c
@@ -32,7 +32,7 @@ int nft_masq_validate(const struct nft_ctx *ctx,
 		return err;
 
 	return nft_chain_validate_hooks(ctx->chain,
-				        (1 << NF_INET_POST_ROUTING));
+					(1 << NF_INET_POST_ROUTING));
 }
 EXPORT_SYMBOL_GPL(nft_masq_validate);
 
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 9b42b5e..9f71f3d 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -344,7 +344,7 @@ textify_hooks(char *buf, size_t size, unsigned int mask, uint8_t nfproto)
 
 	names = (nfproto == NFPROTO_ARP) ? arp_names : inetbr_names;
 	max   = (nfproto == NFPROTO_ARP) ? ARRAY_SIZE(arp_names) :
-	                                   ARRAY_SIZE(inetbr_names);
+					   ARRAY_SIZE(inetbr_names);
 	*p = '\0';
 	for (i = 0; i < max; ++i) {
 		if (!(mask & (1 << i)))
@@ -392,9 +392,9 @@ int xt_check_match(struct xt_mtchk_param *par,
 		       "valid from %s\n",
 		       xt_prefix[par->family], par->match->name,
 		       textify_hooks(used, sizeof(used), par->hook_mask,
-		                     par->family),
+				     par->family),
 		       textify_hooks(allow, sizeof(allow), par->match->hooks,
-		                     par->family));
+				     par->family));
 		return -EINVAL;
 	}
 	if (par->match->proto && (par->match->proto != proto || inv_proto)) {
@@ -567,9 +567,9 @@ int xt_check_target(struct xt_tgchk_param *par,
 		       "usable from %s\n",
 		       xt_prefix[par->family], par->target->name,
 		       textify_hooks(used, sizeof(used), par->hook_mask,
-		                     par->family),
+				     par->family),
 		       textify_hooks(allow, sizeof(allow), par->target->hooks,
-		                     par->family));
+				     par->family));
 		return -EINVAL;
 	}
 	if (par->target->proto && (par->target->proto != proto || inv_proto)) {
@@ -990,7 +990,7 @@ enum {
 };
 
 static void *xt_mttg_seq_next(struct seq_file *seq, void *v, loff_t *ppos,
-    bool is_target)
+			      bool is_target)
 {
 	static const uint8_t next_class[] = {
 		[MTTG_TRAV_NFP_UNSPEC] = MTTG_TRAV_NFP_SPEC,
@@ -1004,7 +1004,7 @@ static void *xt_mttg_seq_next(struct seq_file *seq, void *v, loff_t *ppos,
 		mutex_lock(&xt[NFPROTO_UNSPEC].mutex);
 		trav->head = trav->curr = is_target ?
 			&xt[NFPROTO_UNSPEC].target : &xt[NFPROTO_UNSPEC].match;
- 		break;
+		break;
 	case MTTG_TRAV_NFP_UNSPEC:
 		trav->curr = trav->curr->next;
 		if (trav->curr != trav->head)
@@ -1030,7 +1030,7 @@ static void *xt_mttg_seq_next(struct seq_file *seq, void *v, loff_t *ppos,
 }
 
 static void *xt_mttg_seq_start(struct seq_file *seq, loff_t *pos,
-    bool is_target)
+			       bool is_target)
 {
 	struct nf_mttg_trav *trav = seq->private;
 	unsigned int j;
@@ -1164,7 +1164,7 @@ static const struct file_operations xt_target_ops = {
 
 #define FORMAT_TABLES	"_tables_names"
 #define	FORMAT_MATCHES	"_tables_matches"
-#define FORMAT_TARGETS 	"_tables_targets"
+#define FORMAT_TARGETS	"_tables_targets"
 
 #endif /* CONFIG_PROC_FS */
 
@@ -1343,4 +1343,3 @@ static void __exit xt_fini(void)
 
 module_init(xt_init);
 module_exit(xt_fini);
-
diff --git a/net/netfilter/xt_CLASSIFY.c b/net/netfilter/xt_CLASSIFY.c
index af9c4da..b555bbb 100644
--- a/net/netfilter/xt_CLASSIFY.c
+++ b/net/netfilter/xt_CLASSIFY.c
@@ -43,7 +43,7 @@ static struct xt_target classify_tg_reg[] __read_mostly = {
 		.revision   = 0,
 		.family     = NFPROTO_UNSPEC,
 		.hooks      = (1 << NF_INET_LOCAL_OUT) | (1 << NF_INET_FORWARD) |
-		              (1 << NF_INET_POST_ROUTING),
+			      (1 << NF_INET_POST_ROUTING),
 		.target     = classify_tg,
 		.targetsize = sizeof(struct xt_classify_target_info),
 		.me         = THIS_MODULE,
diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index 8e52489..36e34b5 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -266,7 +266,7 @@ static int xt_ct_tg_check_v0(const struct xt_tgchk_param *par)
 {
 	struct xt_ct_target_info *info = par->targinfo;
 	struct xt_ct_target_info_v1 info_v1 = {
-		.flags 		= info->flags,
+		.flags		= info->flags,
 		.zone		= info->zone,
 		.ct_events	= info->ct_events,
 		.exp_events	= info->exp_events,
@@ -347,7 +347,7 @@ static void xt_ct_tg_destroy_v0(const struct xt_tgdtor_param *par)
 {
 	struct xt_ct_target_info *info = par->targinfo;
 	struct xt_ct_target_info_v1 info_v1 = {
-		.flags 		= info->flags,
+		.flags		= info->flags,
 		.zone		= info->zone,
 		.ct_events	= info->ct_events,
 		.exp_events	= info->exp_events,
diff --git a/net/netfilter/xt_NETMAP.c b/net/netfilter/xt_NETMAP.c
index b253e07..a7801fd 100644
--- a/net/netfilter/xt_NETMAP.c
+++ b/net/netfilter/xt_NETMAP.c
@@ -123,9 +123,9 @@ static struct xt_target netmap_tg_reg[] __read_mostly = {
 		.targetsize = sizeof(struct nf_nat_range),
 		.table      = "nat",
 		.hooks      = (1 << NF_INET_PRE_ROUTING) |
-		              (1 << NF_INET_POST_ROUTING) |
-		              (1 << NF_INET_LOCAL_OUT) |
-		              (1 << NF_INET_LOCAL_IN),
+			      (1 << NF_INET_POST_ROUTING) |
+			      (1 << NF_INET_LOCAL_OUT) |
+			      (1 << NF_INET_LOCAL_IN),
 		.checkentry = netmap_tg6_checkentry,
 		.me         = THIS_MODULE,
 	},
@@ -137,9 +137,9 @@ static struct xt_target netmap_tg_reg[] __read_mostly = {
 		.targetsize = sizeof(struct nf_nat_ipv4_multi_range_compat),
 		.table      = "nat",
 		.hooks      = (1 << NF_INET_PRE_ROUTING) |
-		              (1 << NF_INET_POST_ROUTING) |
-		              (1 << NF_INET_LOCAL_OUT) |
-		              (1 << NF_INET_LOCAL_IN),
+			      (1 << NF_INET_POST_ROUTING) |
+			      (1 << NF_INET_LOCAL_OUT) |
+			      (1 << NF_INET_LOCAL_IN),
 		.checkentry = netmap_tg4_check,
 		.me         = THIS_MODULE,
 	},
diff --git a/net/netfilter/xt_REDIRECT.c b/net/netfilter/xt_REDIRECT.c
index 03f0b37..6220954 100644
--- a/net/netfilter/xt_REDIRECT.c
+++ b/net/netfilter/xt_REDIRECT.c
@@ -75,7 +75,7 @@ static struct xt_target redirect_tg_reg[] __read_mostly = {
 		.target     = redirect_tg6,
 		.targetsize = sizeof(struct nf_nat_range),
 		.hooks      = (1 << NF_INET_PRE_ROUTING) |
-		              (1 << NF_INET_LOCAL_OUT),
+			      (1 << NF_INET_LOCAL_OUT),
 		.me         = THIS_MODULE,
 	},
 	{
@@ -87,7 +87,7 @@ static struct xt_target redirect_tg_reg[] __read_mostly = {
 		.checkentry = redirect_tg4_check,
 		.targetsize = sizeof(struct nf_nat_ipv4_multi_range_compat),
 		.hooks      = (1 << NF_INET_PRE_ROUTING) |
-		              (1 << NF_INET_LOCAL_OUT),
+			      (1 << NF_INET_LOCAL_OUT),
 		.me         = THIS_MODULE,
 	},
 };
diff --git a/net/netfilter/xt_cluster.c b/net/netfilter/xt_cluster.c
index 96fa26b..79641dc 100644
--- a/net/netfilter/xt_cluster.c
+++ b/net/netfilter/xt_cluster.c
@@ -44,7 +44,7 @@ xt_cluster_hash(const struct nf_conn *ct,
 {
 	u_int32_t hash = 0;
 
-	switch(nf_ct_l3num(ct)) {
+	switch (nf_ct_l3num(ct)) {
 	case AF_INET:
 		hash = xt_cluster_hash_ipv4(nf_ct_orig_ipv4_src(ct), info);
 		break;
@@ -71,7 +71,7 @@ xt_cluster_is_multicast_addr(const struct sk_buff *skb, u_int8_t family)
 {
 	bool is_multicast = false;
 
-	switch(family) {
+	switch (family) {
 	case NFPROTO_IPV4:
 		is_multicast = ipv4_is_multicast(ip_hdr(skb)->daddr);
 		break;
@@ -114,7 +114,7 @@ xt_cluster_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	 */
 	if (!xt_cluster_is_multicast_addr(skb, par->family) &&
 	    skb->pkt_type == PACKET_MULTICAST) {
-	    	pskb->pkt_type = PACKET_HOST;
+		pskb->pkt_type = PACKET_HOST;
 	}
 
 	ct = nf_ct_get(skb, &ctinfo);
diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index 075d89d..5361fe2 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -74,7 +74,7 @@ static inline unsigned int connlimit_iphash(__be32 addr)
 
 static inline unsigned int
 connlimit_iphash6(const union nf_inet_addr *addr,
-                  const union nf_inet_addr *mask)
+		  const union nf_inet_addr *mask)
 {
 	union nf_inet_addr res;
 	unsigned int i;
@@ -347,7 +347,7 @@ connlimit_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	}
 
 	connections = count_them(net, info->data, tuple_ptr, &addr,
-	                         &info->mask, par->family, zone);
+				 &info->mask, par->family, zone);
 	if (connections == 0)
 		/* kmalloc failed, drop it entirely */
 		goto hotdrop;
diff --git a/net/netfilter/xt_connmark.c b/net/netfilter/xt_connmark.c
index 69f78e9..5675c7c 100644
--- a/net/netfilter/xt_connmark.c
+++ b/net/netfilter/xt_connmark.c
@@ -57,7 +57,7 @@ connmark_tg(struct sk_buff *skb, const struct xt_action_param *par)
 		break;
 	case XT_CONNMARK_SAVE:
 		newmark = (ct->mark & ~info->ctmask) ^
-		          (skb->mark & info->nfmask);
+			  (skb->mark & info->nfmask);
 		if (ct->mark != newmark) {
 			ct->mark = newmark;
 			nf_conntrack_event_cache(IPCT_MARK, ct);
@@ -65,7 +65,7 @@ connmark_tg(struct sk_buff *skb, const struct xt_action_param *par)
 		break;
 	case XT_CONNMARK_RESTORE:
 		newmark = (skb->mark & ~info->nfmask) ^
-		          (ct->mark & info->ctmask);
+			  (ct->mark & info->ctmask);
 		skb->mark = newmark;
 		break;
 	}
diff --git a/net/netfilter/xt_conntrack.c b/net/netfilter/xt_conntrack.c
index 188404b9..9934136 100644
--- a/net/netfilter/xt_conntrack.c
+++ b/net/netfilter/xt_conntrack.c
@@ -27,8 +27,8 @@ MODULE_ALIAS("ip6t_conntrack");
 
 static bool
 conntrack_addrcmp(const union nf_inet_addr *kaddr,
-                  const union nf_inet_addr *uaddr,
-                  const union nf_inet_addr *umask, unsigned int l3proto)
+		  const union nf_inet_addr *uaddr,
+		  const union nf_inet_addr *umask, unsigned int l3proto)
 {
 	if (l3proto == NFPROTO_IPV4)
 		return ((kaddr->ip ^ uaddr->ip) & umask->ip) == 0;
@@ -41,7 +41,7 @@ conntrack_addrcmp(const union nf_inet_addr *kaddr,
 
 static inline bool
 conntrack_mt_origsrc(const struct nf_conn *ct,
-                     const struct xt_conntrack_mtinfo2 *info,
+		     const struct xt_conntrack_mtinfo2 *info,
 		     u_int8_t family)
 {
 	return conntrack_addrcmp(&ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.u3,
@@ -50,7 +50,7 @@ conntrack_mt_origsrc(const struct nf_conn *ct,
 
 static inline bool
 conntrack_mt_origdst(const struct nf_conn *ct,
-                     const struct xt_conntrack_mtinfo2 *info,
+		     const struct xt_conntrack_mtinfo2 *info,
 		     u_int8_t family)
 {
 	return conntrack_addrcmp(&ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.dst.u3,
@@ -59,7 +59,7 @@ conntrack_mt_origdst(const struct nf_conn *ct,
 
 static inline bool
 conntrack_mt_replsrc(const struct nf_conn *ct,
-                     const struct xt_conntrack_mtinfo2 *info,
+		     const struct xt_conntrack_mtinfo2 *info,
 		     u_int8_t family)
 {
 	return conntrack_addrcmp(&ct->tuplehash[IP_CT_DIR_REPLY].tuple.src.u3,
@@ -68,7 +68,7 @@ conntrack_mt_replsrc(const struct nf_conn *ct,
 
 static inline bool
 conntrack_mt_repldst(const struct nf_conn *ct,
-                     const struct xt_conntrack_mtinfo2 *info,
+		     const struct xt_conntrack_mtinfo2 *info,
 		     u_int8_t family)
 {
 	return conntrack_addrcmp(&ct->tuplehash[IP_CT_DIR_REPLY].tuple.dst.u3,
@@ -77,7 +77,7 @@ conntrack_mt_repldst(const struct nf_conn *ct,
 
 static inline bool
 ct_proto_port_check(const struct xt_conntrack_mtinfo2 *info,
-                    const struct nf_conn *ct)
+		    const struct nf_conn *ct)
 {
 	const struct nf_conntrack_tuple *tuple;
 
@@ -163,7 +163,7 @@ ct_proto_port_check_v3(const struct xt_conntrack_mtinfo3 *info,
 
 static bool
 conntrack_mt(const struct sk_buff *skb, struct xt_action_param *par,
-             u16 state_mask, u16 status_mask)
+	     u16 state_mask, u16 status_mask)
 {
 	const struct xt_conntrack_mtinfo2 *info = par->matchinfo;
 	enum ip_conntrack_info ctinfo;
diff --git a/net/netfilter/xt_dccp.c b/net/netfilter/xt_dccp.c
index b63d2a3..ce0048a 100644
--- a/net/netfilter/xt_dccp.c
+++ b/net/netfilter/xt_dccp.c
@@ -139,22 +139,22 @@ static int dccp_mt_check(const struct xt_mtchk_param *par)
 
 static struct xt_match dccp_mt_reg[] __read_mostly = {
 	{
-		.name 		= "dccp",
+		.name		= "dccp",
 		.family		= NFPROTO_IPV4,
 		.checkentry	= dccp_mt_check,
 		.match		= dccp_mt,
 		.matchsize	= sizeof(struct xt_dccp_info),
 		.proto		= IPPROTO_DCCP,
-		.me 		= THIS_MODULE,
+		.me		= THIS_MODULE,
 	},
 	{
-		.name 		= "dccp",
+		.name		= "dccp",
 		.family		= NFPROTO_IPV6,
 		.checkentry	= dccp_mt_check,
 		.match		= dccp_mt,
 		.matchsize	= sizeof(struct xt_dccp_info),
 		.proto		= IPPROTO_DCCP,
-		.me 		= THIS_MODULE,
+		.me		= THIS_MODULE,
 	},
 };
 
diff --git a/net/netfilter/xt_ecn.c b/net/netfilter/xt_ecn.c
index 3c831a8..54498f9 100644
--- a/net/netfilter/xt_ecn.c
+++ b/net/netfilter/xt_ecn.c
@@ -108,7 +108,7 @@ static inline bool match_ipv6(const struct sk_buff *skb,
 			      const struct xt_ecn_info *einfo)
 {
 	return (((ipv6_hdr(skb)->flow_lbl[0] >> 4) & XT_ECN_IP_MASK) ==
-	        einfo->ip_ect) ^
+		einfo->ip_ect) ^
 	       !!(einfo->invert & XT_ECN_OP_MATCH_IP);
 }
 
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 1786968..80ff0a4 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -235,7 +235,7 @@ static int htable_create(struct net *net, struct xt_hashlimit_mtinfo1 *minfo,
 	}
 	/* FIXME: don't use vmalloc() here or anywhere else -HW */
 	hinfo = vmalloc(sizeof(struct xt_hashlimit_htable) +
-	                sizeof(struct list_head) * size);
+			sizeof(struct list_head) * size);
 	if (hinfo == NULL)
 		return -ENOMEM;
 	minfo->hinfo = hinfo;
@@ -529,10 +529,10 @@ hashlimit_init_dst(const struct xt_hashlimit_htable *hinfo,
 	case NFPROTO_IPV4:
 		if (hinfo->cfg.mode & XT_HASHLIMIT_HASH_DIP)
 			dst->ip.dst = maskl(ip_hdr(skb)->daddr,
-			              hinfo->cfg.dstmask);
+					    hinfo->cfg.dstmask);
 		if (hinfo->cfg.mode & XT_HASHLIMIT_HASH_SIP)
 			dst->ip.src = maskl(ip_hdr(skb)->saddr,
-			              hinfo->cfg.srcmask);
+					    hinfo->cfg.srcmask);
 
 		if (!(hinfo->cfg.mode &
 		      (XT_HASHLIMIT_HASH_DPT | XT_HASHLIMIT_HASH_SPT)))
diff --git a/net/netfilter/xt_iprange.c b/net/netfilter/xt_iprange.c
index b46626c..1f2ca02 100644
--- a/net/netfilter/xt_iprange.c
+++ b/net/netfilter/xt_iprange.c
@@ -29,10 +29,10 @@ iprange_mt4(const struct sk_buff *skb, struct xt_action_param *par)
 		m ^= !!(info->flags & IPRANGE_SRC_INV);
 		if (m) {
 			pr_debug("src IP %pI4 NOT in range %s%pI4-%pI4\n",
-			         &iph->saddr,
-			         (info->flags & IPRANGE_SRC_INV) ? "(INV) " : "",
-			         &info->src_min.ip,
-			         &info->src_max.ip);
+				 &iph->saddr,
+				 (info->flags & IPRANGE_SRC_INV) ? "(INV) " : "",
+				 &info->src_min.ip,
+				 &info->src_max.ip);
 			return false;
 		}
 	}
@@ -42,10 +42,10 @@ iprange_mt4(const struct sk_buff *skb, struct xt_action_param *par)
 		m ^= !!(info->flags & IPRANGE_DST_INV);
 		if (m) {
 			pr_debug("dst IP %pI4 NOT in range %s%pI4-%pI4\n",
-			         &iph->daddr,
-			         (info->flags & IPRANGE_DST_INV) ? "(INV) " : "",
-			         &info->dst_min.ip,
-			         &info->dst_max.ip);
+				 &iph->daddr,
+				 (info->flags & IPRANGE_DST_INV) ? "(INV) " : "",
+				 &info->dst_min.ip,
+				 &info->dst_max.ip);
 			return false;
 		}
 	}
diff --git a/net/netfilter/xt_mac.c b/net/netfilter/xt_mac.c
index d5b4fd4..981510c 100644
--- a/net/netfilter/xt_mac.c
+++ b/net/netfilter/xt_mac.c
@@ -48,7 +48,7 @@ static struct xt_match mac_mt_reg __read_mostly = {
 	.match     = mac_mt,
 	.matchsize = sizeof(struct xt_mac_info),
 	.hooks     = (1 << NF_INET_PRE_ROUTING) | (1 << NF_INET_LOCAL_IN) |
-	             (1 << NF_INET_FORWARD),
+		     (1 << NF_INET_FORWARD),
 	.me        = THIS_MODULE,
 };
 
diff --git a/net/netfilter/xt_multiport.c b/net/netfilter/xt_multiport.c
index ac1d3c3..5ba78ef 100644
--- a/net/netfilter/xt_multiport.c
+++ b/net/netfilter/xt_multiport.c
@@ -94,11 +94,10 @@ multiport_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	return ports_match_v1(multiinfo, ntohs(pptr[0]), ntohs(pptr[1]));
 }
 
-static inline bool
-check(u_int16_t proto,
-      u_int8_t ip_invflags,
-      u_int8_t match_flags,
-      u_int8_t count)
+static inline bool check(u_int16_t proto,
+			 u_int8_t ip_invflags,
+			 u_int8_t match_flags,
+			 u_int8_t count)
 {
 	/* Must specify supported protocol, no unknown flags or bad count */
 	return (proto == IPPROTO_TCP || proto == IPPROTO_UDP
diff --git a/net/netfilter/xt_osf.c b/net/netfilter/xt_osf.c
index 0778855..e4601b1 100644
--- a/net/netfilter/xt_osf.c
+++ b/net/netfilter/xt_osf.c
@@ -355,14 +355,14 @@ xt_osf_match_packet(const struct sk_buff *skb, struct xt_action_param *p)
 }
 
 static struct xt_match xt_osf_match = {
-	.name 		= "osf",
+	.name		= "osf",
 	.revision	= 0,
 	.family		= NFPROTO_IPV4,
 	.proto		= IPPROTO_TCP,
-	.hooks      	= (1 << NF_INET_LOCAL_IN) |
+	.hooks		= (1 << NF_INET_LOCAL_IN) |
 				(1 << NF_INET_PRE_ROUTING) |
 				(1 << NF_INET_FORWARD),
-	.match 		= xt_osf_match_packet,
+	.match		= xt_osf_match_packet,
 	.matchsize	= sizeof(struct xt_osf_info),
 	.me		= THIS_MODULE,
 };
@@ -372,7 +372,7 @@ static int __init xt_osf_init(void)
 	int err = -EINVAL;
 	int i;
 
-	for (i=0; i<ARRAY_SIZE(xt_osf_fingers); ++i)
+	for (i = 0; i < ARRAY_SIZE(xt_osf_fingers); ++i)
 		INIT_LIST_HEAD(&xt_osf_fingers[i]);
 
 	err = nfnetlink_subsys_register(&xt_osf_nfnetlink);
@@ -405,7 +405,7 @@ static void __exit xt_osf_fini(void)
 	xt_unregister_match(&xt_osf_match);
 
 	rcu_read_lock();
-	for (i=0; i<ARRAY_SIZE(xt_osf_fingers); ++i) {
+	for (i = 0; i < ARRAY_SIZE(xt_osf_fingers); ++i) {
 
 		list_for_each_entry_rcu(f, &xt_osf_fingers[i], finger_entry) {
 			list_del_rcu(&f->finger_entry);
diff --git a/net/netfilter/xt_owner.c b/net/netfilter/xt_owner.c
index ca2e577..0f17937 100644
--- a/net/netfilter/xt_owner.c
+++ b/net/netfilter/xt_owner.c
@@ -77,7 +77,7 @@ static struct xt_match owner_mt_reg __read_mostly = {
 	.match      = owner_mt,
 	.matchsize  = sizeof(struct xt_owner_match_info),
 	.hooks      = (1 << NF_INET_LOCAL_OUT) |
-	              (1 << NF_INET_POST_ROUTING),
+		      (1 << NF_INET_POST_ROUTING),
 	.me         = THIS_MODULE,
 };
 
diff --git a/net/netfilter/xt_policy.c b/net/netfilter/xt_policy.c
index f23e97b..00fcdd8 100644
--- a/net/netfilter/xt_policy.c
+++ b/net/netfilter/xt_policy.c
@@ -38,10 +38,10 @@ static bool
 match_xfrm_state(const struct xfrm_state *x, const struct xt_policy_elem *e,
 		 unsigned short family)
 {
-#define MATCH_ADDR(x,y,z)	(!e->match.x ||			       \
+#define MATCH_ADDR(x, y, z)	(!e->match.x ||			       \
 				 (xt_addr_cmp(&e->x, &e->y, (const union nf_inet_addr *)(z), family) \
 				  ^ e->invert.x))
-#define MATCH(x,y)		(!e->match.x || ((e->x == (y)) ^ e->invert.x))
+#define MATCH(x, y)		(!e->match.x || ((e->x == (y)) ^ e->invert.x))
 
 	return MATCH_ADDR(saddr, smask, &x->props.saddr) &&
 	       MATCH_ADDR(daddr, dmask, &x->id.daddr) &&
@@ -157,7 +157,7 @@ static struct xt_match policy_mt_reg[] __read_mostly = {
 	{
 		.name		= "policy",
 		.family		= NFPROTO_IPV4,
-		.checkentry 	= policy_mt_check,
+		.checkentry	= policy_mt_check,
 		.match		= policy_mt,
 		.matchsize	= sizeof(struct xt_policy_info),
 		.me		= THIS_MODULE,
diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index 45e1b30..99a7c21 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -659,7 +659,7 @@ static void __net_exit recent_proc_net_exit(struct net *net)
 	 */
 	spin_lock_bh(&recent_lock);
 	list_for_each_entry(t, &recent_net->tables, list)
-	        remove_proc_entry(t->name, recent_net->xt_recent);
+		remove_proc_entry(t->name, recent_net->xt_recent);
 
 	recent_net->xt_recent = NULL;
 	spin_unlock_bh(&recent_lock);
diff --git a/net/netfilter/xt_tcpudp.c b/net/netfilter/xt_tcpudp.c
index c14d464..aea7424 100644
--- a/net/netfilter/xt_tcpudp.c
+++ b/net/netfilter/xt_tcpudp.c
@@ -56,7 +56,7 @@ tcp_find_option(u_int8_t option,
 	for (i = 0; i < optlen; ) {
 		if (op[i] == option) return !invert;
 		if (op[i] < 2) i++;
-		else i += op[i+1]?:1;
+		else i += op[i + 1] ? : 1;
 	}
 
 	return invert;
diff --git a/net/netfilter/xt_time.c b/net/netfilter/xt_time.c
index 0ae55a3..3ae054f 100644
--- a/net/netfilter/xt_time.c
+++ b/net/netfilter/xt_time.c
@@ -162,8 +162,8 @@ time_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	/*
 	 * We cannot use get_seconds() instead of __net_timestamp() here.
 	 * Suppose you have two rules:
-	 * 	1. match before 13:00
-	 * 	2. match after 13:00
+	 *	1. match before 13:00
+	 *	2. match after 13:00
 	 * If you match against processing time (get_seconds) it
 	 * may happen that the same packet matches both rules if
 	 * it arrived at the right moment before 13:00.
-- 
1.9.1
