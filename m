From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] ip1000: menu location change
Date: Sat, 12 Jan 2008 17:41:41 -0500
Message-ID: <47894225.6070606@pobox.com>
References: <20080101092758.59bd5665@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51099 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758952AbYALWlv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jan 2008 17:41:51 -0500
In-Reply-To: <20080101092758.59bd5665@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> Move the ip1000 driver into the expected place for gigabit cards
> in the configuration menu structure. It should be under the gigabit
> cards, not at the top level.
> 
> Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>
> 
> --- a/drivers/net/Kconfig	2007-12-26 20:17:31.000000000 -0800
> +++ b/drivers/net/Kconfig	2007-12-26 20:18:36.000000000 -0800
> @@ -166,16 +166,6 @@ config NET_SB1000
>  
>  	  If you don't have this card, of course say N.
>  
> -config IP1000
> -	tristate "IP1000 Gigabit Ethernet support"
> -	depends on PCI && EXPERIMENTAL
> -	select MII
> -	---help---
> -	  This driver supports IP1000 gigabit Ethernet cards.
> -
> -	  To compile this driver as a module, choose M here: the module
> -	  will be called ipg.  This is recommended.
> -
>  source "drivers/net/arcnet/Kconfig"
>  
>  source "drivers/net/phy/Kconfig"
> @@ -2004,6 +1994,16 @@ config E1000E
>  	  To compile this driver as a module, choose M here. The module
>  	  will be called e1000e.
>  
> +config IP1000
> +	tristate "IP1000 Gigabit Ethernet support"
> +	depends on PCI && EXPERIMENTAL
> +	select MII
> +	---help---
> +	  This driver supports IP1000 gigabit Ethernet cards.
> +
> +	  To compile this driver as a module, choose M here: the module
> +	  will be called ipg.  This is recommended.
> +
>  source "drivers/net/ixp2000/Kconfig"

applied


