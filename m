From: Finn Thain <fthain@telegraphics.com.au>
Subject: Re: [PATCH] macmace: disable only the dma interrupt
Date: Sun, 11 Sep 2011 20:02:17 +1000 (EST)
Message-ID: <alpine.LNX.2.00.1109111958310.2745@nippy.intranet>
References: <alpine.LNX.2.00.1109110042210.5327@nippy.intranet> <20110910.143046.520109083086760748.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-m68k@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <20110910.143046.520109083086760748.davem@davemloft.net>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Sat, 10 Sep 2011, David Miller wrote:

> From: Finn Thain <fthain@telegraphics.com.au>
> Date: Sun, 11 Sep 2011 01:02:16 +1000 (EST)
> 
> > Don't disable all interrupts, just disable the relevant one.
> > 
> > Also move a couple of printk calls outside of local_irq_save/restore.
> > 
> > Tested on a Quadra 660av.
> > 
> > Signed-off-by: Finn Thain <fthain@telegraphics.com.au>
> 
> Using disable_irq() is very expensive, and when done from an interrupt 
> handler can deadlock especially on SMP (which I understand might not be 
> relevant here).
> 
> I really can't see why you'd do things this way, especially since 
> interrupt handlers under Linux now unconditionally always run with cpu 
> interrupts disabled.

I wasn't aware of this (I was under the impression that a higher priority 
interrupt could be serviced). Please disregard this patch.

Finn
