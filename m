From: Brad Boyer <flar@allandria.com>
Subject: Re: [PATCH 11/13] mac68k: macmace fixes
Date: Sat, 17 Mar 2007 08:30:54 -0700
Message-ID: <20070317153054.GC14763@cynthia.pants.nu>
References: <Pine.LNX.4.64.0703171732250.4875@loopy.telegraphics.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-m68k@vger.kernel.org
To: Finn Thain <fthain@telegraphics.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from adsl-216-102-214-42.dsl.snfc21.pacbell.net ([216.102.214.42]:37707
	"EHLO cynthia.pants.nu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752462AbXCQR2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2007 13:28:55 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0703171732250.4875@loopy.telegraphics.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 17, 2007 at 08:08:33PM +1100, Finn Thain wrote:
> Index: linux-2.6.20/drivers/net/Kconfig
> ===================================================================
> --- linux-2.6.20.orig/drivers/net/Kconfig	2007-03-06 19:22:38.000000000 +1100
> +++ linux-2.6.20/drivers/net/Kconfig	2007-03-06 20:15:52.000000000 +1100
> @@ -347,8 +347,8 @@ config MACSONIC
>  	  be called macsonic.
>  
>  config MACMACE
> -	bool "Macintosh (AV) onboard MACE ethernet (EXPERIMENTAL)"
> -	depends on NET_ETHERNET && MAC && EXPERIMENTAL
> +	bool "Macintosh (AV) onboard MACE ethernet"
> +	depends on NET_ETHERNET && MAC
>  	select CRC32
>  	help
>  	  Support for the onboard AMD 79C940 MACE Ethernet controller used in

Have you tried making this a tristate option? It looked like the code
had all the proper hooks to be built as a module, but it currently
isn't allowed by the Kconfig.

	Brad Boyer
	flar@allandria.com

