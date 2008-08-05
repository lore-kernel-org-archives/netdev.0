From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/2] (revised) Interfamily IPSec BEET
Date: Tue, 5 Aug 2008 18:54:06 +0800
Message-ID: <20080805105406.GC21786@gondor.apana.org.au>
References: <200808051235.47624.joakim.koskela@hiit.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, yoshfuji@wide.ad.jp
To: Joakim Koskela <joakim.koskela@hiit.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59390 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752315AbYHEKyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 06:54:09 -0400
Content-Disposition: inline
In-Reply-To: <200808051235.47624.joakim.koskela@hiit.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 05, 2008 at 12:35:47PM +0300, Joakim Koskela wrote:
> 
> Here's a revised version, based on Herbert's comments, of a fix for
> the ipv4-inner, ipv6-outer interfamily ipsec beet mode. It fixes the
> network header adjustment during interfamily, as well as makes sure
> that we reserve enough room for the new ipv6 header if we might have
> something else as the inner family. Also, the ipv4 pseudo header
> construction was added.
> 
> Signed-off-by: Joakim Koskela <jookos@gmail.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

A future improvement would be to divide the output processing
for BEET based on the inner/outer family.  Then the option code
would only be needed on the IPv4 side.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
