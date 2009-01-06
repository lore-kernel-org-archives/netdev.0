From: David Miller <davem@davemloft.net>
Subject: Re: [2/2] vlan: Add GRO interfaces
Date: Tue, 06 Jan 2009 10:50:17 -0800 (PST)
Message-ID: <20090106.105017.124602241.davem@davemloft.net>
References: <20090105095131.GA15851@gondor.apana.org.au>
	<20090106071142.GA27281@gondor.apana.org.au>
	<20090106071216.GB27281@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43194
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752351AbZAFSuQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 13:50:16 -0500
In-Reply-To: <20090106071216.GB27281@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 6 Jan 2009 18:12:16 +1100

> vlan: Add GRO interfaces
> 
> This patch adds GRO interfaces for hardware-assisted VLAN reception.
> With this in place we're now at parity with LRO as far as the
> interface is concerned.  That is, you can now take any LRO driver
> and convert it over to GRO.
> 
> As the CB memory clashes with GRO's use of CB, I've removed it
> entirely by storing dev in skb->dev.  This is OK because VLAN
> gets called first thing in netif_receive_skb and skb->dev is
> not used in between us calling netif_rx and netif_receive_skb
> getting called.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Also applied, thanks Herbert.
