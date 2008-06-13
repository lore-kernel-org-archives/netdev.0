From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] [UPDATED] ixgbe: add LRO support
Date: Fri, 13 Jun 2008 11:45:55 -0700
Message-ID: <20080613114555.4955f666.randy.dunlap@oracle.com>
References: <20080613183716.9641.33945.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:61235 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752214AbYFMSqp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2008 14:46:45 -0400
In-Reply-To: <20080613183716.9641.33945.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Jun 2008 11:40:16 -0700 Jeff Kirsher wrote:

> From: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> 
> Support for in-kernel LRO with the ability to enable/disable via ethtool
> based on comments from Ben Hutchings and Randy Dunlap.
> 
> Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> ---
> 
>  drivers/net/Kconfig               |    3 +
>  drivers/net/ixgbe/ixgbe.h         |    9 +++
>  drivers/net/ixgbe/ixgbe_ethtool.c |   11 ++++
>  drivers/net/ixgbe/ixgbe_main.c    |  111 ++++++++++++++++++++++++++++++-------
>  4 files changed, 112 insertions(+), 22 deletions(-)
> 
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index f4182cf..8b53255 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2436,7 +2436,8 @@ config EHEA
>  
>  config IXGBE
>  	tristate "Intel(R) 10GbE PCI Express adapters support"
> -	depends on PCI
> +	depends on PCI && INET
> +	select INET_LRO
>  	---help---
>  	  This driver supports Intel(R) 10GbE PCI Express family of
>  	  adapters.  For more information on how to identify your adapter, go

Yes, thanks.

---
~Randy
'"Daemon' is an old piece of jargon from the UNIX operating system,
where it referred to a piece of low-level utility software, a
fundamental part of the operating system."
