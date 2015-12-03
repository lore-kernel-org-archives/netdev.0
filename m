From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: lpc_eth: remove irq > NR_IRQS check from probe()
Date: Thu, 03 Dec 2015 15:02:52 -0500 (EST)
Message-ID: <20151203.150252.916768886355672458.davem@davemloft.net>
References: <1449036733-20632-1-git-send-email-vz@mleia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vz@mleia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45047 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753285AbbLCUCy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 15:02:54 -0500
In-Reply-To: <1449036733-20632-1-git-send-email-vz@mleia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladimir Zapolskiy <vz@mleia.com>
Date: Wed,  2 Dec 2015 08:12:13 +0200

> If the driver is used on an ARM platform with SPARSE_IRQ defined,
> semantics of NR_IRQS is different (minimal value of virtual irqs) and
> by default it is set to 16, see arch/arm/include/asm/irq.h.
> 
> This value may be less than the actual number of virtual irqs, which
> may break the driver initialization. The check removal allows to use
> the driver on such a platform, and, if irq controller driver works
> correctly, the check is not needed on legacy platforms.
> 
> Fixes a runtime problem:
> 
>     lpc-eth 31060000.ethernet: error getting resources.
>     lpc_eth: lpc-eth: not found (-6).
> 
> Signed-off-by: Vladimir Zapolskiy <vz@mleia.com>

Applied.
