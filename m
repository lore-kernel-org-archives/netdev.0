From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH v2] net: fec: Select the FEC driver by default for i.MX
 SoCs
Date: Wed, 30 Nov 2011 14:25:36 +0100
Message-ID: <20111130132536.GD26618@pengutronix.de>
References: <1322652717-2685-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel@lists.infradead.org, kernel@pengutronix.de,
	shawn.guo@freescale.com, davem@davemloft.net,
	netdev@vger.kernel.org, marek.vasut@gmail.com
To: Fabio Estevam <fabio.estevam@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:60527 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755592Ab1K3NZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 08:25:46 -0500
Content-Disposition: inline
In-Reply-To: <1322652717-2685-1-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2011 at 09:31:57AM -0200, Fabio Estevam wrote:
> Let the FEC driver be built by default.
>=20
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
Just one small nitpick below. Other than that:

Suggested-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
Acked-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>

> ---
> Changes since v1:=20
> Move the FEC selection into Kconfig instead of .config file
>=20
>  drivers/net/ethernet/freescale/Kconfig |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/freescale/Kconfig b/drivers/net/eth=
ernet/freescale/Kconfig
> index c520cfd..ae269ad 100644
> --- a/drivers/net/ethernet/freescale/Kconfig
> +++ b/drivers/net/ethernet/freescale/Kconfig
> @@ -22,6 +22,7 @@ if NET_VENDOR_FREESCALE
> =20
>  config FEC
>  	bool "FEC ethernet controller (of ColdFire and some i.MX CPUs)"
> +	default ARCH_MXC || ARCH_MXS if ARM
>  	depends on (M523x || M527x || M5272 || M528x || M520x || M532x || \
>  		   ARCH_MXC || ARCH_MXS)
I'd write the depends line first, then default and then select.

Best regards
Uwe

>  	select PHYLIB

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
