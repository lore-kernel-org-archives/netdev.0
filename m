From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch 23/32] IPV4: Correct rp_filter help text.
Date: Sat, 9 Jun 2007 11:22:08 +1000
Message-ID: <20070609012208.GA31945@gondor.apana.org.au>
References: <20070608071553.469107000@sous-sol.org> <E1HwpdD-0008Il-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, davej@redhat.com
To: Chris Wright <chrisw@sous-sol.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3401 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753196AbXFIBWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2007 21:22:12 -0400
Content-Disposition: inline
In-Reply-To: <E1HwpdD-0008Il-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 09, 2007 at 11:20:43AM +1000, Herbert Xu wrote:
> Chris Wright <chrisw@sous-sol.org> wrote:
> > 
> > --- linux-2.6.20.13.orig/net/ipv4/Kconfig
> > +++ linux-2.6.20.13/net/ipv4/Kconfig
> > @@ -43,11 +43,11 @@ config IP_ADVANCED_ROUTER
> >          asymmetric routing (packets from you to a host take a different path
> >          than packets from that host to you) or if you operate a non-routing
> >          host which has several IP addresses on different interfaces. To turn
> > -         rp_filter off use:
> > +         rp_filter on use:
> > 
> > -         echo 0 > /proc/sys/net/ipv4/conf/<device>/rp_filter
> > +         echo 1 > /proc/sys/net/ipv4/conf/<device>/rp_filter
> >          or
> > -         echo 0 > /proc/sys/net/ipv4/conf/all/rp_filter
> > +         echo 1 > /proc/sys/net/ipv4/conf/all/rp_filter
> 
> BTW, this documentation is actually wrong.  You can't enable rp_filter

So to fix the documentation, we should change the word "or" to "and".

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
