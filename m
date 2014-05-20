From: "Frank.Li@freescale.com" <Frank.Li@freescale.com>
Subject: RE: [PATCH 2/2] net: fec: correct the MDIO clock source
Date: Tue, 20 May 2014 13:13:18 +0000
Message-ID: <406c6a63a9b246f7a9a9fc4b9026796d@BLUPR03MB486.namprd03.prod.outlook.com>
References: <1400563389-3599-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"fugang.duan@freescale.com" <fugang.duan@freescale.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: "fugang.duan@freescale.com" <fugang.duan@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0205.outbound.protection.outlook.com ([207.46.163.205]:39362
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753668AbaETNNc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2014 09:13:32 -0400
In-Reply-To: <1400563389-3599-1-git-send-email-b38611@freescale.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Fugang Duan [mailto:b38611@freescale.com]
> Sent: Tuesday, May 20, 2014 12:23 AM
> To: Li Frank-B20596; davem@davemloft.net
> Cc: netdev@vger.kernel.org; Duan Fugang-B38611; bhutchings@solarflare.com;
> stephen@networkplumber.org
> Subject: [PATCH 2/2] net: fec: correct the MDIO clock source
> 
> Since imx serials FEC/ENET MDIO clock source is internal ipg clock, and
> "ahb" clock is defined as FEC/ENET bus clock, so the patch just correct
> the fec driver MDIO clock source.
> 
> Signed-off-by: Fugang Duan <B38611@freescale.com>

Acked-by: Frank Li <frank.li@freescale.com>

> ---
>  drivers/net/ethernet/freescale/fec_main.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec_main.c
> b/drivers/net/ethernet/freescale/fec_main.c
> index 99fb0dc..cb5c987 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -1407,7 +1407,7 @@ static int fec_enet_mii_init(struct platform_device
> *pdev)
>  	 * Reference Manual has an error on this, and gets fixed on i.MX6Q
>  	 * document.
>  	 */
> -	fep->phy_speed = DIV_ROUND_UP(clk_get_rate(fep->clk_ahb), 5000000);
> +	fep->phy_speed = DIV_ROUND_UP(clk_get_rate(fep->clk_ipg), 5000000);
>  	if (id_entry->driver_data & FEC_QUIRK_ENET_MAC)
>  		fep->phy_speed--;
>  	fep->phy_speed <<= 1;
> --
> 1.7.8
