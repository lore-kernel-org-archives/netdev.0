From: Bill Fink <billfink@mindspring.com>
Subject: Re: [net-2.6 PATCH 3/10] Neterion: New driver: Kconfig and Makefile
Date: Sat, 14 Mar 2009 13:40:17 -0400
Message-ID: <20090314134017.d0ec1024.billfink@mindspring.com>
References: <1237018842.4966.418.camel@flash>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>
To: ram.vepa@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66]:36776
	"EHLO elasmtp-spurfowl.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752909AbZCNRkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 13:40:24 -0400
In-Reply-To: <1237018842.4966.418.camel@flash>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14 Mar 2009, Ramkrishna Vepa wrote:

> - Kconfig and Makefile related changes for vxge driver.
> 
> Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
> Signed-off-by: Rastapur Santosh <santosh.rastapur@neterion.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
> ---
> diff -urpN patch_2/drivers/net/Kconfig patch_3/drivers/net/Kconfig
> --- patch_2/drivers/net/Kconfig	2009-03-12 11:23:32.000000000 -0700
> +++ patch_3/drivers/net/Kconfig	2009-03-12 11:33:06.000000000 -0700
> @@ -2531,6 +2531,24 @@ config S2IO
>  	  More specific information on configuring the driver is in 
>  	  <file:Documentation/networking/s2io.txt>.
> 
> +config VXGE
> +	tristate "Neterion X3100 Series 10GbE PCIe Server Adapter"
> +	depends on PCI
> +	select INET_LRO
> +	---help---
> +	  This driver supports Neterion Inc's X3100 Series 10 GbE PCIe
> +	  I/O Virtualized Server Adapter.
> +	  More specific information on configuring the driver is in
> +	  <file:Documentation/networking/vxge.txt>.

To prevent certain build failures, when you "select INET_LRO" you also
need to add a depends on INET, so the above "depends on PCI" needs to
be changed to:

	depends on PCI && INET

						-Bill
