From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 16/42] net/ipv6/netfilter: Adjust confusing if indentation
Date: Thu, 5 Aug 2010 22:21:41 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1008052221240.31692@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:55560 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934129Ab0HEUVn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Aug 2010 16:21:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

Indent the branch of an if.

The semantic match that finds this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@r disable braces4@
position p1,p2;
statement S1,S2;
@@

(
if (...) { ... }
|
if (...) S1@p1 S2@p2
)

@script:python@
p1 << r.p1;
p2 << r.p2;
@@

if (p1[0].column == p2[0].column):
  cocci.print_main("branch",p1)
  cocci.print_secs("after",p2)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index 1df3c8b..befccff 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -192,7 +192,7 @@ icmpv6_error(struct net *net, struct nf_conn *tmpl,
 	icmp6h = skb_header_pointer(skb, dataoff, sizeof(_ih), &_ih);
 	if (icmp6h == NULL) {
 		if (LOG_INVALID(net, IPPROTO_ICMPV6))
-		nf_log_packet(PF_INET6, 0, skb, NULL, NULL, NULL,
+			nf_log_packet(PF_INET6, 0, skb, NULL, NULL, NULL,
 			      "nf_ct_icmpv6: short packet ");
 		return -NF_ACCEPT;
 	}
