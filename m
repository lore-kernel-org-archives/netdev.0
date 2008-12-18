From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: Accept ESP packets regardless of UDP
	encapsulation mode
Date: Fri, 19 Dec 2008 09:38:51 +1100
Message-ID: <20081218223851.GA1637@gondor.apana.org.au>
References: <1229596531.10402.121.camel@martin> <E1LDGgX-0007JE-T9@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Martin Willi <martin@strongswan.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:60386 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751394AbYLRWi4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 17:38:56 -0500
Content-Disposition: inline
In-Reply-To: <E1LDGgX-0007JE-T9@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 18, 2008 at 10:04:53PM +1100, Herbert Xu wrote:
>
> > [1]https://lists.strongswan.org/pipermail/users/2008-December/002936.html
> 
> Right that's what led to this patch.
> 
> Reading this it seems that there is either a bug in strongswan or
> in its peer.  IKE or IKEv2 is supposed to negotiate UDP encapsulation
> explicitly.  So either we did negotiate to use UDP encapsulation,
> and Strongswan ignored it (it's buggy), or we didn't and the peer
> still chose to use it (the peer is buggy).

You didn't address this part.

What KM/OS was the peer running? How was it configured?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
