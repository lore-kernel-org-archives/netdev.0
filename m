From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH v4 06/10] ARM: mx28: update clock and device name for
 dual fec support
Date: Thu, 13 Jan 2011 16:06:22 +0100
Message-ID: <20110113150622.GV24920@pengutronix.de>
References: <1294297998-26930-1-git-send-email-shawn.guo@freescale.com>
 <1294297998-26930-7-git-send-email-shawn.guo@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, gerg@snapgear.com, baruch@tkos.co.il,
	eric@eukrea.com, bryan.wu@canonical.com, r64343@freescale.com,
	B32542@freescale.com, lw@karo-electronics.de,
	w.sang@pengutronix.de, s.hauer@pengutronix.de, jamie@jamieiles.com,
	jamie@shareable.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Shawn Guo <shawn.guo@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:43739 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756921Ab1AMPGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 10:06:38 -0500
Content-Disposition: inline
In-Reply-To: <1294297998-26930-7-git-send-email-shawn.guo@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Shawn,

On Thu, Jan 06, 2011 at 03:13:14PM +0800, Shawn Guo wrote:
> Change device name from "fec" to "imx28-fec", so that fec driver
> can distinguish mx28.
>=20
> Signed-off-by: Shawn Guo <shawn.guo@freescale.com>
> ---
> Changes for v4:
>  - Use "imx28-fec" as fec device name
>=20
> Changes for v3:
>  - Change device name to "enet-mac"
>=20
>  arch/arm/mach-mxs/clock-mx28.c           |    3 ++-
>  arch/arm/mach-mxs/devices/platform-fec.c |    2 +-
>  2 files changed, 3 insertions(+), 2 deletions(-)
>=20
> diff --git a/arch/arm/mach-mxs/clock-mx28.c b/arch/arm/mach-mxs/clock=
-mx28.c
> index f20b254..e2a8b0f 100644
> --- a/arch/arm/mach-mxs/clock-mx28.c
> +++ b/arch/arm/mach-mxs/clock-mx28.c
> @@ -606,7 +606,8 @@ static struct clk_lookup lookups[] =3D {
>  	_REGISTER_CLOCK("duart", "apb_pclk", xbus_clk)
>  	/* for amba-pl011 driver */
>  	_REGISTER_CLOCK("duart", NULL, uart_clk)
> -	_REGISTER_CLOCK("fec.0", NULL, fec_clk)
> +	_REGISTER_CLOCK("imx28-fec.0", NULL, fec_clk)
> +	_REGISTER_CLOCK("imx28-fec.1", NULL, fec_clk)
>  	_REGISTER_CLOCK("rtc", NULL, rtc_clk)
>  	_REGISTER_CLOCK("pll2", NULL, pll2_clk)
>  	_REGISTER_CLOCK(NULL, "hclk", hbus_clk)
> diff --git a/arch/arm/mach-mxs/devices/platform-fec.c b/arch/arm/mach=
-mxs/devices/platform-fec.c
> index c08168c..c42dff7 100644
> --- a/arch/arm/mach-mxs/devices/platform-fec.c
> +++ b/arch/arm/mach-mxs/devices/platform-fec.c
> @@ -45,6 +45,6 @@ struct platform_device *__init mxs_add_fec(
>  		},
>  	};
> =20
> -	return mxs_add_platform_device("fec", data->id,
> +	return mxs_add_platform_device("imx28-fec", data->id,
IMHO "imx28-fec" shouldn't be hard coded here but come from data.  See
imx-spi device registration for an example.

Uwe
>  			res, ARRAY_SIZE(res), pdata, sizeof(*pdata));
>  }
> --=20
> 1.7.1
>=20
>=20
>=20

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
