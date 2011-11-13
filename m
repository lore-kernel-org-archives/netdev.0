From: Richard Zhao <richard.zhao@linaro.org>
Subject: Re: [PATCH 1/1] net: fec: convert to clk_prepare/clk_unprepare
Date: Sun, 13 Nov 2011 11:34:33 +0800
Message-ID: <20111113033427.GC2425@richard-laptop>
References: <1320901304-13157-1-git-send-email-richard.zhao@linaro.org>
 <20111112124939.GJ5011@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, kernel@pengutronix.de,
	shawn.guo@linaro.org, eric.miao@linaro.org
To: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:63949 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918Ab1KMDfr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Nov 2011 22:35:47 -0500
Received: by iage36 with SMTP id e36so5748514iag.19
        for <netdev@vger.kernel.org>; Sat, 12 Nov 2011 19:35:46 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20111112124939.GJ5011@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Uwe,
On Sat, Nov 12, 2011 at 01:49:39PM +0100, Uwe Kleine-K=F6nig wrote:
> Hello Richard,
>=20
> On Thu, Nov 10, 2011 at 01:01:44PM +0800, Richard Zhao wrote:
> > Signed-off-by: Richard Zhao <richard.zhao@linaro.org>
> > ---
> >  drivers/net/ethernet/freescale/fec.c |    5 +++++
> >  1 files changed, 5 insertions(+), 0 deletions(-)
> >=20
> > diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/eth=
ernet/freescale/fec.c
> > index 1124ce0..92e3585 100644
> > --- a/drivers/net/ethernet/freescale/fec.c
> > +++ b/drivers/net/ethernet/freescale/fec.c
> > @@ -1588,6 +1588,7 @@ fec_probe(struct platform_device *pdev)
> >  		ret =3D PTR_ERR(fep->clk);
> >  		goto failed_clk;
> >  	}
> > +	clk_prepare(fep->clk);
> What about error checking?
The goal of the patch is migrating to the new generic clock framework.
If the original driver has error check of clk_enable, I also added erro=
r check of
clk_prepare. And I've sent out new version patch, which use clk_prepare=
_enable.

Richard
>=20
> Best regards
> Uwe
>=20
> --=20
> Pengutronix e.K.                           | Uwe Kleine-K=F6nig      =
      |
> Industrial Linux Solutions                 | http://www.pengutronix.d=
e/  |
