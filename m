From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/3] enic: add Makefile, patch Kconfig, MAINTAINERS, etc
Date: Fri, 12 Sep 2008 19:07:13 +0100
Message-ID: <1221242833.3244.6.camel@achroite>
References: <Pine.LNX.4.64.0809082045200.18196@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:39757 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751788AbYILSHT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2008 14:07:19 -0400
In-Reply-To: <Pine.LNX.4.64.0809082045200.18196@palito_client100.nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-09-08 at 20:57 -0700, Scott Feldman wrote:
> enic: add Makefile, patch Kconfig, MAINTAINERS, etc
> 
> Adds driver/net/enic/Makefile, add the enic (10G Ethernet) option to the 
> net Kconfig.  Add PCI vendor ID for Cisco.  Updates MAINTAINERS to add an 
> entry for the enic driver.
> 
> Signed-off-by: Scott Feldman <scofeldm@cisco.com>
> ---
> diff -Naurp -X linux-2.6.26.3/Documentation/dontdiff linux-2.6.26.3/drivers/net/enic/Makefile linux-2.6.26.3-enic/drivers/net/enic/Makefile
> --- linux-2.6.26.3/drivers/net/enic/Makefile	1969-12-31 16:00:00.000000000 -0800
> +++ linux-2.6.26.3-enic/drivers/net/enic/Makefile	2008-08-22 13:41:41.000000000 -0700

The baseline for your diffs should be David Miller's net-next-2.6 tree.

> @@ -0,0 +1,5 @@
> +obj-$(CONFIG_ENIC) := enic.o
> +
> +enic-y := enic_main.o vnic_cq.o vnic_intr.o vnic_wq.o \
> +	enic_res.o vnic_dev.o vnic_rq.o
> +
> diff -Naurp -X linux-2.6.26.3/Documentation/dontdiff linux-2.6.26.3/drivers/net/Kconfig linux-2.6.26.3-enic/drivers/net/Kconfig
> --- linux-2.6.26.3/drivers/net/Kconfig	2008-08-20 11:11:37.000000000 -0700
> +++ linux-2.6.26.3-enic/drivers/net/Kconfig	2008-08-26 10:43:30.000000000 -0700
> @@ -2527,6 +2527,13 @@ config MYRI10GE
>   	  To compile this driver as a module, choose M here. The module
>   	  will be called myri10ge.
> 
> +config ENIC
> +	tristate "Cisco 10G Ethernet NIC"
> +	depends on PCI && INET
> +	select INET_LRO
> +	help
> +	  This enables the support for Cisco 10G Ethernet card.
> +
>   config NETXEN_NIC
>   	tristate "NetXen Multi port (1/10) Gigabit Ethernet NIC"
>   	depends on PCI
[...]

The leading spaces in the context have been doubled in your mail, so the
patch doesn't apply.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

