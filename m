From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH] net: cadence: Fix architecture dependencies
Date: Wed, 23 Apr 2014 17:06:12 +0200
Message-ID: <5357D6E4.1030400@atmel.com>
References: <20140423104012.68f60014@endymion.delvare>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Michal Simek <monstr@monstr.eu>,
	Mark Brown <broonie@kernel.org>
To: Jean Delvare <jdelvare@suse.de>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.242]:39595 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753403AbaDWPGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 11:06:19 -0400
In-Reply-To: <20140423104012.68f60014@endymion.delvare>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/04/2014 10:40, Jean Delvare :
> I was told that the Cadence macb driver is also useful on Microblaze.
> 
> Signed-off-by: Jean Delvare <jdelvare@suse.de>
> Cc: Nicolas Ferre <nicolas.ferre@atmel.com>

then:
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>


> Cc: David S. Miller <davem@davemloft.net>
> Cc: Michal Simek <monstr@monstr.eu>
> Cc: Mark Brown <broonie@kernel.org>
> ---
>  drivers/net/ethernet/cadence/Kconfig |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> --- linux-3.15-rc2.orig/drivers/net/ethernet/cadence/Kconfig	2014-04-22 14:20:30.727102543 +0200
> +++ linux-3.15-rc2/drivers/net/ethernet/cadence/Kconfig	2014-04-23 10:34:44.300548144 +0200
> @@ -4,7 +4,7 @@
>  
>  config NET_CADENCE
>  	bool "Cadence devices"
> -	depends on HAS_IOMEM && (ARM || AVR32 || COMPILE_TEST)
> +	depends on HAS_IOMEM && (ARM || AVR32 || MICROBLAZE || COMPILE_TEST)
>  	default y
>  	---help---
>  	  If you have a network (Ethernet) card belonging to this class, say Y.
> @@ -30,7 +30,7 @@ config ARM_AT91_ETHER
>  
>  config MACB
>  	tristate "Cadence MACB/GEM support"
> -	depends on HAS_DMA && (PLATFORM_AT32AP || ARCH_AT91 || ARCH_PICOXCELL || ARCH_ZYNQ || COMPILE_TEST)
> +	depends on HAS_DMA && (PLATFORM_AT32AP || ARCH_AT91 || ARCH_PICOXCELL || ARCH_ZYNQ || MICROBLAZE || COMPILE_TEST)
>  	select PHYLIB
>  	---help---
>  	  The Cadence MACB ethernet interface is found on many Atmel AT32 and
> 
> 


-- 
Nicolas Ferre
