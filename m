From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: pxa168: Fix build errors by including interrupt.h
Date: Tue, 20 Sep 2011 15:47:40 -0400 (EDT)
Message-ID: <20110920.154740.1212490857319716408.davem@davemloft.net>
References: <1315287124-13972-1-git-send-email-tanmay.upadhyay@einfochips.com>
	<1315287124-13972-2-git-send-email-tanmay.upadhyay@einfochips.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ssanap@marvell.com, zgao6@marvell.com, prakity@marvell.com,
	markb@marvell.com, netdev@vger.kernel.org
To: tanmay.upadhyay@einfochips.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35381 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750967Ab1ITTry (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2011 15:47:54 -0400
In-Reply-To: <1315287124-13972-2-git-send-email-tanmay.upadhyay@einfochips.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tanmay Upadhyay <tanmay.upadhyay@einfochips.com>
Date: Tue,  6 Sep 2011 11:02:04 +0530

> Commit a6b7a407865aab9f849dd99a71072b7cd1175116 removed
> linux/interrupt.h from netdevice.h. This fixes below build failure
> 
> drivers/net/pxa168_eth.c: In function 'pxa168_eth_collect_events':
> drivers/net/pxa168_eth.c:866: error: 'IRQ_NONE' undeclared (first use in this function)
> drivers/net/pxa168_eth.c:866: error: (Each undeclared identifier is reported only once
> drivers/net/pxa168_eth.c:866: error: for each function it appears in.)
> drivers/net/pxa168_eth.c: At top level:
> drivers/net/pxa168_eth.c:913: error: expected '=', ',', ';', 'asm' or '__attribute__' before 'pxa168_eth_int_handler'
> drivers/net/pxa168_eth.c: In function 'pxa168_eth_open':
> drivers/net/pxa168_eth.c:1133: error: implicit declaration of function 'request_irq'
> drivers/net/pxa168_eth.c:1133: error: 'pxa168_eth_int_handler' undeclared (first use in this function)
> drivers/net/pxa168_eth.c:1134: error: 'IRQF_DISABLED' undeclared (first use in this function)
> drivers/net/pxa168_eth.c:1160: error: implicit declaration of function 'free_irq'
> 
> Signed-off-by: Tanmay Upadhyay <tanmay.upadhyay@einfochips.com>

Applied, thanks.
