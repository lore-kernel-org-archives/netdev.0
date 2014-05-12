From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ptp: fix kconfig dependency warnings
Date: Mon, 12 May 2014 00:27:51 -0400 (EDT)
Message-ID: <20140512.002751.863013870815265640.davem@davemloft.net>
References: <536BFD22.3020505@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, richardcochran@gmail.com,
	akpm@linux-foundation.org
To: rdunlap@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54766 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750907AbaELE1x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 00:27:53 -0400
In-Reply-To: <536BFD22.3020505@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@infradead.org>
Date: Thu, 08 May 2014 14:54:42 -0700

> From: Randy Dunlap <rdunlap@infradead.org>
> 
> Fix kconfig warnings:
> 
> PTP_1588_CLOCK selects NET_PTP_CLASSIFY, which depends on NET,
> so PTP_1588_CLOCK should also depend on NET.
> 
> PTP_1588_CLOCK_PCH selects PTP_1588_CLOCK so the former should
> depend on NET.
> 
> warning: (IXP4XX_ETH && PTP_1588_CLOCK) selects NET_PTP_CLASSIFY which has unmet direct dependencies (NET)
> 
> warning: (SFC && TILE_NET && BFIN_MAC_USE_HWSTAMP && TIGON3 && FEC && E1000E && IGB && IXGBE && I40E && MLX4_EN && SXGBE_ETH && STMMAC_ETH && TI_CPTS && PTP_1588_CLOCK_GIANFAR && PTP_1588_CLOCK_IXP46X && DP83640_PHY && PTP_1588_CLOCK_PCH) selects PTP_1588_CLOCK which has unmet direct dependencies (NET)
> [This warning is caused by the new 'depends on NET' in PTP_1588_CLOCK.]
> 
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>

Applied, thanks Randy.
