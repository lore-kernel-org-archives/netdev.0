From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -mm] Documentation: add networking driver's mapping
 error handling to DMA-API-HOWTO
Date: Sun, 09 May 2010 01:46:39 -0700 (PDT)
Message-ID: <20100509.014639.180406795.davem@davemloft.net>
References: <20100509130439D.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, randy.dunlap@oracle.com,
	netdev@vger.kernel.org
To: fujita.tomonori@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49377
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751722Ab0EIIqc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 May 2010 04:46:32 -0400
In-Reply-To: <20100509130439D.fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Sun, 9 May 2010 13:00:49 +0900

> I think that it's a good idea to add what drivers should to do exactly
> in the DMA mapping failure case.
> 
> Seems some networking drivers call dev_kfree_skb() and return
> NETDEV_TX_OK, however, some return NETDEV_TX_BUSY without freeing the
> skb. (and many don't even check the failure, which we need to fix).
> 
> What networking drivers are supposed to do in the case?

The best thing is probably just to drop, pretending the queue
is full and passing the packet back to the stack is just
full of complications and not worth it, so...

> From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> Subject: [PATCH -mm] Documentation: add networking driver's mapping error handling to DMA-API-HOWTO
> 
> Adds the concrete DMA mapping error handling for Networking drivers on
> the transmit path.
> 
> Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>

Acked-by: David S. Miller <davem@davemloft.net>
