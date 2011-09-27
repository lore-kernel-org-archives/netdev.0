From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] skge: handle irq better on single port card
Date: Tue, 27 Sep 2011 13:41:58 -0400 (EDT)
Message-ID: <20110927.134158.473056454279800853.davem@davemloft.net>
References: <20110927102523.5f8b7f2a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53229 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750965Ab1I0RmB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 13:42:01 -0400
In-Reply-To: <20110927102523.5f8b7f2a@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 27 Sep 2011 10:25:23 -0700

> Most boards with SysKonnect/Marvell Ethernet have only a single port.
> For the single port case, use the standard Ethernet driver convention
> of allocating IRQ when device is brought up rather than at probe time.
> 
> This patch also adds some additional read after writes to avoid any
> PCI posting problems when setting the IRQ mask.
> 
> The error handling of dual port cards is also changed.  If second port
> can not be brought up, then just fail. No point in continuing, since
> the failure is most certainly because of out of memory.
> 
> It is worth noting that the dual port skge device has a single irq but two
> seperate status rings and therefore has two NAPI objects, one for
> each port.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
