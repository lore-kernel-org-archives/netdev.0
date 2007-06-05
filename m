From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [2/4] [IPV4]: Convert IPv4 devconf to an array
Date: Tue, 5 Jun 2007 16:29:30 +1000
Message-ID: <20070605062929.GA12024@gondor.apana.org.au>
References: <20070602100132.GA9129@gondor.apana.org.au> <20070602100252.GB9247@gondor.apana.org.au> <20070604.231754.74747974.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4078 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755121AbXFEG3e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 02:29:34 -0400
Content-Disposition: inline
In-Reply-To: <20070604.231754.74747974.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 04, 2007 at 11:17:54PM -0700, David Miller wrote:
> 
> These array indexes are off by one.

Good catch.  I'll repost this.

> This is the danger in using this "x-1" indexing style.
> Such a mistake is way too easy to make.

Yes, unfortunately the NET_IPV4_* constants are exposed to user-space
so I can't easily change them.  Inventing a new set of constants didn't
seem to be worthwhile.  The other option would be to keep the symbolic
names with a union or explicit pointer calculations for the bitmap, but
this seemed to me to be the least ugly of all the alternatives.

If it's any consolation, this should be the only spot where we use
these constants directly.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
