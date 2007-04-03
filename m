From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/9] AF_RXRPC: Add blkcipher accessors for using kernel data directly
Date: Tue, 3 Apr 2007 13:50:19 +1000
Message-ID: <20070403035019.GA4798@gondor.apana.org.au>
References: <20070402224449.31568.17833.stgit@warthog.cambridge.redhat.com> <20070402224458.31568.45303.stgit@warthog.cambridge.redhat.com> <20070402.202215.21596343.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dhowells@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3832 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751691AbXDCDuf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2007 23:50:35 -0400
Content-Disposition: inline
In-Reply-To: <20070402.202215.21596343.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 02, 2007 at 08:22:15PM -0700, David Miller wrote:
> 
> I'll let Herbert, the crypto layer maintainer, decide on this one.
> I can put it into net-2.6.22 in order to make the RXRPC integration
> easier if Herbert is OK with this.
> 
> Please be sure to CC: Herbert and/or the crypto lists on any future
> crypto layer patches David, thanks.

I'm OK with the concept but this is going to conflict with the async
stuff that I'm about to push into cryptodev-2.6.

Would it be possible to just use the existing scatterlist interface
for now? We can simplify it later when things settle down.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
