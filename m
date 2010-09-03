From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] netpoll: use non-BH variant of RCU
Date: Fri, 3 Sep 2010 08:52:44 -0700
Message-ID: <20100903155244.GC2413@linux.vnet.ibm.com>
References: <20100813175157.GA29586@gondor.apana.org.au>
 <20100814.235033.02286546.davem@davemloft.net>
 <20100902172625.GD2349@linux.vnet.ibm.com>
 <20100903.083409.52185570.davem@davemloft.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, linville@tuxdriver.com,
	netdev@vger.kernel.org, mingo@elte.hu,
	linux-kernel@vger.kernel.org, peterz@infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100903.083409.52185570.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 03, 2010 at 08:34:09AM -0700, David Miller wrote:
> From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
> Date: Thu, 2 Sep 2010 10:26:25 -0700
> 
> >     softirq: adjust error check
> >     
> >     The error check for _local_bh_enable_ip() warns on both in_irq() and
> >     irqs_disabled().  The check for in_irq() is necessary, because a hardirq
> >     might well have interrupted bh execution, in which case it is simply
> >     not possible for the hardirq to exclude the bh that got interrupted.
> >     
> >     However, it is perfectly reasonable to disable bh while hardirqs are
> >     disabled, and this in fact promotes common code.  This commit therefore
> >     removes the irqs_disabled() check.
> >     
> >     Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> 
> Acked-by: David S. Miller <davem@davemloft.net>

Thank you, David!

							Thanx, Paul
