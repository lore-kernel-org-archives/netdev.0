From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] net: phy: mdio: add missing __iomem annotation
Date: Wed, 07 Aug 2013 16:59:57 -0700 (PDT)
Message-ID: <20130807.165957.698344024245042714.davem@davemloft.net>
References: <000201ce927f$8e339490$aa9abdb0$@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, timur@freescale.com
To: jg1.han@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51611 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933256Ab3HGXym (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 19:54:42 -0400
In-Reply-To: <000201ce927f$8e339490$aa9abdb0$@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingoo Han <jg1.han@samsung.com>
Date: Tue, 06 Aug 2013 17:32:58 +0900

> Added missing __iomem annotation in order to fix the following
> sparse warnings:
> 
> drivers/net/phy/mdio-mux-mmioreg.c:51:27: warning: incorrect type in initializer (different address spaces)
> drivers/net/phy/mdio-mux-mmioreg.c:51:27:    expected void *p
> drivers/net/phy/mdio-mux-mmioreg.c:51:27:    got void [noderef] <asn:2>*
> drivers/net/phy/mdio-mux-mmioreg.c:57:21: warning: incorrect type in argument 1 (different address spaces)
> drivers/net/phy/mdio-mux-mmioreg.c:57:21:    expected void const volatile [noderef] <asn:2>*addr
> drivers/net/phy/mdio-mux-mmioreg.c:57:21:    got void *p
> drivers/net/phy/mdio-mux-mmioreg.c:60:25: warning: incorrect type in argument 2 (different address spaces)
> drivers/net/phy/mdio-mux-mmioreg.c:60:25:    expected void volatile [noderef] <asn:2>*addr
> drivers/net/phy/mdio-mux-mmioreg.c:60:25:    got void *p
> drivers/net/phy/mdio-mux-mmioreg.c:64:25: warning: incorrect type in argument 1 (different address spaces)
> drivers/net/phy/mdio-mux-mmioreg.c:64:25:    expected void volatile [noderef] <asn:2>*addr
> drivers/net/phy/mdio-mux-mmioreg.c:64:25:    got void *p
> 
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Applied.
