From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPsec replay sequence number overflow behavior? (RFC4303 section 3.3.3)
Date: Mon, 10 Dec 2007 11:43:56 +0800
Message-ID: <20071210034356.GA31825@gondor.apana.org.au>
References: <E1J1Bfw-0006Kw-00@gondolin.me.apana.org.au> <200712090937.56599.paul.moore@hp.com> <20071210030653.GA31566@gondor.apana.org.au> <475CAF94.7020306@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Moore <paul.moore@hp.com>, netdev@vger.kernel.org,
	latten@us.ibm.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4825 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751536AbXLJDoD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Dec 2007 22:44:03 -0500
Content-Disposition: inline
In-Reply-To: <475CAF94.7020306@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 10, 2007 at 04:16:36AM +0100, Patrick McHardy wrote:
>
> Won't this break with manually installed SAs (without a keying
> daemon)?

Well what's being suggested here will already break that anyway :)

Alternatively we can take the interpretation that it's the KM's
responsibility to set the appropriate hard life time if ESNs are
not in use.

Either way is fine with me.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
