From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH net-next] net/cadence: depend on HAS_IOMEM
Date: Mon, 29 Oct 2012 15:48:38 +0100
Message-ID: <508E9746.9030406@atmel.com>
References: <1351339823-24987-1-git-send-email-manabian@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <fengguang.wu@intel.com>,
	<netdev@vger.kernel.org>
To: Joachim Eastwood <manabian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.243]:42067 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759173Ab2J2Nsc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2012 09:48:32 -0400
In-Reply-To: <1351339823-24987-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/27/2012 02:10 PM, Joachim Eastwood :
> Fixes the following build failure on S390:
>   In file included from drivers/net/ethernet/cadence/at91_ether.c:35:0:
>    drivers/net/ethernet/cadence/macb.h: In function 'macb_is_gem':
>    drivers/net/ethernet/cadence/macb.h:563:2: error: implicit declaration of function '__raw_readl' [-Werror=implicit-function-declaration]
>    drivers/net/ethernet/cadence/at91_ether.c: In function 'update_mac_address':
>    drivers/net/ethernet/cadence/at91_ether.c:119:2: error: implicit declaration of function '__raw_writel' [-Werror=implicit-function-declaration]
>    cc1: some warnings being treated as errors
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Joachim Eastwood <manabian@gmail.com>

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

> ---
>  drivers/net/ethernet/cadence/Kconfig | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/ethernet/cadence/Kconfig b/drivers/net/ethernet/cadence/Kconfig
> index 40172d1..ceb0de0 100644
> --- a/drivers/net/ethernet/cadence/Kconfig
> +++ b/drivers/net/ethernet/cadence/Kconfig
> @@ -4,6 +4,7 @@
>  
>  config NET_CADENCE
>  	bool "Cadence devices"
> +	depends on HAS_IOMEM
>  	default y
>  	---help---
>  	  If you have a network (Ethernet) card belonging to this class, say Y.
> 


-- 
Nicolas Ferre
