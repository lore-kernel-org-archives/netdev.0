From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH 02/21] net: 3c59x: use common rx_copybreak handling
Date: Sun, 10 Jul 2011 01:23:39 +0200
Message-ID: <20110709232339.GA15588@rere.qmqm.pl>
References: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
 <5a242c5dbd6222d87b77a22b9c6fe6cdfa0351f3.1310229312.git.mirq-linux@rere.qmqm.pl>
 <20110709222258.GA5642@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:59198 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753371Ab1GIXXl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2011 19:23:41 -0400
Content-Disposition: inline
In-Reply-To: <20110709222258.GA5642@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 10, 2011 at 12:22:58AM +0200, Francois Romieu wrote:
> Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl> :
> [...]
> > diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
> > index 8cc2256..456726c 100644
> > --- a/drivers/net/3c59x.c
> > +++ b/drivers/net/3c59x.c
> [...]
> > +			skb =3D dev_skb_finish_rx_dma(&vp->rx_skbuff[entry],
> > +				pkt_len, rx_copybreak,
> > +				&VORTEX_PCI(vp)->dev, dma, PKT_BUF_SZ);
> > +			if (skb)
> s/if (skb)/if (vp->rx_skbuff[entry])/ probably

=46or this driver and via-velocity - you're right (fixed). For others n=
o -
they always refill the rx ring, possibly discarding the packet.

Best Regards,
Micha=B3 Miros=B3aw
