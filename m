From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: gso: Attempt to handle mega-GRO packets
Date: Wed, 6 Nov 2013 12:07:17 +0800
Message-ID: <20131106040717.GA15711@gondor.apana.org.au>
References: <20131029.194446.2215574000648693370.davem@davemloft.net>
 <1383091610.1534.29.camel@bwh-desktop.uk.level5networks.com>
 <1383400897.4291.47.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131103122824.GA17394@gondor.apana.org.au>
 <1383496104.4291.69.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131103163103.GA18894@gondor.apana.org.au>
 <1383499603.4291.71.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131104041108.GA22823@gondor.apana.org.au>
 <20131106013038.GA14894@gondor.apana.org.au>
 <1383702347.4291.152.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:46782 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755373Ab3KFEH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 23:07:29 -0500
Content-Disposition: inline
In-Reply-To: <1383702347.4291.152.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 05, 2013 at 05:45:47PM -0800, Eric Dumazet wrote:
>
> Hmm, I do not think fskb has the headers in the general case.

Only GRO produces such packets, see the changeset where I added
frag_list support to skb_setgment

	89319d3801d1d3ac29c7df1f067038986f267d29

> It might work in the GRO case only.

Any chance you guys can test this patch out?

Thanks!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
