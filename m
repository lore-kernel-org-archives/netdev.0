From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH] net/cpsw: don't disable_irqs() after an interrupt has
 been received.
Date: Wed, 17 Apr 2013 23:12:54 +0200
Message-ID: <516F1056.6020108@linutronix.de>
References: <1366136460-30732-1-git-send-email-bigeasy@linutronix.de> <516E3EED.4000200@ti.com> <516E52EC.60901@linutronix.de> <516E6165.8050908@ti.com> <516E6538.8060804@linutronix.de> <516E7492.9090608@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:41113 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965409Ab3DQVNA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 17:13:00 -0400
In-Reply-To: <516E7492.9090608@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/17/2013 12:08 PM, Mugunthan V N wrote:
> Mine shows [    0.000000] AM335X ES2.0 (neon )
> 
> In Beagle bone (silicon revision 1.0) there is a bug in CPSW irq in
> Silicon, please refer
> http://www.ti.com/lit/er/sprz360e/sprz360e.pdf  Advisory 1.0.9
> 
> Beagle bone black has Silicon revision 2.0 where the bug is fixed and
> you are able
> to test it properly and it hangs in my bone black as the IRQ is properly
> connected
> to A8

Are you there is not something else going on? According to the TRM
14.3.1.3.1 + .14.3.1.3.2 the interrupts are properly disabled. So
according to the TRM, the interrupts should not be disabled and not
appear anymore.
Advisory 1.0.9 says that only TXPEND[0] and RXPEND[0] are connected to
the INTC rather than TXPEND[0-7] (+RXPEND) and therefore only channel 0
can be used. That means I have still no idea why the interrupt is not
cleared on your ES2.0.

> Regards
> Mugunthan V N

Sebastian
