From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sh_eth: Fix build by forgot including
 linux/interrupt.h
Date: Sat, 13 Aug 2011 18:02:29 -0700 (PDT)
Message-ID: <20110813.180229.401223475214365969.davem@davemloft.net>
References: <1312956950-32598-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adobriyan@gmail.com
To: nobuhiro.iwamatsu.yj@renesas.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48622 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752864Ab1HNBCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Aug 2011 21:02:35 -0400
In-Reply-To: <1312956950-32598-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Date: Wed, 10 Aug 2011 15:15:50 +0900

> By a6b7a407865aab9f849dd99a71072b7cd1175116, remove interrupt.h
> from netdevice.h. But this forget to revise sh_eth.
> 
> This fix the build failure.
> 
> error: expected '=', ',', ';', 'asm' or '__attribute__' before 'sh_eth_interrupt'
> error: implicit declaration of function 'request_irq'
> error: 'sh_eth_interrupt' undeclared (first use in this function)
> error: (Each undeclared identifier is reported only once
> 	drivers/net/sh_eth.c:1386: error: for each function it appears in.)
> error: 'IRQF_SHARED' undeclared (first use in this function)
> error: implicit declaration of function 'free_irq'
> 
> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
> CC: Alexey Dobriyan <adobriyan@gmail.com>

Applied.
