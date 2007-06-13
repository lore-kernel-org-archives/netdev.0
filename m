From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: ps3: gigabit ethernet driver for PS3
Date: Wed, 13 Jun 2007 00:03:59 -0700 (PDT)
Message-ID: <20070613.000359.112622353.davem@davemloft.net>
References: <20070613154156.71DB.MOKUNO@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	geoffrey.levand@am.sony.com, Geert.Uytterhoeven@sonycom.com
To: mokuno@sm.sony.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54961
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754695AbXFMHDn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 03:03:43 -0400
In-Reply-To: <20070613154156.71DB.MOKUNO@sm.sony.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: MOKUNO Masakazu <mokuno@sm.sony.co.jp>
Date: Wed, 13 Jun 2007 15:58:01 +0900

> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -60,6 +60,8 @@ obj-$(CONFIG_TIGON3) += tg3.o
>  obj-$(CONFIG_BNX2) += bnx2.o
>  spidernet-y += spider_net.o spider_net_ethtool.o
>  obj-$(CONFIG_SPIDER_NET) += spidernet.o sungem_phy.o
> +obj-$(CONFIG_GELIC_NET) += ps3_gelic.o
> +ps3_gelic-objs += gelic_net.o
>  obj-$(CONFIG_TC35815) += tc35815.o
>  obj-$(CONFIG_SKGE) += skge.o
>  obj-$(CONFIG_SKY2) += sky2.o

Please just name the driver ps3_galic.c and use a single

obj-$(CONFIG_GELIC_NET) += ps3_galic.o

line in the Makefile.
