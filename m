From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] net: Fix GRO for multiple page fragments
Date: Fri, 17 Apr 2009 22:48:12 +0800
Message-ID: <20090417144812.GC4182@gondor.apana.org.au>
References: <1239905060.3203.28.camel@achroite> <20090417.012759.184081814.davem@davemloft.net> <20090417091433.GA1535@gondor.apana.org.au> <1239977010.5297.19.camel@deadeye.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53410 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758079AbZDQOsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 10:48:18 -0400
Content-Disposition: inline
In-Reply-To: <1239977010.5297.19.camel@deadeye.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 17, 2009 at 03:03:30PM +0100, Ben Hutchings wrote:
>
> The loop is iterating forward, not backward, so why initialise frag to
> point to the last fragment?

Ah yes, that's completely bogus.  I suppose it only works because
the current users only supply one frag under normal circumstanses.

Yes we should integrate your patch for 2.6.30.  For net-next the
loop no longer exists so it should be fine.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
