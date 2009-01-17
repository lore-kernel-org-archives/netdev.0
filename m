From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: XFRM structures binary compability
Date: Sat, 17 Jan 2009 22:27:07 +1100
Message-ID: <20090117112707.GA7673@gondor.apana.org.au>
References: <200901161440.3616@centrum.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kaber@trash.net, netdev@vger.kernel.org
To: Jiri Klimes <klimes@centrum.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:40281 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751560AbZAQL1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jan 2009 06:27:17 -0500
Content-Disposition: inline
In-Reply-To: <200901161440.3616@centrum.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Klimes <klimes@centrum.cz> wrote:
>
> I see no solution to obtain 32/64-bit compatibility without impacting anybody :-(

We could create new requests, e.g. NEWSA2 that can then take
a properly designed structure which is invariant.

After that we can migrate the applications across.

Of course for all new structures we should be doubly sure that
they're all invariant to prevent this from happening again.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
