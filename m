From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] net: hisilicon: new hip04 MDIO driver
Date: Fri, 04 Apr 2014 11:30:10 -0400 (EDT)
Message-ID: <20140404.113010.1212333214715849484.davem@davemloft.net>
References: <1396624597-390-1-git-send-email-zhangfei.gao@linaro.org>
	<1396624597-390-3-git-send-email-zhangfei.gao@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@arm.linux.org.uk, arnd@arndb.de, f.fainelli@gmail.com,
	sergei.shtylyov@cogentembedded.com, mark.rutland@arm.com,
	David.Laight@ACULAB.COM, eric.dumazet@gmail.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: zhangfei.gao@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52473 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753758AbaDDP2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 11:28:35 -0400
In-Reply-To: <1396624597-390-3-git-send-email-zhangfei.gao@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhangfei Gao <zhangfei.gao@linaro.org>
Date: Fri,  4 Apr 2014 23:16:36 +0800

> +config HIP04_ETH
> +	tristate "HISILICON P04 Ethernet support"
> +	select NET_CORE
> +	select PHYLIB
> +	select MARVELL_PHY
> +	select MFD_SYSCON
> +	---help---
> +	  If you wish to compile a kernel for a hardware with hisilicon p04 SoC and
> +	  want to use the internal ethernet then you should answer Y to this.

Selecting NET_CORE makes no sense, if it's not set this driver's
Kconfig file won't even be considered.
