From: Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>
Subject: Re: [PATCH 6/6] PMC MSP85x0 gigabit ethernet driver
Date: Mon, 26 Jun 2006 15:18:46 +0900
Message-ID: <20060626151846.39281449.yoichi_yuasa@tripeaks.co.jp>
References: <C28979E4F697C249ABDA83AC0C33CDF8143EFB@sjc1exm07.pmc_nt.nt.pmc-sierra.bc.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org,
	Rajesh_Palani@pmc-sierra.com, ralf@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo31.po.2iij.net ([210.128.50.54]:9799 "EHLO mo31.po.2iij.net")
	by vger.kernel.org with ESMTP id S1751159AbWFZGSx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2006 02:18:53 -0400
To: Kiran Thota <Kiran_Thota@pmc-sierra.com>
In-Reply-To: <C28979E4F697C249ABDA83AC0C33CDF8143EFB@sjc1exm07.pmc_nt.nt.pmc-sierra.bc.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Kiran,

On Fri, 23 Jun 2006 19:19:00 -0700
Kiran Thota <Kiran_Thota@pmc-sierra.com> wrote:

>  
> - Based on linux-2.6.12 from http://www.linux-mips.org/pub/linux/mips/kernel/v2.6/linux-2.6.12.tar.gz
> - Rewritten clean driver for PMC MSP85x0 gigabit ethernet driver (planning a rewritten titan driver) \
>   source, Kconfig and makefile. Will remove dependency on TITAN_GE flag with future titan driver.
> 
>  
> Signed-off-by: Kiran Kumar Thota <Kiran_Thota@pmc-sierra.com>
> 
> diff -Naur a/drivers/net/Kconfig b/drivers/net/Kconfig
> --- a/drivers/net/Kconfig	2005-07-11 11:28:10.000000000 -0700
> +++ b/drivers/net/Kconfig	2006-06-22 11:48:21.000000000 -0700
> @@ -2098,7 +2098,7 @@
>  
>  config TITAN_GE
>  	bool "PMC-Sierra TITAN Gigabit Ethernet Support"
> -	depends on PMC_YOSEMITE
> +	depends on PMC_YOSEMITE || PMC_SEQUOIA
>  	help
>  	  This enables support for the the integrated ethernet of
>  	  PMC-Sierra's Titan SoC.
> diff -Naur a/drivers/net/Makefile b/drivers/net/Makefile
> --- a/drivers/net/Makefile	2005-07-11 11:28:10.000000000 -0700
> +++ b/drivers/net/Makefile	2006-06-22 11:48:21.000000000 -0700
> @@ -103,7 +103,8 @@
>  obj-$(CONFIG_GALILEO_64240_ETH) += gt64240eth.o
>  obj-$(CONFIG_MV64340_ETH) += mv64340_eth.o
>  obj-$(CONFIG_BIG_SUR_FE) += big_sur_ge.o
> -obj-$(CONFIG_TITAN_GE) += titan_mdio.o titan_ge.o
> +obj-$(CONFIG_PMC_SEQUOIA) += titan_mdio.o msp85x0_ge.o
> +#obj-$(CONFIG_TITAN_GE) += titan_mdio.o titan_ge.o
>  
>  obj-$(CONFIG_PPP) += ppp_generic.o slhc.o
>  obj-$(CONFIG_PPP_ASYNC) += ppp_async.o

I think that you shold add a new config for msp85x0_ge.

Yoichi
