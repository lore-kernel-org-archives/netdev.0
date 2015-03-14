From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/6] rhashtable: Fixes + cleanups + preparation for
 multiple rehash
Date: Sat, 14 Mar 2015 13:51:05 +1100
Message-ID: <20150314025105.GB10525@gondor.apana.org.au>
References: <20150313095607.GA598@gondor.apana.org.au>
 <20150313.122505.22987105222244414.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:40453 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892AbbCNCvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 22:51:10 -0400
Content-Disposition: inline
In-Reply-To: <20150313.122505.22987105222244414.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 13, 2015 at 12:25:05PM -0400, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Fri, 13 Mar 2015 20:56:07 +1100
> 
> > Patch 1 fixes the walker so that it behaves properly even during
> > a resize.
> > 
> > Patch 2-3 are cleanups.
> > 
> > Patch 4-6 lays some ground work for the upcoming multiple rehashing.
> 
> Looks like this needs at least one respin, to fix the printf formatting
> from changing size to unsigned int from size_t.

OK I have fixed the warning.

> And perhaps addressing the ordering of patches #6 and #1.

AFAICS there is no ordering issue there.  #1 is a bug-fix to the
current rhashtable while #6 is purely ground work for multiple
rehashing.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
