From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: ipcomp regression in 2.6.24
Date: Fri, 8 Feb 2008 10:12:25 +0100
Message-ID: <BAY103-DAV366423029E541B55E047CB22F0@phx.gbl>
References: <BAY103-DAV76D55A34FB3E0924FF49AB2350@phx.gbl><E1JK3QD-0006hM-00@gondolin.me.apana.org.au> <20080129.211227.160323820.davem@davemloft.net>
Cc: <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc2-s25.bay0.hotmail.com ([65.54.246.161]:58246 "EHLO
	bay0-omc2-s25.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761017AbYBHJNG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 04:13:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:

> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Wed, 30 Jan 2008 14:15:33 +1100
>
> > Marco Berizzi <pupilla@hotmail.com> wrote:
> > >
> > >> > With 2.6.24 IPSEC/ESP tunnels to older kernels establish fine,
data
> > >> > flows in both directions, but no data comes out of the tunnel.
> > >> > Needed to disable ipcomp.
> > >
> > > Same problem here: linux 2.6.24 driven by openswan 2.4.11
> > > on Slackware 11.0
> >
> > My bad.  This patch should fix it.
> >
> > [IPCOMP]: Fetch nexthdr before ipch is destroyed
> >
> > When I moved the nexthdr setting out of IPComp I accidently moved
> > the reading of ipch->nexthdr after the decompression.  Unfortunately
> > this means that we'd be reading from a stale ipch pointer which
> > doesn't work very well.
> >
> > This patch moves the reading up so that we get the correct nexthdr
> > value.
> >
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>
> Applied, and queued for -stable, thanks!

Hi David,
I haven't seen this patch in Greg 2.6.24-stable
review message.


