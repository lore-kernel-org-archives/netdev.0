From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] net: convert BUG_TRAP to generic WARN_ON
Date: Fri, 25 Jul 2008 13:21:05 -0700 (PDT)
Message-ID: <20080725.132105.175832134.davem@davemloft.net>
References: <1216990020-2716-2-git-send-email-ilpo.jarvinen@helsinki.fi>
	<E1KMPJS-0005Dh-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51588
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751223AbYGYUVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 16:21:06 -0400
In-Reply-To: <E1KMPJS-0005Dh-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 25 Jul 2008 23:34:34 +0800

> Ilpo J??rvinen <ilpo.jarvinen@helsinki.fi> wrote:
> >
> > diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
> > index a75807b..ee1bbf9 100644
> > --- a/net/ipv4/ipcomp.c
> > +++ b/net/ipv4/ipcomp.c
> > @@ -293,7 +293,7 @@ static void ipcomp_free_tfms(struct crypto_comp **tfms)
> >                        break;
> >        }
> > 
> > -       BUG_TRAP(pos);
> > +       WARN_ON(!pos);
> 
> Sorry I've just moved this to net/xfrm/xfrm_ipcomp.c.  BTW,
> please also remove rtnetlink.h from ipcomp.c since that's only
> included for this macro.

This is my fault, I didn't push before going to bed last night.
Otherwise Ilpo would have seen this sooner.

I've just taken care of this.
