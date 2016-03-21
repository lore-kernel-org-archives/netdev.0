From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: smc911x: avoid unused variable warnings
Date: Mon, 21 Mar 2016 11:27:58 -0400 (EDT)
Message-ID: <20160321.112758.1927638633680684905.davem@davemloft.net>
References: <1458549072-1914517-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, robert.jarzmik@free.fr,
	linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46018 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756107AbcCUP2A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2016 11:28:00 -0400
In-Reply-To: <1458549072-1914517-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 21 Mar 2016 09:30:59 +0100

> The change to use the generic DMA engine API in the smc911x
> driver has led to a harmless warning about unused local variables:
> 
> smsc/smc911x.c: In function 'smc911x_probe':
> smsc/smc911x.c:1796:20: error: unused variable 'param'
> smsc/smc911x.c:1795:17: error: unused variable 'mask'
> smsc/smc911x.c:1794:26: error: unused variable 'config'
> 
> This puts the variable declarations inside of the same #ifdef
> that protects their use.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 79d3b59a93ba ("net: smc911x: convert pxa dma to dmaengine")

Applied.
