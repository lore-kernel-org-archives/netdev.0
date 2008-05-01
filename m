From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/2] Disable forwarding of LRO skbs
Date: Thu, 1 May 2008 18:45:17 +0800
Message-ID: <20080501104517.GA7390@gondor.apana.org.au>
References: <20080430.145820.50450486.davem@davemloft.net> <E1JrVtK-0001pb-00@gondolin.me.apana.org.au> <20080501.033414.132094744.davem@davemloft.net> <20080501103854.GA7285@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhutchings@solarflare.com, kmansley@solarflare.com,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36092 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753764AbYEAKpZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 06:45:25 -0400
Content-Disposition: inline
In-Reply-To: <20080501103854.GA7285@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 01, 2008 at 06:38:54PM +0800, Herbert Xu wrote:
> 
> I still don't understand why we can't forward LRO packets.  It
> should be no different to forwarding GSO packets if it's properly
> constructed.

Nevermind, doing LRO on forwarded traffic is fundamentally broken
because it breaks the end-to-end connection.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
