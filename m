From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [SAA9730] Fix build error
Date: Wed, 29 Nov 2006 05:44:28 +0100
Message-ID: <20061129044428.GF15364@stusta.de>
References: <20061128173259.GA19092@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:21510 "HELO
	mailout.stusta.mhn.de") by vger.kernel.org with SMTP
	id S1758786AbWK2EoY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Nov 2006 23:44:24 -0500
To: Ralf Baechle <ralf@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <20061128173259.GA19092@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 28, 2006 at 05:32:59PM +0000, Ralf Baechle wrote:
> Confusingly NET_PCI is also set for for non-PCI EISA configurations where
> building this driver will result in a build error due to a reference to
> pci_release_regions.
> 
> While at it, remove the EXPERIMENTAL - in all its uglyness and despite

Please also remove the EXPERIMENTAL from the help text.

> the sincerest attempts of the buggy hardware the driver is known to work
> and limit the driver to the Atlas board - the only known system to ever
> use the SAA9730 before Phillips ended the short live of the SAA9730.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
> 
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 4f22c8e..6b5b745 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -1762,7 +1762,7 @@ config VIA_RHINE_NAPI
>  
>  config LAN_SAA9730
>  	bool "Philips SAA9730 Ethernet support (EXPERIMENTAL)"
> -	depends on NET_PCI && EXPERIMENTAL && MIPS
> +	depends on NET_PCI && PCI && MIPS_ATLAS
>  	help
>  	  The SAA9730 is a combined multimedia and peripheral controller used
>  	  in thin clients, Internet access terminals, and diskless

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

