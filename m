From: Roman Zippel <zippel@linux-m68k.org>
Subject: Re: [PATCH 1/3] WAN Kconfig: change "depends on HDLC" to "select"
Date: Mon, 7 May 2007 03:44:37 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0705070343330.2733@scrub.home>
References: <m3abwhcy74.fsf@maximus.localdomain> <m3y7k1biov.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jeff@garzik.org>, Russell King <rmk@arm.linux.org.uk>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753607AbXEGBow@vger.kernel.org>
In-Reply-To: <m3y7k1biov.fsf@maximus.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Mon, 7 May 2007, Krzysztof Halasa wrote:

> Allow enabling WAN drivers without selecting generic HDLC first,
> HDLC will be selected automatically.
> 
> Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>
> 
> diff --git a/drivers/net/wan/Kconfig b/drivers/net/wan/Kconfig
> index 8897f53..3a2fe82 100644
> --- a/drivers/net/wan/Kconfig
> +++ b/drivers/net/wan/Kconfig
> @@ -171,7 +171,8 @@ comment "X.25/LAPB support is disabled"
>  
>  config PCI200SYN
>  	tristate "Goramo PCI200SYN support"
> -	depends on HDLC && PCI
> +	depends on PCI
> +	select HDLC
>  	help
>  	  Driver for PCI200SYN cards by Goramo sp. j.
>  

What's the advantage? The HDLC option is directly before this?

bye, Roman
