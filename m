From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: gso: Attempt to handle mega-GRO packets
Date: Thu, 7 Nov 2013 08:39:47 +0800
Message-ID: <20131107003947.GB27976@gondor.apana.org.au>
References: <20131104041108.GA22823@gondor.apana.org.au>
 <20131106013038.GA14894@gondor.apana.org.au>
 <1383702347.4291.152.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131106040717.GA15711@gondor.apana.org.au>
 <1383711785.4291.156.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131106042858.GA15745@gondor.apana.org.au>
 <1383715222.4291.158.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131106080425.GA17556@gondor.apana.org.au>
 <20131106081638.GA17665@gondor.apana.org.au>
 <1383750341.4291.166.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com, mst@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:39736 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751936Ab3KGAjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 19:39:53 -0500
Content-Disposition: inline
In-Reply-To: <1383750341.4291.166.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 06, 2013 at 07:05:41AM -0800, Eric Dumazet wrote:
> 
> Sure, if your host has infinite amount of memory, we can remove all the
> silly and expensive and bore some checks we added in the stack against
> skb->truesize.
> 
> And yes, network stack will be faster.
> 
> But in real life, we have memory constraints.

With intra-page fragmentation, it's not clear that you'd be better
off with this patch in the long run anyway.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
