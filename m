From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]NET: Fix GSO problems in dev_hard_start_xmit()
Date: Sun, 25 Jun 2006 23:57:24 -0700 (PDT)
Message-ID: <20060625.235724.130237223.davem@davemloft.net>
References: <1151275085.4468.2.camel@rh4>
	<20060625233602.GA22255@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:7583
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751189AbWFZG50 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 02:57:26 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060625233602.GA22255@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 26 Jun 2006 09:36:02 +1000

> On Sun, Jun 25, 2006 at 03:38:05PM -0700, Michael Chan wrote:
> > Fix 2 problems in dev_hard_start_xmit():
> > 
> > 1. nskb->next needs to link back to skb->next if hard_start_xmit()
> > returns non-zero.
> > 
> > 2. Since the total number of GSO fragments may exceed MAX_SKB_FRAGS + 1,
> > it needs to stop transmitting if the netif_queue is stopped.
> > 
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
> 
> Good catch.
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks.
