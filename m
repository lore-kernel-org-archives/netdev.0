From: Matt Mackall <mpm@selenic.com>
Subject: Re: [patch 12/12] Configure out ethtool support
Date: Wed, 30 Jul 2008 18:05:02 -0500
Message-ID: <1217459102.18911.182.camel@calx>
References: <200807301939.m6UJd5lT012610@imap1.linux-foundation.org>
	 <20080730.143532.124324888.davem@davemloft.net>
	 <1217456666.18911.145.camel@calx>
	 <20080730.153758.91676696.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, jeff@garzik.org, netdev@vger.kernel.org,
	thomas.petazzoni@free-electrons.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:36859 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752392AbYG3XHr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2008 19:07:47 -0400
In-Reply-To: <20080730.153758.91676696.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2008-07-30 at 15:37 -0700, David Miller wrote:
> From: Matt Mackall <mpm@selenic.com>
> Date: Wed, 30 Jul 2008 17:24:26 -0500
>=20
> >=20
> > On Wed, 2008-07-30 at 14:35 -0700, David Miller wrote:
> > > This change means you can't configure nearly all of the features =
on
> > > your ethernet card.  You can't even configure the link parameters
> > > without ethtool support.
> >=20
> > Which is big fat don't-care for the vast majority of users. =EF=BB=BF=
=EF=BB=BFVarious
> > popular distros don't even install the tool by default.
>=20
> Are you even aware that the ethtool layer gets invoked by simply
> enabling IP forwarding or bridgining, in order to disable LRO
> offloading which conflicts with such uses?

Oh noes. How ever will my poor webcam get on the internets without that=
=2E

Again, most users don't use forwarding or bridging, nor do they have
LRO. Again, doubly so for embedded devices. Your remark about
CONFIG_INET is pure hyperbole.

> And I disagree with your asserion that the tool doesn't get installed
> by default by distros.  I can't find one single system here that
> doesn't have /usr/sbin/ethtool available.
>=20
> I guess it depends upon your definition of "various".

I've got a vanilla Debian install here for starters.

--=20
Mathematics is the supreme nostalgia of our time.

