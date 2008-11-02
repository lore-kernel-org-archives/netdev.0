From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] net: kconfig cleanup
Date: Sun, 02 Nov 2008 08:36:03 -0500
Message-ID: <490DACC3.2050203@garzik.org>
References: <20081031074143.25532.6078.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Andrew Gallatin <gallatin@myri.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50364 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752715AbYKBNgI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Nov 2008 08:36:08 -0500
In-Reply-To: <20081031074143.25532.6078.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> The bool kconfig option added to ixgbe and myri10ge for DCA is ambigous, so this
> patch adds a description to the kconfig option.
> 
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> CC: Andrew Gallatin <gallatin@myri.com>
> ---
> 
>  drivers/net/Kconfig |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index f749b40..b13a7ff 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2437,7 +2437,7 @@ config IXGBE
>  	  will be called ixgbe.
>  
>  config IXGBE_DCA
> -	bool
> +	bool "Enable DCA"
>  	default y
>  	depends on IXGBE && DCA && !(IXGBE=y && DCA=m)
>  
> @@ -2489,7 +2489,7 @@ config MYRI10GE
>  	  will be called myri10ge.
>  
>  config MYRI10GE_DCA
> -	bool
> +	bool "Enable DCA"
>  	default y
>  	depends on MYRI10GE && DCA && !(MYRI10GE=y && DCA=m)

If you're gonna do that, please add useful help text for the user who 
has no idea what this means.  (IGB_DCA needs this as well)

	Jeff



