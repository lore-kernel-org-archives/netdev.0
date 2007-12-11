From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPSEC]: Fix potential dst leak in xfrm_lookup
Date: Tue, 11 Dec 2007 20:44:09 +0800
Message-ID: <20071211124409.GA14372@gondor.apana.org.au>
References: <20071211120729.GA14088@gondor.apana.org.au> <20071211.044016.218495218.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3402 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751907AbXLKNEo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 08:04:44 -0500
Content-Disposition: inline
In-Reply-To: <20071211.044016.218495218.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 11, 2007 at 04:40:16AM -0800, David Miller wrote:
> 
> I bet the __xfrm_lookup() callers could stand a major audit, with the
> special -EREMOTE logic I bet there are non-EREMOTE code paths there
> that don't handle the dst ref semantics properly.
> 
> This is a very error prone interface, both at the implementation
> and in the callers.

Heh, didn't we already do an audit a couple of years ago when
we made the decision that the dst is always going to be freed
in case of an error?

But yeah another audit for this and EREMOTE wouldn't hurt.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
