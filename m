From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ipv6: Make icmp route lookup code a bit clearer.
Date: Wed, 2 Mar 2011 15:02:51 +0800
Message-ID: <20110302070251.GA18270@gondor.apana.org.au>
References: <20110301.221543.226770795.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:55516 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751853Ab1CBHCx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 02:02:53 -0500
Content-Disposition: inline
In-Reply-To: <20110301.221543.226770795.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 01, 2011 at 10:15:43PM -0800, David Miller wrote:
> 
> The route lookup code in icmpv6_send() is slightly tricky as a result of
> having to handle all of the requirements of RFC 4301 host relookups.
> 
> Pull the route resolution into a seperate function, so that the error
> handling and route reference counting is hopefully easier to see and
> contained wholly within this new routine.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

Looks good to me too.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
