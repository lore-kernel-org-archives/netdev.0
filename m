From: Florian Fainelli <ffainelli@freebox.fr>
Subject: Re: [PATCH] phylib: Allow BCM63XX PHY to be selected only on BCM63XX.
Date: Wed, 15 Jun 2011 10:20:11 +0200
Message-ID: <201106151020.11904.ffainelli@freebox.fr>
References: <20110615080758.GA3226@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-mips@linux-mips.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g21.free.fr ([212.27.42.4]:42338 "EHLO smtp4-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753059Ab1FOIQD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jun 2011 04:16:03 -0400
In-Reply-To: <20110615080758.GA3226@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 15 June 2011 10:07:58 Ralf Baechle wrote:
> This PHY is available integrated into BCM63xx series SOCs only.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

Acked-by: Florian Fainelli <ffainelli@freebox.fr>

> 
>  drivers/net/phy/Kconfig |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
> index 392a6c4..a702443 100644
> --- a/drivers/net/phy/Kconfig
> +++ b/drivers/net/phy/Kconfig
> @@ -58,6 +58,7 @@ config BROADCOM_PHY
> 
>  config BCM63XX_PHY
>  	tristate "Drivers for Broadcom 63xx SOCs internal PHY"
> +	depends on BCM63XX
>  	---help---
>  	  Currently supports the 6348 and 6358 PHYs.
