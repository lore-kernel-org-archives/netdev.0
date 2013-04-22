From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH 3/5 v2] net/cpsw: don't rely only on netif_running() to
 check which device is active
Date: Mon, 22 Apr 2013 12:19:37 +0200
Message-ID: <51750EB9.6090009@linutronix.de>
References: <1366235536-15744-1-git-send-email-bigeasy@linutronix.de> <1366235536-15744-4-git-send-email-bigeasy@linutronix.de> <516FDE0A.70504@ti.com> <516FE2AD.2040403@linutronix.de> <51711E0B.4000306@ti.com> <20130422083048.GA8162@linutronix.de> <5174FF93.8070408@ti.com> <51750334.8050807@linutronix.de> <51750587.5020801@ti.com> <517507A6.2090609@linutronix.de> <51750D1B.4060600@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tglx@linutronix.de,
	"David S. Miller" <davem@davemloft.net>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:57128 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752401Ab3DVKTj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 06:19:39 -0400
In-Reply-To: <51750D1B.4060600@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/22/2013 12:12 PM, Mugunthan V N wrote:
> 
> Yes, when interrupt is disabled in hardware then interrupt must be
> disabled.
> In my initial days i have verified it, CPSW doesn't allow any new
> interrupts to
> propagate  to arm if CPSW interrupt is disabled which is correct. CPSW irq
> signal is not directly connected to irq controller, it is connected via
> edge to
> level conversion so it is a kind of latched interrupt and so the
> interrupt has
> to be disabled in interrupt controller to disable the interrupt, else
> arm get
> blocked in CPSW ISR.
> 
> This behavior is not only in AM335x CPSW, it is as is from its previous
> versions in TI814x and TI8107.

And I don't see this on ES1.0 because they forgot to add the
edge-to-level converter?

> Regards
> Mugunthan V N

Sebastian
