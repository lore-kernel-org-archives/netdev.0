From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: fix-slab-corruption-running-ip6sic.patch
Date: Fri, 27 Apr 2007 09:18:59 +0200
Message-ID: <20070427071859.GD997@ff.dom.local>
References: <20070426141133.21ef2e17.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	Eric Sesterhenn <snakebyte@gmx.de>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:49245 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755430AbXD0HNI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2007 03:13:08 -0400
Content-Disposition: inline
In-Reply-To: <20070426141133.21ef2e17.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 26, 2007 at 02:11:33PM -0700, Andrew Morton wrote:
> 
> I have this floating about in my tree.  Is it of any interest?
> 
> 
> 
> From: Jarek Poplawski <jarkao2@o2.pl>

I know you've more interesting problems, but I'd like to
straighten something: this is not my patch!

Please, change this to:

From: Eric Sesterhenn <snakebyte@gmx.de>

> 
> * Herbert Xu (herbert@gondor.apana.org.au) wrote:
> > Jarek Poplawski <jarkao2@o2.pl> wrote:
> > >
> > > My proposal is: maybe Eric could change this in
> > > xfrm6_tunnel_rcv() from xfrm6_tunnel.c e.g. like this:
> > >
> > > return xfrm6_rcv_spi(skb, spi) > 0 ? : 0;
> > >
> > > and, if no errors in testing, he could resubmit this patch?
> >
> > I agree, this is the right fix.
> 
> The fix proposed by Jarek indeed fixes the problem, tested on two boxes,
> with an -rc5 kernel and a yesterdays git
> 
> Acked-by: Eric Sesterhenn <snakebyte@gmx.de>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---

Thanks,
Jarek P.

PS: And this one time it's not a joke... I really mean it.
