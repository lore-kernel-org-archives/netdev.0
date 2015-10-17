From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 21/35] netfilter: ipv6: whitespace around operators
Date: Sat, 17 Oct 2015 13:32:56 +0200
Message-ID: <1445081590-2924-22-git-send-email-pablo@netfilter.org>
References: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48413 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752774AbbJQL00 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Oct 2015 07:26:26 -0400
In-Reply-To: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Morris <ipm@chirality.org.uk>

This patch cleanses whitespace around arithmetical operators.

No changes detected by objdiff.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c | 4 ++--
 net/ipv6/netfilter/nf_conntrack_reasm.c        | 2 +-
 net/ipv6/netfilter/nf_reject_ipv6.c            | 4 ++--
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index d3b7974..660bc10 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -57,12 +57,12 @@ static const u_int8_t invmap[] = {
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
index 701cd2b..cfcc71f 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
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
2.1.4
