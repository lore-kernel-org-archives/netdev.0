From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] net: Fix GRO for multiple page fragments
Date: Fri, 17 Apr 2009 17:14:33 +0800
Message-ID: <20090417091433.GA1535@gondor.apana.org.au>
References: <1239905060.3203.28.camel@achroite> <20090417.012759.184081814.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:39693 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752993AbZDQJOj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 05:14:39 -0400
Content-Disposition: inline
In-Reply-To: <20090417.012759.184081814.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 17, 2009 at 01:27:59AM -0700, David Miller wrote:
>
> I think the code still isn't right after your changes.
> 
> The intent seems to be to append frags from 'info' into the SKB,
> so that it works even if the SKB already has some frags.
> 
> And being that cxgb3 is pretty well tested with GRO I'm suspicious
> even moreso :-)
> 
> Herbert?

Ah, I'd replied via private email to Ben.  This whole loop no
longer exists in net-next.  As for 2.6.30, the existing loop
should be correct.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
