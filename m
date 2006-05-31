From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netif_tx_disable and lockless TX
Date: Wed, 31 May 2006 15:14:51 +1000
Message-ID: <20060531051451.GA7110@gondor.apana.org.au>
References: <1551EAE59135BE47B544934E30FC4FC041BC90@NT-IRVA-0751.brcm.ad.broadcom.com> <20060531045811.GA6977@gondor.apana.org.au> <20060530.221117.85394939.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mchan@broadcom.com, jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:11269 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751706AbWEaFPJ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 01:15:09 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060530.221117.85394939.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 30, 2006 at 10:11:17PM -0700, David Miller wrote:
> 
> It will come back when net channels arrive :-) This is because net
> channel drivers will do all the work in hard IRQs and not in a NAPI or
> NAPI-like context.

I thought the current channel stuff is RX only.  Is TX completion moving
to IRQ context as well?

> The only regret I have about that is we will go back to not being able
> to profile ->hard_start_xmit() very well in such drivers.

Can you elborate on that? I think I've already removed all references
to this in my memory :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
