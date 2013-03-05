From: "Ferre, Nicolas" <Nicolas.FERRE@atmel.com>
Subject: RE : [PATCH 2/3] net: at91_ether: Use module_platform_driver_probe
 macro
Date: Tue, 5 Mar 2013 09:41:53 +0000
Message-ID: <EABCC4A72A203F4BA2E04297CF0282C427C4F4D2@hnombx01.corp.atmel.com>
References: <1362457882-12892-1-git-send-email-sachin.kamat@linaro.org>,<1362457882-12892-2-git-send-email-sachin.kamat@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>
To: Sachin Kamat <sachin.kamat@linaro.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.242]:32015 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755522Ab3CEJlz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 04:41:55 -0500
In-Reply-To: <1362457882-12892-2-git-send-email-sachin.kamat@linaro.org>
Content-Language: fr-FR
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> module_platform_driver_probe() eliminates the boilerplate and simplifies
> the code.
> 
> Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
> Cc: Nicolas Ferre <nicolas.ferre@atmel.com>

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

> ---
>  drivers/net/ethernet/cadence/at91_ether.c |   13 +------------
>  1 files changed, 1 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
> index 3becdb2..1a57e16 100644
> --- a/drivers/net/ethernet/cadence/at91_ether.c
> +++ b/drivers/net/ethernet/cadence/at91_ether.c
> @@ -519,18 +519,7 @@ static struct platform_driver at91ether_driver = {
>         },
>  };
> 
> -static int __init at91ether_init(void)
> -{
> -       return platform_driver_probe(&at91ether_driver, at91ether_probe);
> -}
> -
> -static void __exit at91ether_exit(void)
> -{
> -       platform_driver_unregister(&at91ether_driver);
> -}
> -
> -module_init(at91ether_init)
> -module_exit(at91ether_exit)
> +module_platform_driver_probe(at91ether_driver, at91ether_probe);
> 
>  MODULE_LICENSE("GPL");
>  MODULE_DESCRIPTION("AT91RM9200 EMAC Ethernet driver");
> --
> 1.7.4.1
> 