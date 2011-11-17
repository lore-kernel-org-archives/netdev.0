From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH 1/1] net/cadence: enable by default NET_ATMEL
Date: Thu, 17 Nov 2011 09:56:28 +0100
Message-ID: <4EC4CC3C.5040106@atmel.com>
References: <1321385790-15056-1-git-send-email-plagnioj@jcrosoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1321385790-15056-1-git-send-email-plagnioj@jcrosoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/15/2011 08:36 PM, Jean-Christophe PLAGNIOL-VILLARD :
> so the defconfig of the atmel continue to have the support of the network
> as before
> 
> Signed-off-by: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
> Cc: Nicolas Ferre <nicolas.ferre@atmel.com>

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

> ---
> Hi David,
> 
> 	can we have this for the 3.2 so the atmel continue to work as before
> 
> Best Regards,
> J.
>  drivers/net/ethernet/cadence/Kconfig |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cadence/Kconfig b/drivers/net/ethernet/cadence/Kconfig
> index 98849a1..b48378a 100644
> --- a/drivers/net/ethernet/cadence/Kconfig
> +++ b/drivers/net/ethernet/cadence/Kconfig
> @@ -7,6 +7,7 @@ config HAVE_NET_MACB
>  
>  config NET_ATMEL
>  	bool "Atmel devices"
> +	default y
>  	depends on HAVE_NET_MACB || (ARM && ARCH_AT91RM9200)
>  	---help---
>  	  If you have a network (Ethernet) card belonging to this class, say Y.


-- 
Nicolas Ferre
