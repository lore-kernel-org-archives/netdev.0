From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phy: add AT803x driver
Date: Fri, 12 Oct 2012 13:56:02 -0400 (EDT)
Message-ID: <20121012.135602.2001617705161327585.davem@davemloft.net>
References: <1350049656-22766-1-git-send-email-ujhelyi.m@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@zonque.org, rd@radekdostal.com
To: ujhelyi.m@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49404 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759921Ab2JLR4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2012 13:56:05 -0400
In-Reply-To: <1350049656-22766-1-git-send-email-ujhelyi.m@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ujhelyi.m@gmail.com
Date: Fri, 12 Oct 2012 15:47:36 +0200

> From: Matus Ujhelyi <ujhelyi.m@gmail.com>
> 
> This driver add support for wake over lan on AT803x phys.
> 
> Signed-off-by: Matus Ujhelyi <ujhelyi.m@gmail.com>
> ---
>  drivers/net/phy/Kconfig  |    5 ++
>  drivers/net/phy/Makefile |    1 +
>  drivers/net/phy/at803x.c |  176 ++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 182 insertions(+)
>  create mode 100644 drivers/net/phy/at803x.c
> 
> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
> index 3090dc6..e69d74e 100644
> --- a/drivers/net/phy/Kconfig
> +++ b/drivers/net/phy/Kconfig
> @@ -15,6 +15,11 @@ if PHYLIB
>  
>  comment "MII PHY device drivers"
>  
> +config AT803X_PHY
> +	tristate "Drivers for Atheros PHYs"
> +	---help---
> +	  Currently supports the AT8030 and AT8035 model

You should just put the model number into the tristate string.
Like: "Drivers for Atheros AT803X PHYs"
