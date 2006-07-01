From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [1/4] [IPV6]: Remove redundant length check on input
Date: Sat, 1 Jul 2006 13:39:39 +1000
Message-ID: <20060701033939.GC29803@gondor.apana.org.au>
References: <78C9135A3D2ECE4B8162EBDCE82CAD7793A4C8@nekter>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.62.148.172] ([64.62.148.172]:59654 "EHLO arnor.apana.org.au")
	by vger.kernel.org with ESMTP id S964814AbWGADkt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 23:40:49 -0400
To: Ananda Raju <Ananda.Raju@neterion.com>
Content-Disposition: inline
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD7793A4C8@nekter>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 30, 2006 at 07:44:49PM -0400, Ananda Raju wrote:
> 
> I tested the patch, and TSO over ipv6 is working fine. But TSO disable
> not working for IPv6. 
> 
> I tried the from tree /pub/scm/linux/kernel/git/davem/net-2.6

I think we need some new ethtool helper functions that sets/clears both
TSO/TSO6.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
