From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] sh_eth: remove unchecked interrupts for RZ/A1
Date: Fri, 02 Dec 2016 13:55:39 -0500 (EST)
Message-ID: <20161202.135539.2038699670508120973.davem@davemloft.net>
References: <20161201183214.30196-1-chris.brandt@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, horms+renesas@verge.net.au,
        geert+renesas@glider.be, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: chris.brandt@renesas.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38932 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752400AbcLBSzl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 13:55:41 -0500
In-Reply-To: <20161201183214.30196-1-chris.brandt@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Brandt <chris.brandt@renesas.com>
Date: Thu,  1 Dec 2016 13:32:14 -0500

> When streaming a lot of data and the RZ/A1 can't keep up, some status bits
> will get set that are not being checked or cleared which cause the
> following messages and the Ethernet driver to stop working. This
> patch fixes that issue.
> 
> irq 21: nobody cared (try booting with the "irqpoll" option)
> handlers:
> [<c036b71c>] sh_eth_interrupt
> Disabling IRQ #21
> 
> Fixes: db893473d313a4ad ("sh_eth: Add support for r7s72100")
> Signed-off-by: Chris Brandt <chris.brandt@renesas.com>
> Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied and queued up for -stable, thanks.
