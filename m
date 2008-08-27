From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/1] netdev: Blackfin EMAC Driver: the BF526 also supports
 the MAC, so updates things accordingly
Date: Wed, 27 Aug 2008 05:18:03 -0400
Message-ID: <48B51BCB.60402@garzik.org>
References: <1219808877-15168-1-git-send-email-cooloney@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mike Frysinger <vapier.adi@gmail.com>
To: Bryan Wu <cooloney@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45216 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752903AbYH0JSH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 05:18:07 -0400
In-Reply-To: <1219808877-15168-1-git-send-email-cooloney@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bryan Wu wrote:
> From: Mike Frysinger <vapier.adi@gmail.com>
> 
> Signed-off-by: Mike Frysinger <vapier.adi@gmail.com>
> Signed-off-by: Bryan Wu <cooloney@kernel.org>
> ---
>  drivers/net/Kconfig |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index a5c141c..4a11296 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -822,14 +822,14 @@ config ULTRA32
>  	  will be called smc-ultra32.
>  
>  config BFIN_MAC
> -	tristate "Blackfin 527/536/537 on-chip mac support"
> -	depends on NET_ETHERNET && (BF527 || BF537 || BF536)
> +	tristate "Blackfin on-chip MAC support"
> +	depends on NET_ETHERNET && (BF526 || BF527 || BF536 || BF537)
>  	select CRC32
>  	select MII
>  	select PHYLIB
>  	select BFIN_MAC_USE_L1 if DMA_UNCACHED_NONE
>  	help
> -	  This is the driver for blackfin on-chip mac device. Say Y if you want it
> +	  This is the driver for Blackfin on-chip mac device. Say Y if you want it
>  	  compiled into the kernel. This driver is also available as a module
>  	  ( = code which can be inserted in and removed from the running kernel
>  	  whenever you want). The module will be called bfin_mac.

applied

