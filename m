From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tun: virtio net is not compatible with LRO
Date: Wed, 3 Jun 2009 17:59:07 +1000
Message-ID: <20090603075906.GA9857@gondor.apana.org.au>
References: <20090603052335.GA20823@sequoia.sous-sol.org> <200906031652.56084.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Wright <chrisw@sous-sol.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:39127 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753263AbZFCH7T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 03:59:19 -0400
Content-Disposition: inline
In-Reply-To: <200906031652.56084.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 03, 2009 at 04:52:55PM +0930, Rusty Russell wrote:
>
> So, skb_is_gso() is true, but it's not actually a gso frame?
> 
> I know nothing about LRO, but that seems wrong.  If you bridge any other GSO 
> device with an LRO device, does that do random things as well?

Yeah you don't want to know about LRO.  The good news is that
LRO is going away so this is temporary.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
