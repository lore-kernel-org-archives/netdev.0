From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/4] forcedeth: add vitesse phy
Date: Thu, 24 May 2007 17:54:50 -0400
Message-ID: <465609AA.8020906@garzik.org>
References: <465237D5.4050809@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48445 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750957AbXEXVzH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 May 2007 17:55:07 -0400
In-Reply-To: <465237D5.4050809@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ayaz Abdulla wrote:
> This patch adds errata support for the vitesse phy.
> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>
> 
> 
> ------------------------------------------------------------------------
> 
> --- old/drivers/net/forcedeth.c	2007-05-01 15:30:53.000000000 -0400
> +++ new/drivers/net/forcedeth.c	2007-05-01 15:30:57.000000000 -0400
> @@ -550,6 +550,7 @@
>  /* PHY defines */
>  #define PHY_OUI_MARVELL	0x5043
>  #define PHY_OUI_CICADA	0x03f1
> +#define PHY_OUI_VITESSE	0x01c1
>  #define PHYID1_OUI_MASK	0x03ff
>  #define PHYID1_OUI_SHFT	6
>  #define PHYID2_OUI_MASK	0xfc00
> @@ -557,12 +558,29 @@
>  #define PHYID2_MODEL_MASK		0x03f0
>  #define PHY_MODEL_MARVELL_E3016		0x220
>  #define PHY_MARVELL_E3016_INITMASK	0x0300
> -#define PHY_INIT1	0x0f000
> -#define PHY_INIT2	0x0e00
> -#define PHY_INIT3	0x01000
> -#define PHY_INIT4	0x0200
> -#define PHY_INIT5	0x0004
> -#define PHY_INIT6	0x02000
> +#define PHY_CICADA_INIT1	0x0f000
> +#define PHY_CICADA_INIT2	0x0e00
> +#define PHY_CICADA_INIT3	0x01000
> +#define PHY_CICADA_INIT4	0x0200
> +#define PHY_CICADA_INIT5	0x0004
> +#define PHY_CICADA_INIT6	0x02000

Please split this into two patches:

1) rename PHY_INIT symbols to PHY_CICADA_INIT

2) add vitesse phy errata workarounds

otherwise, looks OK


