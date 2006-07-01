From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] NET: Fix ipv6 GSO payload length
Date: Sat, 1 Jul 2006 13:44:46 +1000
Message-ID: <20060701034446.GA30258@gondor.apana.org.au>
References: <1151708208.3645.2.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.62.148.172] ([64.62.148.172]:775 "EHLO arnor.apana.org.au")
	by vger.kernel.org with ESMTP id S964814AbWGADp2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 23:45:28 -0400
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <1151708208.3645.2.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 30, 2006 at 03:56:47PM -0700, Michael Chan wrote:
> Fix ipv6 GSO payload length calculation.
> 
> The ipv6 payload length excludes the ipv6 base header length and so
> must be subtracted.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Looks good to me.  Thanks for cathcing this!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
