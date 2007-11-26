From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] add compare_ether_addr_unaligned
Date: Mon, 26 Nov 2007 18:39:44 +0800
Message-ID: <20071126103944.GA26250@gondor.apana.org.au>
References: <20071123000922.C44009D4A1F@zog.reactivated.net> <20071123132631.GI18862@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3347 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753399AbXKZKjv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 05:39:51 -0500
Content-Disposition: inline
In-Reply-To: <20071123132631.GI18862@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 23, 2007 at 09:26:31PM +0800, Herbert Xu wrote:
> On Fri, Nov 23, 2007 at 12:09:22AM +0000, Daniel Drake wrote:
> > David Miller found a problem in a wireless driver where I was using
> > compare_ether_addr() on potentially unaligned data. Document that
> > compare_ether_addr() is not safe for use everywhere, and add an equivalent
> > function that works regardless of alignment.
> > 
> > Signed-off-by: Daniel Drake <dsd@gentoo.org>
> 
> Patch applied to net-2.6.  Thanks.

Since it turned out that this function wouldn't be useful in
the case that you originally intended it for, I'm going to drop
it until such a time when a new need arises.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
