From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] defxx: Fix issues with debug printk calls
Date: Tue, 08 Jul 2014 15:32:11 -0700 (PDT)
Message-ID: <20140708.153211.1389512038724757200.davem@davemloft.net>
References: <alpine.LFD.2.11.1407051520310.15455@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: macro@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54722 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753773AbaGHWcM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 18:32:12 -0400
In-Reply-To: <alpine.LFD.2.11.1407051520310.15455@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Maciej W. Rozycki" <macro@linux-mips.org>
Date: Sat, 5 Jul 2014 15:28:22 +0100 (BST)

> This fixes issues with debug printk calls across the driver, normally 
> disabled; first compilation errors:
> 
> drivers/net/fddi/defxx.c:676:1: error: pasting "(" and ""In dfx_bus_init...\n"" does not give a valid preprocessing token
> drivers/net/fddi/defxx.c:820:1: error: pasting "(" and ""In dfx_bus_uninit...\n"" does not give a valid preprocessing token
> 
> and so on, and then warnings:
> 
> drivers/net/fddi/defxx.c: In function 'dfx_driver_init':
> drivers/net/fddi/defxx.c:1132: warning: format '%0X' expects type 'unsigned int', but argument 4 has type 'dma_addr_t'
> drivers/net/fddi/defxx.c:1132: warning: format '%0X' expects type 'unsigned int', but argument 4 has type 'dma_addr_t'
> 
> etc.  Additionally casts are removed from virtual addresses and %p used.
> 
> Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>

Applied to net-next, thanks.
