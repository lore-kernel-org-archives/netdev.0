From: David Miller <davem@davemloft.net>
Subject: Re: forcedeth skb_gso_segment warning
Date: Mon, 29 Jun 2009 19:43:16 -0700 (PDT)
Message-ID: <20090629.194316.30754487.davem@davemloft.net>
References: <1244539163.4672.5.camel@johannes.local>
	<20090629040330.GA2981@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55106
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753374AbZF3CnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 22:43:10 -0400
In-Reply-To: <20090629040330.GA2981@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 29 Jun 2009 12:03:30 +0800

> tcp: Stop non-TSO packets morphing into TSO
> 
> If a socket starts out on a non-TSO route, and then switches to
> a TSO route, then the tail on the tx queue can morph into a TSO
> packet, causing mischief because the rest of the stack does not
> expect a partially linear TSO packet.
> 
> This patch fixes this by ensuring that skb->ip_summed is set to
> CHECKSUM_PARTIAL before declaring a packet as TSO.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
