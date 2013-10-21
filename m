From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net 2/3] ipv6: fill rt6i_gateway with nexthop address
Date: Mon, 21 Oct 2013 10:31:06 +0300 (EEST)
Message-ID: <alpine.LFD.2.03.1310211009270.1522@ssi.bg>
References: <1382272985-1528-1-git-send-email-ja@ssi.bg> <1382272985-1528-3-git-send-email-ja@ssi.bg> <20131021050159.GE28333@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:48777 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752362Ab3JUHgK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Oct 2013 03:36:10 -0400
In-Reply-To: <20131021050159.GE28333@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 21 Oct 2013, Hannes Frederic Sowa wrote:

> On Sun, Oct 20, 2013 at 03:43:04PM +0300, Julian Anastasov wrote:
> > Make sure rt6i_gateway contains nexthop information in
> > all routes returned from lookup or when routes are directly
> > attached to skb for generated ICMP packets.
> > 
> > The effect of this patch should be a faster version of
> > rt6_nexthop() and the consideration of local addresses as
> > nexthop.
> > 
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> 
> The patch is fine. I don't mind if we leave it as is or remove rt6_nexthop,
> so:
> 
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

	Thanks for the review! I don't mind too about
removing rt6_nexthop. For me it is 51% against 49% to keep it
as it denotes the places that use nexthop and not gateway.
May be more opinions will help to decide because I don't know
if there are any plans to use similar techniques as done for IPv4.

Regards

--
Julian Anastasov <ja@ssi.bg>
