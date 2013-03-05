From: "Ferre, Nicolas" <Nicolas.FERRE@atmel.com>
Subject: RE : [PATCH 3/3] net: macb: Use module_platform_driver_probe macro
Date: Tue, 5 Mar 2013 09:36:32 +0000
Message-ID: <EABCC4A72A203F4BA2E04297CF0282C427C4F0C1@hnombx01.corp.atmel.com>
References: <1362457882-12892-1-git-send-email-sachin.kamat@linaro.org>,<1362457882-12892-3-git-send-email-sachin.kamat@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>
To: Sachin Kamat <sachin.kamat@linaro.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.243]:31168 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755838Ab3CEJgg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 04:36:36 -0500
In-Reply-To: <1362457882-12892-3-git-send-email-sachin.kamat@linaro.org>
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
>  drivers/net/ethernet/cadence/macb.c |   13 +------------
>  1 files changed, 1 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index 7903943..3a5d680 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -1737,18 +1737,7 @@ static struct platform_driver macb_driver = {
>         },
>  };
> 
> -static int __init macb_init(void)
> -{
> -       return platform_driver_probe(&macb_driver, macb_probe);
> -}
> -
> -static void __exit macb_exit(void)
> -{
> -       platform_driver_unregister(&macb_driver);
> -}
> -
> -module_init(macb_init);
> -module_exit(macb_exit);
> +module_platform_driver_probe(macb_driver, macb_probe);
> 
>  MODULE_LICENSE("GPL");
>  MODULE_DESCRIPTION("Cadence MACB/GEM Ethernet driver");
> --
> 1.7.4.1
> 