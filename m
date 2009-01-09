From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH 01/16] dma-debug: add Kconfig entry
Date: Fri, 9 Jan 2009 12:12:25 -0800
Message-ID: <20090109121225.a0b4bbee.randy.dunlap@oracle.com>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com>
	<1231517970-20288-2-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com,
	dwmw2@infradead.org, fujita.tomonori@lab.ntt.co.jp,
	netdev@vger.kernel.org, iommu@lists.linux-foundation.org
To: Joerg Roedel <joerg.roedel@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:20172 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752926AbZAIUNV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 15:13:21 -0500
In-Reply-To: <1231517970-20288-2-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 9 Jan 2009 17:19:15 +0100 Joerg Roedel wrote:

> Impact: add a Kconfig entry for DMA-API debugging

Surely Impact: is (meant to be) different from the actual patch description... ?


> Signed-off-by: Joerg Roedel <joerg.roedel@amd.com>
> ---
>  arch/Kconfig      |    2 ++
>  lib/Kconfig.debug |   11 +++++++++++
>  2 files changed, 13 insertions(+), 0 deletions(-)
> 
> diff --git a/arch/Kconfig b/arch/Kconfig
> index 2e13aa2..068554c 100644
> --- a/arch/Kconfig
> +++ b/arch/Kconfig
> @@ -103,3 +103,5 @@ config HAVE_CLK
>  	  The <linux/clk.h> calls support software clock gating and
>  	  thus are a key power management tool on many systems.
>  
> +config HAVE_DMA_API_DEBUG
> +	bool
> diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
> index 2e75478..cba5778 100644
> --- a/lib/Kconfig.debug
> +++ b/lib/Kconfig.debug
> @@ -899,6 +899,17 @@ config DYNAMIC_PRINTK_DEBUG
>  	  debugging for all modules. This mode can be turned off via the above
>  	  disable command.
>  
> +config DMA_API_DEBUG
> +	bool "Enable debugging of DMA-API usage"
> +	depends on HAVE_DMA_API_DEBUG
> +	help
> +	  Enable this option to debug the use of the DMA API by device drivers.
> +	  With this option you will be able to detect common bugs in device
> +	  drivers like double-freeing of DMA mappings or freeing mappings that
> +	  were never allocated.
> +	  This option causes a performance degredation.  Use only if you want
> +	  to debug device drivers. If unsure, say N.
> +
>  source "samples/Kconfig"
>  
>  source "lib/Kconfig.kgdb"
> -- 

---
~Randy
