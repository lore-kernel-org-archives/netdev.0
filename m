From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [NET-NEXT PATCH 29/29] ixgbe: fix DCA dependency in Kconfig
Date: Sat, 13 Sep 2008 15:30:42 -0400
Message-ID: <48CC14E2.5000001@garzik.org>
References: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com> <20080912030558.6234.82574.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50160 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752765AbYIMTar (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 15:30:47 -0400
In-Reply-To: <20080912030558.6234.82574.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> ixgbe can depend on dca IF it is enabled.  So if we are compiled as
> IXGBE=y, and DCA is enabled, then we must force INTEL_IOATDMA and therefore
> DCA to be =y also.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  drivers/net/Kconfig |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 8831d13..826e556 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2380,6 +2380,7 @@ config EHEA
>  config IXGBE
>  	tristate "Intel(R) 10GbE PCI Express adapters support"
>  	depends on PCI && INET
> +	select INTEL_IOATDMA

applied 1-29


