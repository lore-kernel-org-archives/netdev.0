From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH 05/31] net: at91_ether: use dev_get_platdata()
Date: Fri, 30 Aug 2013 09:53:55 +0200
Message-ID: <52204F93.8050400@atmel.com>
References: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com> <005701cea53f$70f6fac0$52e4f040$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Jingoo Han <jg1.han@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.242]:50963 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752453Ab3H3Hx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 03:53:59 -0400
In-Reply-To: <005701cea53f$70f6fac0$52e4f040$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30/08/2013 07:11, Jingoo Han :
> Use the wrapper function for retrieving the platform data instead of
> accessing dev->platform_data directly. This is a cosmetic change
> to make the code simpler and enhance the readability.
>
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

> ---
>   drivers/net/ethernet/cadence/at91_ether.c |    2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
> index bb5d63f..ce75de9 100644
> --- a/drivers/net/ethernet/cadence/at91_ether.c
> +++ b/drivers/net/ethernet/cadence/at91_ether.c
> @@ -304,7 +304,7 @@ MODULE_DEVICE_TABLE(of, at91ether_dt_ids);
>   /* Detect MAC & PHY and perform ethernet interface initialization */
>   static int __init at91ether_probe(struct platform_device *pdev)
>   {
> -	struct macb_platform_data *board_data = pdev->dev.platform_data;
> +	struct macb_platform_data *board_data = dev_get_platdata(&pdev->dev);
>   	struct resource *regs;
>   	struct net_device *dev;
>   	struct phy_device *phydev;
>


-- 
Nicolas Ferre
