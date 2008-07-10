From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] ipv6: missed namespace context in ipv6_rthdr_rcv
Date: Thu, 10 Jul 2008 16:55:01 -0700 (PDT)
Message-ID: <20080710.165501.260157661.davem@davemloft.net>
References: <1215691748-17151-1-git-send-email-den@openvz.org>
	<487606DD.8000804@fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: den@openvz.org, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	benjamin.thery@bull.net, den@parallels.com
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50140
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754958AbYGJXzB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 19:55:01 -0400
In-Reply-To: <487606DD.8000804@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Thu, 10 Jul 2008 14:55:57 +0200

> Denis V. Lunev wrote:
> > Signed-off-by: Denis V. Lunev <den@parallels.com>
> > ---
> >  net/ipv6/exthdrs.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
> > index 3cd1c99..dcf94fd 100644
> > --- a/net/ipv6/exthdrs.c
> > +++ b/net/ipv6/exthdrs.c
> > @@ -445,7 +445,7 @@ looped_back:
> >  			kfree_skb(skb);
> >  			return -1;
> >  		}
> > -		if (!ipv6_chk_home_addr(&init_net, addr)) {
> > +		if (!ipv6_chk_home_addr(dev_net(skb->dst->dev), addr)) {
> >  			IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
> >  					 IPSTATS_MIB_INADDRERRORS);
> >  			kfree_skb(skb);
> 
> Thanks Denis :)

Applied to net-2.6, thanks!
