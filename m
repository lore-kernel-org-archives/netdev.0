From: David Miller <davem@davemloft.net>
Subject: Re: tun: Only wake up writers
Date: Wed, 03 Jun 2009 21:46:10 -0700 (PDT)
Message-ID: <20090603.214610.86822955.davem@davemloft.net>
References: <20090603033303.GA7889@gondor.apana.org.au>
	<20090603123655.GA13916@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45147
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750696AbZFDEqJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 00:46:09 -0400
In-Reply-To: <20090603123655.GA13916@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 3 Jun 2009 22:36:55 +1000

> tun: Only wake up writers
> 
> When I added socket accounting to tun I inadvertently introduced
> spurious wake-up events that kills qemu performance.  The problem
> occurs when qemu polls on the tun fd for read, and then transmits
> packets.  For each packet transmitted, we will wake up qemu even
> if it only cares about read events.
> 
> Now this affects all sockets, but it is only a new problem for
> tun.  So this patch tries to fix it for tun first and we can then
> look at the problem in general.
>  
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-next-2.6, thanks Herbert!
