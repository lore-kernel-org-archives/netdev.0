From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/2] net: fec: default select FEC_PTP at mx6 platform
Date: Wed, 7 Nov 2012 18:58:16 +0000
Message-ID: <1352314696.2725.13.camel@bwh-desktop.uk.solarflarecom.com>
References: <1352268883-16800-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <lznuaa@gmail.com>, <richardcochran@gmail.com>,
	<shawn.guo@linaro.org>, <linux-arm-kernel@lists.infradead.or>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>
To: Frank Li <Frank.Li@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:46253 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751284Ab2KGS6U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 13:58:20 -0500
In-Reply-To: <1352268883-16800-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-11-07 at 14:14 +0800, Frank Li wrote:
> Remove PPS.
> Limit FEC_PTP option for i.MX chip only.
> FEC_PTP default is on at mx6 platform.
> 
> Signed-off-by: Frank Li <Frank.Li@freescale.com>
Acked-by: Ben Hutchings <bhutchings@solarflare.com>

Looks sensible, though I know nothing about the hardware dependencies.

Ben.

> ---
>  drivers/net/ethernet/freescale/Kconfig |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/Kconfig b/drivers/net/ethernet/freescale/Kconfig
> index ff3be53..5ba6e1c 100644
> --- a/drivers/net/ethernet/freescale/Kconfig
> +++ b/drivers/net/ethernet/freescale/Kconfig
> @@ -94,9 +94,9 @@ config GIANFAR
>  
>  config FEC_PTP
>  	bool "PTP Hardware Clock (PHC)"
> -	depends on FEC
> -	select PPS
> +	depends on FEC && ARCH_MXC
>  	select PTP_1588_CLOCK
> +	default y if SOC_IMX6Q
>  	--help---
>  	  Say Y here if you want to use PTP Hardware Clock (PHC) in the
>  	  driver.  Only the basic clock operations have been implemented.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
