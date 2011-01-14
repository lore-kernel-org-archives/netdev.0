From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH v5] ARM: mx28: add the second fec device registration
Date: Fri, 14 Jan 2011 15:04:02 +0800
Message-ID: <20110114070401.GC14491@freescale.com>
References: <1294297998-26930-1-git-send-email-shawn.guo@freescale.com>
 <1294747764-4499-1-git-send-email-shawn.guo@freescale.com>
 <20110113144900.GT24920@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <s.hauer@pengutronix.de>, <davem@davemloft.net>,
	<gerg@snapgear.com>, <baruch@tkos.co.il>, <eric@eukrea.com>,
	<bryan.wu@canonical.com>, <r64343@freescale.com>,
	<B32542@freescale.com>, <lw@karo-electronics.de>,
	<w.sang@pengutronix.de>, <jamie@jamieiles.com>,
	<jamie@shareable.org>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe001.messaging.microsoft.com ([216.32.180.11]:37228
	"EHLO VA3EHSOBE001.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752429Ab1ANHBG convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jan 2011 02:01:06 -0500
Received: from mail34-va3 (localhost.localdomain [127.0.0.1])	by
 mail34-va3-R.bigfish.com (Postfix) with ESMTP id 485FB18C06BE	for
 <netdev@vger.kernel.org>; Fri, 14 Jan 2011 07:01:05 +0000 (UTC)
Received: from VA3EHSMHS010.bigfish.com (unknown [10.7.14.243])	by
 mail34-va3.bigfish.com (Postfix) with ESMTP id 04FF7E0050	for
 <netdev@vger.kernel.org>; Fri, 14 Jan 2011 07:01:04 +0000 (UTC)
Received: from az33smr02.freescale.net (az33smr02.freescale.net
 [10.64.34.200])	by de01egw02.freescale.net (8.14.3/8.14.3) with ESMTP id
 p0E712g6004644	for <netdev@vger.kernel.org>; Fri, 14 Jan 2011 00:01:03 -0700
 (MST)
Received: from ubuntu.localdomain (ubuntu-010192242196.ap.freescale.net
 [10.192.242.196])	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id
 p0E7117Y011924	for <netdev@vger.kernel.org>; Fri, 14 Jan 2011 01:01:01 -0600
 (CST)
Content-Disposition: inline
In-Reply-To: <20110113144900.GT24920@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Uwe,

On Thu, Jan 13, 2011 at 03:49:00PM +0100, Uwe Kleine-K=F6nig wrote:
> On Tue, Jan 11, 2011 at 08:09:24PM +0800, Shawn Guo wrote:
> > Signed-off-by: Shawn Guo <shawn.guo@freescale.com>
> > ---
> > Changes for v5:
> >  - Do not use CONFIG_FEC2 which is a fec driver configration
> >=20
> >  arch/arm/mach-mxs/mach-mx28evk.c |   26 +++++++++++++++++++++++---
> >  1 files changed, 23 insertions(+), 3 deletions(-)
> >=20
> > diff --git a/arch/arm/mach-mxs/mach-mx28evk.c b/arch/arm/mach-mxs/m=
ach-mx28evk.c
> > index d162e95..8e2c597 100644
> > --- a/arch/arm/mach-mxs/mach-mx28evk.c
> > +++ b/arch/arm/mach-mxs/mach-mx28evk.c
> > @@ -57,6 +57,19 @@ static const iomux_cfg_t mx28evk_pads[] __initco=
nst =3D {
> >  		(MXS_PAD_8MA | MXS_PAD_3V3 | MXS_PAD_PULLUP),
> >  	MX28_PAD_ENET_CLK__CLKCTRL_ENET |
> >  		(MXS_PAD_8MA | MXS_PAD_3V3 | MXS_PAD_PULLUP),
> > +	/* fec1 */
> > +	MX28_PAD_ENET0_CRS__ENET1_RX_EN |
> > +		(MXS_PAD_8MA | MXS_PAD_3V3 | MXS_PAD_PULLUP),
> > +	MX28_PAD_ENET0_RXD2__ENET1_RXD0 |
> > +		(MXS_PAD_8MA | MXS_PAD_3V3 | MXS_PAD_PULLUP),
> > +	MX28_PAD_ENET0_RXD3__ENET1_RXD1 |
> > +		(MXS_PAD_8MA | MXS_PAD_3V3 | MXS_PAD_PULLUP),
> > +	MX28_PAD_ENET0_COL__ENET1_TX_EN |
> > +		(MXS_PAD_8MA | MXS_PAD_3V3 | MXS_PAD_PULLUP),
> > +	MX28_PAD_ENET0_TXD2__ENET1_TXD0 |
> > +		(MXS_PAD_8MA | MXS_PAD_3V3 | MXS_PAD_PULLUP),
> > +	MX28_PAD_ENET0_TXD3__ENET1_TXD1 |
> > +		(MXS_PAD_8MA | MXS_PAD_3V3 | MXS_PAD_PULLUP),
> >  	/* phy power line */
> >  	MX28_PAD_SSP1_DATA3__GPIO_2_15 |
> >  		(MXS_PAD_4MA | MXS_PAD_3V3 | MXS_PAD_NOPULL),
> > @@ -106,8 +119,14 @@ static void __init mx28evk_fec_reset(void)
> >  	gpio_set_value(MX28EVK_FEC_PHY_RESET, 1);
> >  }
> > =20
> > -static const struct fec_platform_data mx28_fec_pdata __initconst =3D=
 {
> > -	.phy =3D PHY_INTERFACE_MODE_RMII,
> > +static struct fec_platform_data mx28_fec_pdata[] =3D {
> this can still be initdata, doesn't it?
>=20
Sascha has merged the patch.  This one line change may not deserve
a separate patch, so I will take care of it when updating the file
with new version of ocotp patch.

--=20
Regards,
Shawn

