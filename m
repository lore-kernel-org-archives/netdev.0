From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: platform: fix sparse warnings
Date: Fri, 07 Nov 2014 12:25:37 -0500 (EST)
Message-ID: <20141107.122537.927619981689659360.davem@davemloft.net>
References: <1415371602-12049-1-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	vbridgers2013@gmail.com
To: andriy.shevchenko@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40354 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751243AbaKGRZj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2014 12:25:39 -0500
In-Reply-To: <1415371602-12049-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Fri,  7 Nov 2014 16:46:42 +0200

> This patch fixes the following sparse warnings. One is fixed by casting return
> value to a return type of the function. The others by creating a specific
> stmmac_platform.h which provides the bits related to the platform driver.
> 
> drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c:59:29: warning: incorrect type in return expression (different address spaces)
> drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c:59:29:    expected void *
> drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c:59:29:    got void [noderef] <asn:2>*reg
> 
> drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c:64:29: warning: symbol 'meson6_dwmac_data' was not declared. Should it be static?
> drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c:354:29: warning: symbol 'stih4xx_dwmac_data' was not declared. Should it be static?
> drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c:361:29: warning: symbol 'stid127_dwmac_data' was not declared. Should it be static?
> drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c:133:29: warning: symbol 'sun7i_gmac_data' was not declared. Should it be static?
> 
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

Applied, thanks.
