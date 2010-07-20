From: David Miller <davem@davemloft.net>
Subject: Re: [0/8] netpoll/bridge fixes
Date: Mon, 19 Jul 2010 23:28:49 -0700 (PDT)
Message-ID: <20100719.232849.256873280.davem@davemloft.net>
References: <20100719115411.GA22758@gondor.apana.org.au>
	<20100719.090503.73693858.davem@davemloft.net>
	<20100720052645.GA5214@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, shemminger@vyatta.com, frzhang@redhat.com,
	netdev@vger.kernel.org, amwang@redhat.com, mpm@selenic.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51746
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752122Ab0GTG2e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 02:28:34 -0400
In-Reply-To: <20100720052645.GA5214@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 20 Jul 2010 13:26:45 +0800

> Note that this patch needs to be reverted in net-next-2.6 as
> bridge netpoll works correctly there.

Ok, will do.

> bridge: Partially disable netpoll support
> 
> The new netpoll code in bridging contains use-after-free bugs
> that are non-trivial to fix.
> 
> This patch fixes this by removing the code that uses skbs after
> they're freed.
> 
> As a consequence, this means that we can no longer call bridge
> from the netpoll path, so this patch also removes the controller
> function in order to disable netpoll.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
