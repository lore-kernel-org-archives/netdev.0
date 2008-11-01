From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Fix ESP SA loading (by default)
Date: Sat, 1 Nov 2008 19:50:43 +0800
Message-ID: <20081101115043.GA19593@gondor.apana.org.au>
References: <20081101043737.GA1621@x200.localdomain> <20081101050458.GA17807@gondor.apana.org.au> <20081101113835.GA3127@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:50952 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751093AbYKALuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Nov 2008 07:50:50 -0400
Content-Disposition: inline
In-Reply-To: <20081101113835.GA3127@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 01, 2008 at 02:38:35PM +0300, Alexey Dobriyan wrote:
>
> It's a cut down example. This won't work either:

OK, in that case I suggest we make AH depend on the null algorithms
instead.  This is because very few people use AH these days and only
they need this.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
