From: Herbert Xu <herbert.xu@redhat.com>
Subject: Re: [IPSEC] flow: Cache negative results
Date: Thu, 11 Jan 2007 22:29:32 +1100
Message-ID: <20070111112932.GA24696@gondor.apana.org.au>
References: <20070110204922.GA1652@gondor.apana.org.au> <001601c734fb$89ed3b90$cc0a010a@tcssec.com> <20070110232713.GA13180@gondor.apana.org.au> <20070110.220605.38709282.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vyekkirala@trustedcs.com, jmorris@namei.org,
	netdev@vger.kernel.org, paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3447 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1030261AbXAKL3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jan 2007 06:29:48 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20070110.220605.38709282.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 10, 2007 at 10:06:05PM -0800, David Miller wrote:
> 
> One thing we could do is force a full flow cache flush when some
> percentage before the generation count would overflow.  Say every
> %80 of the generation ID space?  That gives enough space to ensure
> the flush tasklet runs before the ID really does wrap.

Yes that would be a good solution.  It'd prevent overflows from causing
any damage and is also pretty light weight (just a single comparison
every time the genid changes).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
