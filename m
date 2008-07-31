From: Matt Mackall <mpm@selenic.com>
Subject: Re: [patch 12/12] Configure out ethtool support
Date: Wed, 30 Jul 2008 20:10:09 -0500
Message-ID: <1217466609.18911.227.camel@calx>
References: <1217456666.18911.145.camel@calx>
	 <20080730.153758.91676696.davem@davemloft.net>
	 <1217459102.18911.182.camel@calx>
	 <20080730.162153.124485443.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, jeff@garzik.org, netdev@vger.kernel.org,
	thomas.petazzoni@free-electrons.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:54531 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754222AbYGaBNF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2008 21:13:05 -0400
In-Reply-To: <20080730.162153.124485443.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2008-07-30 at 16:21 -0700, David Miller wrote:
> From: Matt Mackall <mpm@selenic.com>
> Date: Wed, 30 Jul 2008 18:05:02 -0500
>=20
> > On Wed, 2008-07-30 at 15:37 -0700, David Miller wrote:
> > > From: Matt Mackall <mpm@selenic.com>
> > > Date: Wed, 30 Jul 2008 17:24:26 -0500
> > >=20
> > > >=20
> > > > On Wed, 2008-07-30 at 14:35 -0700, David Miller wrote:
> > > > > This change means you can't configure nearly all of the featu=
res on
> > > > > your ethernet card.  You can't even configure the link parame=
ters
> > > > > without ethtool support.
> > > >=20
> > > > Which is big fat don't-care for the vast majority of users. =EF=
=BB=BF=EF=BB=BFVarious
> > > > popular distros don't even install the tool by default.
> > >=20
> > > Are you even aware that the ethtool layer gets invoked by simply
> > > enabling IP forwarding or bridgining, in order to disable LRO
> > > offloading which conflicts with such uses?
> >=20
> > Oh noes. How ever will my poor webcam get on the internets without =
that.
>=20
> Have any firewall rules implemented on that webcam?

Of course not. It's a webcam. Or it's a printer or game console or medi=
a
streamer or alarm clock or BluRay player, etc. Yes, I do have a
Linux-powered alarm clock (A Nokia N800) and no, it doesn't have a
firewall.

> It's only a matter of time before other core facilities need
> to use ethtool to adjust the device's settings in one way or
> another.

To which I'll respond that your LRO scheme could have just as easily
been implemented the other way around. That is, the driver could have
been written to not go into LRO mode until the core said "hey, it's saf=
e
to turn on LRO mode now if you happen to have it". Same for
checksumming, etc. Which, in addition to being friendly to
CONFIG_ETHTOOL=3DN, is generally a bit more conservative.

--=20
Mathematics is the supreme nostalgia of our time.

