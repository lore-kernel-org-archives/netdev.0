From: David Miller <davem@davemloft.net>
Subject: Re: [2/2] igb: Replace LRO with GRO
Date: Wed, 14 Jan 2009 20:40:16 -0800 (PST)
Message-ID: <20090114.204016.264050434.davem@davemloft.net>
References: <20090114123653.GA19257@gondor.apana.org.au>
	<9929d2390901141603s65cd27a3y732c5058de9145c8@mail.gmail.com>
	<20090115003246.GA26461@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	emil.s.tantilov@intel.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54984
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755023AbZAOEkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 23:40:15 -0500
In-Reply-To: <20090115003246.GA26461@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 15 Jan 2009 11:32:46 +1100

> gro: Fix page ref count for skbs freed normally
> 
> When an skb with page frags is merged into an existing one, we
> cannibalise its reference count.  This is OK when the skb is
> reused because we set nr_frags to zero in that case.  However,
> for the case where the skb is freed through kfree_skb, we didn't
> clear nr_frags which causes the page to be freed prematurely.
> 
> This is fixed by moving the skb resetting into skb_gro_receive.
> 
> Reported-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-2.6
