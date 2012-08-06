From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: skb_warn_bad_offload with kernel 3.5 (maybe gso/bridge related
 ?)
Date: Mon, 6 Aug 2012 17:18:46 +0800
Message-ID: <20120806091846.GA18581@gondor.apana.org.au>
References: <501B8792.6040605@univ-nantes.fr>
 <1343983887.9299.817.camel@edumazet-glaptop>
 <1344008408.4642.160.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Yann Dupont <Yann.Dupont@univ-nantes.fr>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sting.hengli.com.au ([178.18.18.71]:40333 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753881Ab2HFJS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 05:18:56 -0400
Content-Disposition: inline
In-Reply-To: <1344008408.4642.160.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 03, 2012 at 04:40:08PM +0100, Ben Hutchings wrote:
>
> I think GRO is doing the right thing, and I can't think why we should
> see ip_summed = CHECKSUM_PARTIAL if the skb is forwarded by a bridge.  I

If it is was created by GRO then it should always be CHECKSUM_PARTIAL,
even if it came through a bridge.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
