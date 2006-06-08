From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: [PATCH 5/5] ehea: makefile and Kconfig
Date: Thu, 8 Jun 2006 09:21:10 -0700
Message-ID: <20060608092110.a12e6594.rdunlap@xenotime.net>
References: <4487F435.7090007@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, meder@de.ibm.com, raisch@de.ibm.com,
	themann@de.ibm.com, tklein@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:15508 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S964901AbWFHQS1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 12:18:27 -0400
Received: from midway.site ([71.245.102.105]) by xenotime.net for <netdev@vger.kernel.org>; Thu, 8 Jun 2006 09:18:22 -0700
To: Jan-Bernd Themann <ossthema@de.ibm.com>
In-Reply-To: <4487F435.7090007@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 08 Jun 2006 11:56:05 +0200 Jan-Bernd Themann wrote:

> Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>
> 
> 
>   drivers/net/ehea/Kconfig  |    6 ++++++
>   drivers/net/ehea/Makefile |    7 +++++++
>   2 files changed, 13 insertions(+)
> 
> 
> 
> --- linux-2.6.16-rc5-orig/drivers/net/ehea/Makefile	1969-12-31 16:00:00.000000000 -0800
> +++ kernel/drivers/net/ehea/Makefile	2006-06-08 01:58:28.839212488 -0700
> @@ -0,0 +1,7 @@
> +#
> +# Makefile for the eHEA ethernet device driver for IBM eServer System p
> +#
> +
> +ehea_mod-objs = ehea_main.o ehea_phyp.o ehea_qmr.o ehea_ethtool.o ehea_phyp.o
> +obj-$(CONFIG_EHEA) += ehea_mod.o
> +
> --- linux-2.6.16-rc5-orig/drivers/net/ehea/Kconfig	1969-12-31 16:00:00.000000000 -0800
> +++ kernel/drivers/net/ehea/Kconfig	2006-06-08 01:58:28.842212032 -0700
> @@ -0,0 +1,6 @@
> +config EHEA
> +       tristate "eHEA Ethernet support"
> +       depends on IBMEBUS
> +       ---help---
> +       This driver supports the IBM pSeries ethernet adapter
> +

Hi,
Will you be modifying drivers/net/Makefile and drivers/net/Kconfig
to use these files?

And "help" text is normally indented (convention is 2 spaces)
since (from Documentation/kbuild/kconfig-language.txt):

  The end of the help text is determined by
  the indentation level, this means it ends at the first line which has
  a smaller indentation than the first line of the help text.

---
~Randy
