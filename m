From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] Fix comment for packets without data
Date: Sun, 16 Dec 2012 23:38:25 +0100
Message-ID: <20121216223825.GC1304@1984>
References: <50CA23AA.1040501@hp.com>
 <1355482413-18629-1-git-send-email-florent.fourcot@enst-bretagne.fr>
 <50CB9A16.1090006@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florent Fourcot <florent.fourcot@enst-bretagne.fr>,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49508 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751666Ab2LPWi2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Dec 2012 17:38:28 -0500
Content-Disposition: inline
In-Reply-To: <50CB9A16.1090006@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 14, 2012 at 01:28:54PM -0800, Rick Jones wrote:
> On 12/14/2012 02:53 AM, Florent Fourcot wrote:
> >Remove ambiguity of double negation
> >
> >Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
> >---
> >  net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |    4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> >
> >diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
> >index 00ee17c..137e245 100644
> >--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
> >+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
> >@@ -81,8 +81,8 @@ static int ipv6_get_l4proto(const struct sk_buff *skb, unsigned int nhoff,
> >  	}
> >  	protoff = ipv6_skip_exthdr(skb, extoff, &nexthdr, &frag_off);
> >  	/*
> >-	 * (protoff == skb->len) mean that the packet doesn't have no data
> >-	 * except of IPv6 & ext headers. but it's tracked anyway. - YK
> >+	 * (protoff == skb->len) means the packet has not data, just
> >+	 * IPv6 and possibly extensions headers, but it is tracked anyway
> >  	 */
> >  	if (protoff < 0 || (frag_off & htons(~0x7)) != 0) {
> >  		pr_debug("ip6_conntrack_core: can't find proto in pkt\n");
> >
> 
> Acked-by: Rick Jones <rick.jones2@hp.com>

Applied, thanks.

That was many discussion for a patch to fix a comment, nice indeed :-)
