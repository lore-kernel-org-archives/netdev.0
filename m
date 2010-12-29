From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH 03/10] net/fec: add mac field into platform data and
	consolidate fec_get_mac
Date: Wed, 29 Dec 2010 13:42:21 +0100
Message-ID: <20101229124220.GD14221@pengutronix.de>
References: <1293548155-16328-1-git-send-email-shawn.guo@freescale.com> <1293548155-16328-4-git-send-email-shawn.guo@freescale.com> <20101229065329.GB31010@jasper.tkos.co.il> <20101229100520.GB19347@freescale.com> <20101229103138.GT14221@pengutronix.de> <20101229115808.GF19347@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Baruch Siach <baruch@tkos.co.il>, davem@davemloft.net,
	gerg@snapgear.com, eric@eukrea.com, bryan.wu@canonical.com,
	r64343@freescale.com, B32542@freescale.com, lw@karo-electronics.de,
	w.sang@pengutronix.de, s.hauer@pengutronix.de,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Shawn Guo <shawn.guo@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:56209 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752096Ab0L2Mm5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Dec 2010 07:42:57 -0500
Content-Disposition: inline
In-Reply-To: <20101229115808.GF19347@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Shawn,

On Wed, Dec 29, 2010 at 07:58:09PM +0800, Shawn Guo wrote:
> On Wed, Dec 29, 2010 at 11:31:38AM +0100, Uwe Kleine-K=F6nig wrote:
> > On Wed, Dec 29, 2010 at 06:05:21PM +0800, Shawn Guo wrote:
> > > On Wed, Dec 29, 2010 at 08:53:30AM +0200, Baruch Siach wrote:
> > > 	if (iap =3D=3D fec_mac_default)
> > > 		dev->dev_addr[ETH_ALEN-1] =3D fec_mac_default[ETH_ALEN-1] + fep=
->pdev->id;
> > Can this overflow?  (I didn't check the code, so my concern might b=
e
> > completely stupid here.)
> No. dev->dev_addr points to netdev_hw_addr->addr, which is a 32 bytes=
 array.
I didn't mean an out-of-bound access, but what is if
fec_mac_default[ETH_ALEN-1] is 0xff and you add 1?  Does that result in
0x100 or 0?  What if id is <0?  For big ids you might even handle a
carry to indixes <ETH_ALEN-2.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
