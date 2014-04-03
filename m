From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: qlcnic: include irq.h for irq definitions
Date: Thu, 03 Apr 2014 14:05:13 -0400 (EDT)
Message-ID: <20140403.140513.2264055788689960268.davem@davemloft.net>
References: <20140402152547.GD20438@zod>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: himanshu.madhani@qlogic.com, rajesh.borundia@qlogic.com,
	shahed.shaikh@qlogic.com, linux-driver@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jwboyer@fedoraproject.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140402152547.GD20438@zod>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Josh Boyer <jwboyer@fedoraproject.org>
Date: Wed, 2 Apr 2014 11:25:47 -0400

> The qlcnic driver fails to build on ARM with errors like:
> 
> In file included from drivers/net/ethernet/qlogic/qlcnic/qlcnic.h:36:0,
>                  from drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:8:
> drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h:585:1: error: unknown type name 'irqreturn_t'
>  irqreturn_t qlcnic_83xx_clear_legacy_intr(struct qlcnic_adapter *);
>  ^
> 
> Nothing in the driver is explicitly including the irq definitions, so we
> add an include of linux/irq.h to pick them up.
> 
> Signed-off-by: Josh Boyer <jwboyer@fedoraproject.org>

Applied, thanks Josh.
