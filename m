From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] irda/pxa:
Date: Sat, 07 Jul 2012 02:41:42 -0700 (PDT)
Message-ID: <20120707.024142.716093879187765160.davem@davemloft.net>
References: <201207070848.30706.arnd@arndb.de>
	<201207070855.15431.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rmk+kernel@arm.linux.org.uk, linux-arm-kernel@lists.infradead.org,
	samuel@sortiz.org, netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42433 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750949Ab2GGJlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jul 2012 05:41:45 -0400
In-Reply-To: <201207070855.15431.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Sat, 7 Jul 2012 08:55:15 +0000

> After c00184f9ab4 "ARM: sa11x0/pxa: convert OS timer registers to IOMEM",
> magician_defconfig and a few others fail to build because the OSCR
> register is accessed by the drivers/net/irda/pxaficp_ir.c but has turned
> into a pointer that needs to be read using readl.
> 
> There are other registers in the same driver that eventually should
> be converted, and it's unclear whether we would want a better interface
> to access the OSCR from a device driver.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
> This patch should be applied to Russell's ARM tree which contains the
> patch that broke it, Cc to netdev for information and Acks.

Acked-by: David S. Miller <davem@davemloft.net>
