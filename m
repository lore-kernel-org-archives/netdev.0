From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH net-next 2/3] at91_ether: Do not select NET_CORE
Date: Tue, 18 Jun 2013 09:55:40 +0200
Message-ID: <51C0127C.2070508@atmel.com>
References: <1371522107.3495.61.camel@deadeye.wl.decadent.org.uk> <1371522449.3495.65.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Joachim Eastwood <manabian@gmail.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.243]:4332 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752309Ab3FRHzl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jun 2013 03:55:41 -0400
In-Reply-To: <1371522449.3495.65.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/06/2013 04:27, Ben Hutchings :
> This has no dependency on any of the drivers under NET_CORE.
>
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Thanks, bye,

> ---
>   drivers/net/ethernet/cadence/Kconfig |    1 -
>   1 file changed, 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/cadence/Kconfig b/drivers/net/ethernet/cadence/Kconfig
> index 768285e..8030cc0 100644
> --- a/drivers/net/ethernet/cadence/Kconfig
> +++ b/drivers/net/ethernet/cadence/Kconfig
> @@ -23,7 +23,6 @@ if NET_CADENCE
>   config ARM_AT91_ETHER
>   	tristate "AT91RM9200 Ethernet support"
>   	depends on GENERIC_HARDIRQS && HAS_DMA
> -	select NET_CORE
>   	select MACB
>   	---help---
>   	  If you wish to compile a kernel for the AT91RM9200 and enable
>
>


-- 
Nicolas Ferre
