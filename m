From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] phylib: Don't allow core of phylib to build as a module
Date: Mon, 02 Jun 2008 12:03:58 -0400
Message-ID: <484419EE.5040503@garzik.org>
References: <Pine.LNX.4.64.0806021019540.22439@blarg.am.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Andy Fleming <afleming@freescale.com>
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43871 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753666AbYFBQED (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jun 2008 12:04:03 -0400
In-Reply-To: <Pine.LNX.4.64.0806021019540.22439@blarg.am.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kumar Gala wrote:
> The core portions of the phylib aren't capable of being used as
> a module.  This isn't really any different than something like i2c
> in that the bus driver and core need to be built into the kernel.
> 
> Signed-off-by: Kumar Gala <galak@kernel.crashing.org>
> ---
> 
> Jeff, please consider this for 2.6.26 as w/o it we get build issues
> if phylib is config'd as a module on ppc.
> 
>  drivers/net/phy/Kconfig |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
> index 6eb2d31..ab04cc7 100644
> --- a/drivers/net/phy/Kconfig
> +++ b/drivers/net/phy/Kconfig
> @@ -3,7 +3,7 @@
>  #
> 
>  menuconfig PHYLIB
> -	tristate "PHY Device support and infrastructure"
> +	bool "PHY Device support and infrastructure"
>  	depends on !S390
>  	depends on NET_ETHERNET

What are the issues?

The core _should_ be able to be built as a module.

	Jeff



