From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH v4 05/10] net/fec: add dual fec support for mx28
Date: Mon, 17 Jan 2011 10:06:20 +0100
Message-ID: <20110117090620.GN6917@pengutronix.de>
References: <1294297998-26930-1-git-send-email-shawn.guo@freescale.com>
 <1294297998-26930-6-git-send-email-shawn.guo@freescale.com>
 <20110113144805.GS24920@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: gerg@snapgear.com, Greg Ungerer <gerg@uclinux.org>,
	B32542@freescale.com, netdev@vger.kernel.org,
	s.hauer@pengutronix.de, jamie@shareable.org, baruch@tkos.co.il,
	w.sang@pengutronix.de, r64343@freescale.com, eric@eukrea.com,
	bryan.wu@canonical.com, jamie@jamieiles.com, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, lw@karo-electronics.de
To: Shawn Guo <shawn.guo@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:59497 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752238Ab1AQJGW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jan 2011 04:06:22 -0500
Content-Disposition: inline
In-Reply-To: <20110113144805.GS24920@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Thu, Jan 13, 2011 at 03:48:05PM +0100, Uwe Kleine-K=F6nig wrote:
> >  #if defined(CONFIG_M523x) || defined(CONFIG_M527x) || defined(CONF=
IG_M528x) || \
> > -    defined(CONFIG_M520x) || defined(CONFIG_M532x) || defined(CONF=
IG_ARCH_MXC)
> > +    defined(CONFIG_M520x) || defined(CONFIG_M532x) || \
> > +    defined(CONFIG_ARCH_MXC) || defined(CONFIG_SOC_IMX28)
> I wonder what is excluded here.  FEC depends on
>=20
> 	M523x || M527x || M5272 || M528x || M520x || M532x || \
> 	MACH_MX27 || ARCH_MX35 || ARCH_MX25 || ARCH_MX5 || SOC_IMX28
>=20
> so the only difference is that the latter lists M5272 which seems a b=
it
> redundant in the presence of M527x.
M527x =3D {M5271, M5275}, so it seems to me that only M5272 is excluded
here.  I don't know if it's possible to have a kernel supporting M5272
and (e.g.) M527x.  If yes, does the driver work correct on M5272 then?

Greg, it seems to me that M5272 is the exception here, not all the
others.  Would it make sense to make the above read:

	#if !defined(CONFIG_M5272)

?

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
