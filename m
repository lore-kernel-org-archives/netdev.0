From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 03/41]bnx2x: MSI support
Date: Thu, 12 Feb 2009 18:52:38 +0000
Message-ID: <1234464759.3583.8.camel@achroite>
References: <1234463775.1863.134.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:38431 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750742AbZBLSwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 13:52:47 -0500
In-Reply-To: <1234463775.1863.134.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-02-12 at 20:36 +0200, Eilon Greenstein wrote:
[...]
> diff --git a/drivers/net/bnx2x_reg.h b/drivers/net/bnx2x_reg.h
> index fc957fa..0be77c5 100644
> --- a/drivers/net/bnx2x_reg.h
> +++ b/drivers/net/bnx2x_reg.h
> @@ -745,6 +745,7 @@
>  #define DORQ_REG_SHRT_CMHEAD					 0x170054
>  #define HC_CONFIG_0_REG_ATTN_BIT_EN_0				 (0x1<<4)
>  #define HC_CONFIG_0_REG_INT_LINE_EN_0				 (0x1<<3)
> +#define HC_CONFIG_0_REG_MSI_ATTN_EN_0				 (0x1<<7)
>  #define HC_CONFIG_0_REG_MSI_MSIX_INT_EN_0			 (0x1<<2)
>  #define HC_CONFIG_0_REG_SINGLE_ISR_EN_0 			 (0x1<<1)
>  #define HC_REG_AGG_INT_0					 0x108050
> @@ -5359,9 +5360,28 @@
>  #define PCICFG_PM_CSR_STATE			(0x3<<0)
>  #define PCICFG_PM_CSR_PME_ENABLE		(1<<8)
>  #define PCICFG_PM_CSR_PME_STATUS		(1<<15)
> +#define PCICFG_MSI_CAP_ID				0x58

This appears to be a capability offset, not a capability id!  You might
also consider not hard-coding it.

> +#define PCICFG_MSI_CONTROL_ENABLE		(0x1<<16)
> +#define PCICFG_MSI_CONTROL_MCAP 		(0x7<<17)
> +#define PCICFG_MSI_CONTROL_MENA 		(0x7<<20)
> +#define PCICFG_MSI_CONTROL_64_BIT_ADDR_CAP	(0x1<<23)
> +#define PCICFG_MSI_CONTROL_MSI_PVMASK_CAPABLE	(0x1<<24)
>  #define PCICFG_GRC_ADDRESS				0x78
>  #define PCICFG_GRC_DATA 				0x80
> +#define PCICFG_MSIX_CAP_ID				0xa0
[...]

Similarly for this.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

