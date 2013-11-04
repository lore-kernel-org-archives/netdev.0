From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v3 net-next] net: introduce dev_set_forwarding()
Date: Mon, 4 Nov 2013 14:22:02 +0800
Message-ID: <20131104062202.GA23719@gondor.apana.org.au>
References: <20131103122824.GA17394@gondor.apana.org.au>
 <1383496104.4291.69.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131103163103.GA18894@gondor.apana.org.au>
 <1383499603.4291.71.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131104041108.GA22823@gondor.apana.org.au>
 <1383538982.4291.80.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131104042913.GA23021@gondor.apana.org.au>
 <1383541254.4291.82.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131104052321.GA23252@gondor.apana.org.au>
 <1383545155.4291.89.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:44402 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750830Ab3KDGWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Nov 2013 01:22:11 -0500
Content-Disposition: inline
In-Reply-To: <1383545155.4291.89.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 03, 2013 at 10:05:55PM -0800, Eric Dumazet wrote:
>
> > I think we can definitely improve our behaviour the CPU-bound case.
> > Right now if we encounter something we can't hold for GRO we
> > start processing it right away.  Instead we can place it in a
> > list for later processing together with the GRO packets.
> > 
> > This way GRO packets are not penalised by non-GRO packets.
> > 
> > You can then use the usual NAPI budget to minimise latency and
> > ensure scheduling fairness.
> 
> We had these latencies only dealing with TCP packets, all GRO
> candidates.
> 
> Really, I think we have used GRO at large scale here at Google ;)

So what NICs were you using that had this issue?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
