From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Fix xfrm hash collisions by changing
	__xfrm4_daddr_saddr_hash to hash addresses with addition
Date: Thu, 13 Aug 2009 14:19:50 +1000
Message-ID: <20090813041950.GA19592@gondor.apana.org.au>
References: <20090813020606.GA18205@gondor.apana.org.au> <20090812.204247.183387787.davem@davemloft.net> <20090813035310.GA19182@gondor.apana.org.au> <20090812.205635.244644770.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: joamaki@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:46336 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751184AbZHMETy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 00:19:54 -0400
Content-Disposition: inline
In-Reply-To: <20090812.205635.244644770.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 12, 2009 at 08:56:35PM -0700, David Miller wrote:
> 
> 2) Whoever creates such a hash collision explosion can be
>    precisely identified.

BTW the trust issue goes the other way too.  I wouldn't want
to connect to any IPsec peer if I knew that they could render
my gateway unuseable whenever they liked :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
