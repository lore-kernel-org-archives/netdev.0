From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [UPDATED PATCH] net: kconfig cleanup
Date: Mon, 03 Nov 2008 15:26:12 -0500
Message-ID: <490F5E64.6030207@garzik.org>
References: <20081103043033.13607.2028.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Andrew Gallatin <gallatin@myri.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49695 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754113AbYKCU0R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 15:26:17 -0500
In-Reply-To: <20081103043033.13607.2028.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> The bool kconfig option added to ixgbe and myri10ge for DCA is ambigous,
> so this patch adds a description to the kconfig option.
> 
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> CC: Andrew Gallatin <gallatin@myri.com>
> ---
> 
>  drivers/net/Kconfig |   18 +++++++++++++++---
>  1 files changed, 15 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index f749b40..11f143f 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2010,9 +2010,13 @@ config IGB_LRO
>  	  If in doubt, say N.
>  
>  config IGB_DCA
> -	bool "Enable DCA"
> +	bool "Direct Cache Access (DCA) Support"
>  	default y
>  	depends on IGB && DCA && !(IGB=y && DCA=m)
> +	---help---
> +	  Say Y here if you want to use Direct Cache Access (DCA) in the
> +	  driver.  DCA is a method for warming the CPU cache before data
> +	  is used, with the intent of lessening the impact of cache misses.
>  
>  source "drivers/net/ixp2000/Kconfig"
>  
> @@ -2437,9 +2441,13 @@ config IXGBE
>  	  will be called ixgbe.
>  
>  config IXGBE_DCA
> -	bool
> +	bool "Direct Cache Access (DCA) Support"
>  	default y
>  	depends on IXGBE && DCA && !(IXGBE=y && DCA=m)
> +	---help---
> +	  Say Y here if you want to use Direct Cache Access (DCA) in the
> +	  driver.  DCA is a method for warming the CPU cache before data
> +	  is used, with the intent of lessening the impact of cache misses.
>  
>  config IXGB
>  	tristate "Intel(R) PRO/10GbE support"
> @@ -2489,9 +2497,13 @@ config MYRI10GE
>  	  will be called myri10ge.
>  
>  config MYRI10GE_DCA
> -	bool
> +	bool "Direct Cache Access (DCA) Support"
>  	default y
>  	depends on MYRI10GE && DCA && !(MYRI10GE=y && DCA=m)
> +	---help---
> +	  Say Y here if you want to use Direct Cache Access (DCA) in the
> +	  driver.  DCA is a method for warming the CPU cache before data
> +	  is used, with the intent of lessening the impact of cache misses.
>  

applied


