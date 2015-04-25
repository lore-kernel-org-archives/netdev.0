From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH net-next 2/6] ipv6: netfilter: whitespace in line layouts
Date: Sat, 25 Apr 2015 10:26:56 +0100
Message-ID: <1429954020-11763-3-git-send-email-ipm@chirality.org.uk>
References: <1429954020-11763-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-gw.chirality.org.uk ([88.97.209.22]:36724 "EHLO
	yew.chirality.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758806AbbDYJ1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Apr 2015 05:27:10 -0400
In-Reply-To: <1429954020-11763-1-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Try to improve coding readability by adding spaces in line layouts. No
changes to functionality. No changes according to objdiff.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
---
 net/ipv6/netfilter/ip6_tables.c                | 12 ++++++------
 net/ipv6/netfilter/ip6t_rpfilter.c             |  2 +-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |  4 ++--
 net/ipv6/netfilter/nf_conntrack_reasm.c        |  4 ++--
 net/ipv6/netfilter/nf_reject_ipv6.c            |  4 ++--
 5 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index c6c9de7..82d53d5 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -44,13 +44,13 @@ MODULE_DESCRIPTION("IPv6 packet filter");
 /*#define DEBUG_IP_FIREWALL_USER*/
 
 #ifdef DEBUG_IP_FIREWALL
-#define dprintf(format, args...) pr_info(format , ## args)
+#define dprintf(format, args...) pr_info(format, ## args)
 #else
 #define dprintf(format, args...)
 #endif
 
 #ifdef DEBUG_IP_FIREWALL_USER
-#define duprintf(format, args...) pr_info(format , ## args)
+#define duprintf(format, args...) pr_info(format, ## args)
 #else
 #define duprintf(format, args...)
 #endif
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
+	if ((ip6info->flags & IP6T_F_PROTO)) {
 		int protohdr;
 		unsigned short _frag_off;
 
@@ -151,7 +151,7 @@ ip6_packet_match(const struct sk_buff *skb,
 				ip6info->proto);
 
 		if (ip6info->proto == protohdr) {
-			if(ip6info->invflags & IP6T_INV_PROTO) {
+			if (ip6info->invflags & IP6T_INV_PROTO) {
 				return false;
 			}
 			return true;
diff --git a/net/ipv6/netfilter/ip6t_rpfilter.c b/net/ipv6/netfilter/ip6t_rpfilter.c
index 790e0c6..1924177 100644
--- a/net/ipv6/netfilter/ip6t_rpfilter.c
+++ b/net/ipv6/netfilter/ip6t_rpfilter.c
@@ -34,7 +34,7 @@ static bool rpfilter_lookup_reverse6(const struct sk_buff *skb,
 	bool ret = false;
 	struct flowi6 fl6 = {
 		.flowi6_iif = LOOPBACK_IFINDEX,
-		.flowlabel = (* (__be32 *) iph) & IPV6_FLOWINFO_MASK,
+		.flowlabel = (*(__be32 *)iph) & IPV6_FLOWINFO_MASK,
 		.flowi6_proto = iph->nexthdr,
 		.daddr = iph->saddr,
 	};
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index 90388d6..1f5b350 100644
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
index 6f187c8..07d8534 100644
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
-- 
1.9.1
