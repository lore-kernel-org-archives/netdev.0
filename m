From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/1] drivers: net: cpsw: irq not disabled in
 cpsw isr in particular sequence
Date: Thu, 02 May 2013 16:52:27 -0400 (EDT)
Message-ID: <20130502.165227.1558171362372504606.davem@davemloft.net>
References: <1367495531-19470-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org,
	bigeasy@linutronix.de
To: mugunthanvnm@ti.com
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1367495531-19470-1-git-send-email-mugunthanvnm@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Thu, 2 May 2013 17:22:11 +0530

> In CPSW NAPI, after processing all interrupts IRQ is enabled and then book
> keeping irq_enabled is updated. In random cases when a packet is transmitted
> or received between processing packets and IRQ enabled, then just after
> enabled IRQ and before irq_enabled is updated, ISR is called so IRQs are
> not disabled as irq_enabled is still false and CPU gets locked in CPSW ISR.
> 
> By changing the sequence as update the irq_enabled and then enable IRQ
> fixes the issue. This issue is not captured always as it is a timing issue
> whether Tx or Rx IRQ is invoked between packet processing and enable IRQ.
> 
> Cc: Sebastian Siewior <bigeasy@linutronix.de>
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>

Applied, thanks.
