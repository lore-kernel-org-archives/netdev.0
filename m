From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPSEC]: Don't warn if high-order hash resize fails
Date: Mon, 14 May 2007 17:07:33 +1000
Message-ID: <20070514070733.GA23173@gondor.apana.org.au>
References: <20070514054837.GA18879@gondor.apana.org.au> <20070513.233635.28398106.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1344 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755446AbXENHHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2007 03:07:38 -0400
Content-Disposition: inline
In-Reply-To: <20070513.233635.28398106.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, May 13, 2007 at 11:36:35PM -0700, David Miller wrote:
> 
> Thanks I'll add the warning fix, but there must be some counter
> bug if it tried to grow to order-7, that really shouldn't
> be happening.

Good point.  A bit of dd-ing shows that I've got a negative value
in xfrm_policy_count[0] (0xfffffff6).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
