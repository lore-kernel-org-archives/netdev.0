From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/4] gro: Change all receive functions to return GRO
	result codes
Date: Thu, 29 Oct 2009 13:48:23 -0400
Message-ID: <20091029174823.GB30749@gondor.apana.org.au>
References: <1256836695.2827.71.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:46761 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756553AbZJ2RsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 13:48:20 -0400
Content-Disposition: inline
In-Reply-To: <1256836695.2827.71.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 29, 2009 at 05:18:15PM +0000, Ben Hutchings wrote:
> This will allow drivers to adjust their receive path dynamically
> based on whether GRO is being applied successfully.
> 
> Currently all in-tree callers ignore the return values of these
> functions and do not need to be changed.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
