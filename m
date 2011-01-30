From: David Miller <davem@davemloft.net>
Subject: Re: gro: Reset dev pointer on reuse
Date: Sat, 29 Jan 2011 20:45:11 -0800 (PST)
Message-ID: <20110129.204511.71113208.davem@davemloft.net>
References: <20110130041047.GA6290@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34061
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752522Ab1A3Eog (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jan 2011 23:44:36 -0500
In-Reply-To: <20110130041047.GA6290@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 30 Jan 2011 15:10:47 +1100

> gro: Reset dev pointer on reuse
> 
> On older kernels the VLAN code may zero skb->dev before dropping
> it and causing it to be reused by GRO.
> 
> Unfortunately we didn't reset skb->dev in that case which causes
> the next GRO user to get a bogus skb->dev pointer.
> 
> This particular problem no longer happens with the current upstream
> kernel due to changes in VLAN processing.
> 
> However, for correctness we should still reset the skb->dev pointer
> in the GRO reuse function in case a future user does the same thing.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
