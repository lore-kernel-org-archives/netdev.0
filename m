From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH v4 08/10] ARM: mxs: add ocotp read function
Date: Fri, 14 Jan 2011 09:33:20 +0100
Message-ID: <20110114083320.GK26617@pengutronix.de>
References: <1294297998-26930-1-git-send-email-shawn.guo@freescale.com>
 <1294297998-26930-9-git-send-email-shawn.guo@freescale.com>
 <20110113151939.GX24920@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shawn Guo <shawn.guo@freescale.com>, gerg@snapgear.com,
	B32542@freescale.com, netdev@vger.kernel.org, jamie@shareable.org,
	baruch@tkos.co.il, w.sang@pengutronix.de, r64343@freescale.com,
	eric@eukrea.com, bryan.wu@canonical.com, jamie@jamieiles.com,
	davem@davemloft.net, linux-arm-kernel@lists.infradead.org,
	lw@karo-electronics.de
To: Uwe =?iso-8859-15?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:53341 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341Ab1ANIdW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 03:33:22 -0500
Content-Disposition: inline
In-Reply-To: <20110113151939.GX24920@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 13, 2011 at 04:19:39PM +0100, Uwe Kleine-K=F6nig wrote:
> On Thu, Jan 06, 2011 at 03:13:16PM +0800, Shawn Guo wrote:
> > Signed-off-by: Shawn Guo <shawn.guo@freescale.com>
> > ---
> > Changes for v4:
> >  - Call cpu_relax() during polling
> >=20
> > Changes for v2:
> >  - Add mutex locking for mxs_read_ocotp()
> >  - Use type size_t for count and i
> >  - Add comment for clk_enable/disable skipping
> >  - Add ERROR bit clearing and polling step
> >=20
> >  arch/arm/mach-mxs/Makefile              |    2 +-
> >  arch/arm/mach-mxs/include/mach/common.h |    1 +
> >  arch/arm/mach-mxs/ocotp.c               |   79 +++++++++++++++++++=
++++++++++++
> >  3 files changed, 81 insertions(+), 1 deletions(-)
> >  create mode 100644 arch/arm/mach-mxs/ocotp.c
> >=20
> > diff --git a/arch/arm/mach-mxs/Makefile b/arch/arm/mach-mxs/Makefil=
e
> > index 39d3f9c..f23ebbd 100644
> > --- a/arch/arm/mach-mxs/Makefile
> > +++ b/arch/arm/mach-mxs/Makefile
> > @@ -1,5 +1,5 @@
> >  # Common support
> > -obj-y :=3D clock.o devices.o gpio.o icoll.o iomux.o system.o timer=
=2Eo
> > +obj-y :=3D clock.o devices.o gpio.o icoll.o iomux.o ocotp.o system=
=2Eo timer.o
> is it worth to make ocotp optional?  (and let evk select
> CONFIG_MXS_OCOTP)

I think not.

Sascha

--=20
Pengutronix e.K.                           |                           =
  |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0  =
  |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-555=
5 |
