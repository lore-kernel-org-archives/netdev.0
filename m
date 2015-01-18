From: David Miller <davem@davemloft.net>
Subject: Re: [patch-net-next v3 2/2] net: ethernet: cpsw: don't requests
 IRQs we don't use
Date: Sun, 18 Jan 2015 01:07:50 -0500 (EST)
Message-ID: <20150118.010750.480741880077015933.davem@davemloft.net>
References: <1421424672-19323-1-git-send-email-balbi@ti.com>
	<1421424672-19323-2-git-send-email-balbi@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tony@atomide.com, linux-omap@vger.kernel.org, mugunthanvnm@ti.com,
	netdev@vger.kernel.org
To: balbi@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42544 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750880AbbARGHw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 01:07:52 -0500
In-Reply-To: <1421424672-19323-2-git-send-email-balbi@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felipe Balbi <balbi@ti.com>
Date: Fri, 16 Jan 2015 10:11:12 -0600

> CPSW never uses RX_THRESHOLD or MISC interrupts. In
> fact, they are always kept masked in their appropriate
> IRQ Enable register.
> 
> Instead of allocating an IRQ that never fires, it's best
> to remove that code altogether and let future patches
> implement it if anybody needs those.
> 
> Signed-off-by: Felipe Balbi <balbi@ti.com>

Applied.
