From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] genirq: Eliminate explicit dependency between
 IRQ affinity notifiers and CONFIG_SMP
Date: Thu, 22 May 2014 15:28:08 -0400 (EDT)
Message-ID: <20140522.152808.802269502342645717.davem@davemloft.net>
References: <1400597820-30685-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, bhutchings@solarflare.com,
	yevgenyp@mellanox.com, ogerlitz@mellanox.com, eyalpe@mellanox.com
To: amirv@mellanox.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400597820-30685-1-git-send-email-amirv@mellanox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amir Vadai <amirv@mellanox.com>
Date: Tue, 20 May 2014 17:57:00 +0300

> From: Eyal Perry <eyalpe@mellanox.com>
> 
> Instead of requiring each consumer of the IRQ affinity notifier to have
> themselves be explicitly dependent on CONFIG_SMP, make the definition of
> struct irq_affinity_notify to exist independently of that config option
> and introduce a stub for irq_set_affinity_notifier() under non SMP
> configuration.
> 
> Fixes: 2eacc23 ("net/mlx4_core: Enforce irq affinity changes
> immediatly")
> 
> Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>

IRQ layer folks please review and push upstream if there aren't any
problems.

Thanks.
