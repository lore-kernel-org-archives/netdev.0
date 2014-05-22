From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH net-next] genirq: Eliminate explicit dependency between
 IRQ affinity notifiers and CONFIG_SMP
Date: Fri, 23 May 2014 07:21:02 +0900 (JST)
Message-ID: <alpine.DEB.2.02.1405230717310.8522@ionos.tec.linutronix.de>
References: <1400597820-30685-1-git-send-email-amirv@mellanox.com> <20140522.152808.802269502342645717.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: amirv@mellanox.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, bhutchings@solarflare.com,
	yevgenyp@mellanox.com, ogerlitz@mellanox.com, eyalpe@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140522.152808.802269502342645717.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 22 May 2014, David Miller wrote:

> From: Amir Vadai <amirv@mellanox.com>
> Date: Tue, 20 May 2014 17:57:00 +0300
> 
> > From: Eyal Perry <eyalpe@mellanox.com>
> > 
> > Instead of requiring each consumer of the IRQ affinity notifier to have
> > themselves be explicitly dependent on CONFIG_SMP, make the definition of
> > struct irq_affinity_notify to exist independently of that config option
> > and introduce a stub for irq_set_affinity_notifier() under non SMP
> > configuration.
> > 
> > Fixes: 2eacc23 ("net/mlx4_core: Enforce irq affinity changes
> > immediatly")
> > 
> > Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
> > Signed-off-by: Amir Vadai <amirv@mellanox.com>
> 
> IRQ layer folks please review and push upstream if there aren't any
> problems.

It's queued for 3.16 in irq/core and also available for you as a
single commit to merge into your next tree at:

 git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git irq/for-net

if you want to carry it along for testing.

Thanks,

	tglx
