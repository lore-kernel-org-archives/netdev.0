From: Herbert Xu <herbert.xu@redhat.com>
Subject: Re: [PATCH 1/9] AF_RXRPC: Add blkcipher accessors for using kernel data directly
Date: Wed, 4 Apr 2007 07:37:26 +1000
Message-ID: <20070403213726.GA19200@gondor.apana.org.au>
References: <20070403035019.GA4798@gondor.apana.org.au> <20070402224449.31568.17833.stgit@warthog.cambridge.redhat.com> <20070402224458.31568.45303.stgit@warthog.cambridge.redhat.com> <20070402.202215.21596343.davem@davemloft.net> <19944.1175608373@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4867 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1945980AbXDCVhk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2007 17:37:40 -0400
Content-Disposition: inline
In-Reply-To: <19944.1175608373@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 03, 2007 at 02:52:53PM +0100, David Howells wrote:
> 
> Note that it does paste stack space into sg-list elements, which I think
> should be okay, and it asks the compiler to get it appropriately aligned bits
> of stack.

That'll do for now.

Thanks!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
