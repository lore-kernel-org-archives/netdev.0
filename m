From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [UNTESTED] Add hardware-assisted VLAN support for GRO
Date: Mon, 5 Jan 2009 20:47:30 +1100
Message-ID: <20090105094730.GA15756@gondor.apana.org.au>
References: <20090102054714.GA23106@gondor.apana.org.au> <20090102054921.GA23174@gondor.apana.org.au> <20090104.225727.236263263.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:56474 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751844AbZAEJrf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 04:47:35 -0500
Content-Disposition: inline
In-Reply-To: <20090104.225727.236263263.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 04, 2009 at 10:57:27PM -0800, David Miller wrote:
> 
> These changes look fine to me, although the skb->dev trick
> is... exciting :-)

Yeah it's not for the faint-hearted :) Actually it's easy to
fix, all we have to do is give netif_nit_deliver a dev argument
and the hack goes away.  I'll do that when I send the patches
for real.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
