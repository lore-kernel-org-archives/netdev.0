From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: enic: include irq.h for irqreturn_t definitions
Date: Thu, 03 Apr 2014 14:05:03 -0400 (EDT)
Message-ID: <20140403.140503.968514828017455803.davem@davemloft.net>
References: <20140402152400.GC20438@zod>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benve@cisco.com, ssujith@cisco.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jwboyer@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140402152400.GC20438@zod>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Josh Boyer <jwboyer@gmail.com>
Date: Wed, 2 Apr 2014 11:24:00 -0400

> The enic driver fails to build on ARM with:
> 
> In file included from drivers/net/ethernet/cisco/enic/enic_res.c:40:0:
> drivers/net/ethernet/cisco/enic/enic.h:48:2: error: expected specifier-qualifier-list before 'irqreturn_t'
>   irqreturn_t (*isr)(int, void *);
>   ^
> 
> Nothing in the driver is explicitly including the irq definitions, so we add
> an include of linux/irq.h to pick them up.
> 
> Signed-off-by: Josh Boyer <jwboyer@fedoraproject.org>

Applied.
