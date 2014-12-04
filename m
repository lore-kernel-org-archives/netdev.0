From: Lokesh Vutla <lokeshvutla@ti.com>
Subject: Re: [PATCH] drivers: net : cpsw: Update Kconfig for CPSW
Date: Thu, 4 Dec 2014 10:22:47 +0530
Message-ID: <547FE89F.10701@ti.com>
References: <1417668484-25327-1-git-send-email-lokeshvutla@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <mugunthanvnm@ti.com>, <linux-omap@vger.kernel.org>,
	<grygorii.strashko@ti.com>, <balbi@ti.com>, <nsekhar@ti.com>,
	<t-kristo@ti.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:57536 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751911AbaLDEyJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2014 23:54:09 -0500
In-Reply-To: <1417668484-25327-1-git-send-email-lokeshvutla@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
Please discard this patch. Missed adding something.
Will be posting an updated patch.
Sorry for the spam.

Thanks and regards,
Lokesh
On Thursday 04 December 2014 10:18 AM, Lokesh Vutla wrote:
> CPSW is present in AM33xx, AM43xx, DRA7xx.
> Updating the Kconfig to depend on ARCH_OMAP2PLUS instead of listing
> all SoC's.
> 
> Signed-off-by: Lokesh Vutla <lokeshvutla@ti.com>
> ---
>  drivers/net/ethernet/ti/Kconfig | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kconfig
> index 5d8cb79..7051255 100644
> --- a/drivers/net/ethernet/ti/Kconfig
> +++ b/drivers/net/ethernet/ti/Kconfig
> @@ -5,7 +5,7 @@
>  config NET_VENDOR_TI
>  	bool "Texas Instruments (TI) devices"
>  	default y
> -	depends on PCI || EISA || AR7 || (ARM && (ARCH_DAVINCI || ARCH_OMAP3 || SOC_AM33XX || ARCH_KEYSTONE))
> +	depends on PCI || EISA || AR7 || ARCH_OMAP2PLUS || ARCH_KEYSTONE
>  	---help---
>  	  If you have a network (Ethernet) card belonging to this class, say Y
>  	  and read the Ethernet-HOWTO, available from
> @@ -32,7 +32,7 @@ config TI_DAVINCI_EMAC
>  
>  config TI_DAVINCI_MDIO
>  	tristate "TI DaVinci MDIO Support"
> -	depends on ARM && ( ARCH_DAVINCI || ARCH_OMAP3 || SOC_AM33XX || ARCH_KEYSTONE )
> +	depends on ARCH_DAVINCI || ARCH_OMAP2PLUS || ARCH_KEYSTONE
>  	select PHYLIB
>  	---help---
>  	  This driver supports TI's DaVinci MDIO module.
> @@ -42,7 +42,7 @@ config TI_DAVINCI_MDIO
>  
>  config TI_DAVINCI_CPDMA
>  	tristate "TI DaVinci CPDMA Support"
> -	depends on ARM && ( ARCH_DAVINCI || ARCH_OMAP3 || SOC_AM33XX )
> +	depends on ARCH_DAVINCI || ARCH_OMAP2PLUS
>  	---help---
>  	  This driver supports TI's DaVinci CPDMA dma engine.
>  
> @@ -58,7 +58,7 @@ config TI_CPSW_PHY_SEL
>  
>  config TI_CPSW
>  	tristate "TI CPSW Switch Support"
> -	depends on ARM && (ARCH_DAVINCI || SOC_AM33XX)
> +	depends on ARCH_DAVINCI || ARCH_OMAP2PLUS
>  	select TI_DAVINCI_CPDMA
>  	select TI_DAVINCI_MDIO
>  	select TI_CPSW_PHY_SEL
> 
