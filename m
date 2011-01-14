From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH v4 06/10] ARM: mx28: update clock and device name for
 dual fec support
Date: Fri, 14 Jan 2011 14:46:27 +0800
Message-ID: <20110114064626.GB14491@freescale.com>
References: <1294297998-26930-1-git-send-email-shawn.guo@freescale.com>
 <1294297998-26930-7-git-send-email-shawn.guo@freescale.com>
 <20110113150622.GV24920@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <gerg@snapgear.com>, <baruch@tkos.co.il>,
	<eric@eukrea.com>, <bryan.wu@canonical.com>,
	<r64343@freescale.com>, <B32542@freescale.com>,
	<lw@karo-electronics.de>, <w.sang@pengutronix.de>,
	<s.hauer@pengutronix.de>, <jamie@jamieiles.com>,
	<jamie@shareable.org>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe001.messaging.microsoft.com ([65.55.88.11]:49386 "EHLO
	TX2EHSOBE001.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132Ab1ANGna convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 01:43:30 -0500
Received: from mail182-tx2 (localhost.localdomain [127.0.0.1])	by
 mail182-tx2-R.bigfish.com (Postfix) with ESMTP id D53E213682F6	for
 <netdev@vger.kernel.org>; Fri, 14 Jan 2011 06:43:28 +0000 (UTC)
Received: from TX2EHSMHS037.bigfish.com (unknown [10.9.14.252])	by
 mail182-tx2.bigfish.com (Postfix) with ESMTP id A1A271270052	for
 <netdev@vger.kernel.org>; Fri, 14 Jan 2011 06:43:28 +0000 (UTC)
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by de01egw02.freescale.net (8.14.3/8.14.3) with ESMTP id p0E6hRfg004057	for
 <netdev@vger.kernel.org>; Thu, 13 Jan 2011 23:43:27 -0700 (MST)
Received: from ubuntu.localdomain (ubuntu-010192242196.ap.freescale.net
 [10.192.242.196])	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id
 p0E6hQNI005697	for <netdev@vger.kernel.org>; Fri, 14 Jan 2011 00:43:26 -0600
 (CST)
Content-Disposition: inline
In-Reply-To: <20110113150622.GV24920@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Uwe,

On Thu, Jan 13, 2011 at 04:06:22PM +0100, Uwe Kleine-K=F6nig wrote:
> Hi Shawn,
>=20
> On Thu, Jan 06, 2011 at 03:13:14PM +0800, Shawn Guo wrote:
> > Change device name from "fec" to "imx28-fec", so that fec driver
> > can distinguish mx28.
> >=20
> > Signed-off-by: Shawn Guo <shawn.guo@freescale.com>
> > ---
> > Changes for v4:
> >  - Use "imx28-fec" as fec device name
> >=20
> > Changes for v3:
> >  - Change device name to "enet-mac"
> >=20
> >  arch/arm/mach-mxs/clock-mx28.c           |    3 ++-
> >  arch/arm/mach-mxs/devices/platform-fec.c |    2 +-
> >  2 files changed, 3 insertions(+), 2 deletions(-)
> >=20
> > diff --git a/arch/arm/mach-mxs/clock-mx28.c b/arch/arm/mach-mxs/clo=
ck-mx28.c
> > index f20b254..e2a8b0f 100644
> > --- a/arch/arm/mach-mxs/clock-mx28.c
> > +++ b/arch/arm/mach-mxs/clock-mx28.c
> > @@ -606,7 +606,8 @@ static struct clk_lookup lookups[] =3D {
> >  	_REGISTER_CLOCK("duart", "apb_pclk", xbus_clk)
> >  	/* for amba-pl011 driver */
> >  	_REGISTER_CLOCK("duart", NULL, uart_clk)
> > -	_REGISTER_CLOCK("fec.0", NULL, fec_clk)
> > +	_REGISTER_CLOCK("imx28-fec.0", NULL, fec_clk)
> > +	_REGISTER_CLOCK("imx28-fec.1", NULL, fec_clk)
> >  	_REGISTER_CLOCK("rtc", NULL, rtc_clk)
> >  	_REGISTER_CLOCK("pll2", NULL, pll2_clk)
> >  	_REGISTER_CLOCK(NULL, "hclk", hbus_clk)
> > diff --git a/arch/arm/mach-mxs/devices/platform-fec.c b/arch/arm/ma=
ch-mxs/devices/platform-fec.c
> > index c08168c..c42dff7 100644
> > --- a/arch/arm/mach-mxs/devices/platform-fec.c
> > +++ b/arch/arm/mach-mxs/devices/platform-fec.c
> > @@ -45,6 +45,6 @@ struct platform_device *__init mxs_add_fec(
> >  		},
> >  	};
> > =20
> > -	return mxs_add_platform_device("fec", data->id,
> > +	return mxs_add_platform_device("imx28-fec", data->id,
> IMHO "imx28-fec" shouldn't be hard coded here but come from data.  Se=
e
> imx-spi device registration for an example.
>=20
Sascha has merged the patch, so I will send a follow-up patch.

--=20
Regards,
Shawn

