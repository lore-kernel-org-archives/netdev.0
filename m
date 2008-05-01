From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/2] Disable forwarding of LRO skbs
Date: Thu, 1 May 2008 18:53:07 +0800
Message-ID: <20080501105307.GA7490@gondor.apana.org.au>
References: <E1JrVtK-0001pb-00@gondolin.me.apana.org.au> <20080501.033414.132094744.davem@davemloft.net> <20080501103854.GA7285@gondor.apana.org.au> <20080501.035108.190262472.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhutchings@solarflare.com, kmansley@solarflare.com,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43271 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754658AbYEAKxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 06:53:17 -0400
Content-Disposition: inline
In-Reply-To: <20080501.035108.190262472.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 01, 2008 at 03:51:08AM -0700, David Miller wrote:
>
> Perhaps the issue is that it's expensive to do that, and thus
> it could harm routing performance in such cases.

Actually my brain was busted from reading FIPS doco :)

LRO on forward is fundamentally broken because we'd be fiddling
with other people's bits.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
