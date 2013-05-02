From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [net-next PATCH 1/1] drivers: net: cpsw: irq not disabled in
 cpsw isr in particular sequence
Date: Thu, 2 May 2013 14:37:27 +0200
Message-ID: <20130502123727.GA17149@linutronix.de>
References: <1367495531-19470-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-omap@vger.kernel.org
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:39563 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759146Ab3EBMh3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 May 2013 08:37:29 -0400
Content-Disposition: inline
In-Reply-To: <1367495531-19470-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Mugunthan V N | 2013-05-02 17:22:11 [+0530]:

>In CPSW NAPI, after processing all interrupts IRQ is enabled and then book
>keeping irq_enabled is updated. In random cases when a packet is transmitted
>or received between processing packets and IRQ enabled, then just after
>enabled IRQ and before irq_enabled is updated, ISR is called so IRQs are
>not disabled as irq_enabled is still false and CPU gets locked in CPSW ISR.
>
>By changing the sequence as update the irq_enabled and then enable IRQ
>fixes the issue. This issue is not captured always as it is a timing issue
>whether Tx or Rx IRQ is invoked between packet processing and enable IRQ.

Acked-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

Sebastian
