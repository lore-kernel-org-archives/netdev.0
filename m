From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: ipcomp regression in 2.6.24
Date: Wed, 30 Jan 2008 10:14:46 +0100
Message-ID: <BAY103-DAV204C57458B3E41DE1AA365B2360@phx.gbl>
References: <E1JK3QD-0006hM-00@gondolin.me.apana.org.au>
Cc: <Daniel.Beschorner@facton.com>, <netdev@vger.kernel.org>
To: "Herbert Xu" <herbert@gondor.apana.org.au>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc3-s41.bay0.hotmail.com ([65.54.246.241]:24248 "EHLO
	bay0-omc3-s41.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757417AbYA3JPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 04:15:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:

> Marco Berizzi <pupilla@hotmail.com> wrote:
> >
> >> > With 2.6.24 IPSEC/ESP tunnels to older kernels establish fine,
data
> >> > flows in both directions, but no data comes out of the tunnel.
> >> > Needed to disable ipcomp.
> >
> > Same problem here: linux 2.6.24 driven by openswan 2.4.11
> > on Slackware 11.0
>
> My bad.  This patch should fix it.

Sorry for bother you again.
I have applied to 2.6.24, but ipcomp doesn't work anyway.
I have patched a clean 2.6.24 tree and I did a complete
rebuild.
With tcpdump I see both the esp packets going in/out but
I don't see the clear packets on the interface.


