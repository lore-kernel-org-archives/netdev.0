From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH 1/1] net: fec: convert to clk_prepare/clk_unprepare
Date: Sat, 12 Nov 2011 13:49:39 +0100
Message-ID: <20111112124939.GJ5011@pengutronix.de>
References: <1320901304-13157-1-git-send-email-richard.zhao@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, kernel@pengutronix.de,
	shawn.guo@linaro.org, eric.miao@linaro.org
To: Richard Zhao <richard.zhao@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:44566 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752596Ab1KLMtn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Nov 2011 07:49:43 -0500
Content-Disposition: inline
In-Reply-To: <1320901304-13157-1-git-send-email-richard.zhao@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Richard,

On Thu, Nov 10, 2011 at 01:01:44PM +0800, Richard Zhao wrote:
> Signed-off-by: Richard Zhao <richard.zhao@linaro.org>
> ---
>  drivers/net/ethernet/freescale/fec.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ether=
net/freescale/fec.c
> index 1124ce0..92e3585 100644
> --- a/drivers/net/ethernet/freescale/fec.c
> +++ b/drivers/net/ethernet/freescale/fec.c
> @@ -1588,6 +1588,7 @@ fec_probe(struct platform_device *pdev)
>  		ret =3D PTR_ERR(fep->clk);
>  		goto failed_clk;
>  	}
> +	clk_prepare(fep->clk);
What about error checking?

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
