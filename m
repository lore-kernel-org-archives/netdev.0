From: David Miller <davem@davemloft.net>
Subject: Re: [IPV6]: Fix IPsec datagram fragmentation
Date: Tue, 12 Feb 2008 18:08:28 -0800 (PST)
Message-ID: <20080212.180828.262893392.davem@davemloft.net>
References: <20080213000437.GA19976@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	dlstevens@us.ibm.com, kazunori@miyazawa.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38798
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753066AbYBMCH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2008 21:07:56 -0500
In-Reply-To: <20080213000437.GA19976@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 13 Feb 2008 11:04:37 +1100

> [IPV6]: Fix IPsec datagram fragmentation
> 
> This is a long-standing bug in the IPsec IPv6 code that breaks
> when we emit a IPsec tunnel-mode datagram packet.  The problem
> is that the code the emits the packet assumes the IPv6 stack
> will fragment it later, but the IPv6 stack assumes that whoever
> is emitting the packet is going to pre-fragment the packet.
> 
> In the long term we need to fix both sides, e.g., to get the
> datagram code to pre-fragment as well as to get the IPv6 stack
> to fragment locally generated tunnel-mode packet.
> 
> For now this patch does the second part which should make it
> work for the IPsec host case.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, and I'll queue this up to -stable as well.

Thanks!
