From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: gso: Attempt to handle mega-GRO packets
Date: Thu, 7 Nov 2013 10:15:19 +0800
Message-ID: <20131107021519.GA29081@gondor.apana.org.au>
References: <20131106042858.GA15745@gondor.apana.org.au>
 <1383715222.4291.158.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131106080425.GA17556@gondor.apana.org.au>
 <20131106081638.GA17665@gondor.apana.org.au>
 <20131106131252.GA20680@gondor.apana.org.au>
 <1383750070.4291.163.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131107003658.GA27976@gondor.apana.org.au>
 <1383786208.2878.15.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131107014724.GA28946@gondor.apana.org.au>
 <1383789758.2878.32.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com, mst@redhat.com,
	Jason Wang <jasowang@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:41785 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751924Ab3KGCP3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 21:15:29 -0500
Content-Disposition: inline
In-Reply-To: <1383789758.2878.32.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 06, 2013 at 06:02:38PM -0800, Eric Dumazet wrote:
> 
> 4K page will contain 2 frags and they will coalesce.
> 
> Performance will still be quite good.
>
> We probably add a tweak, to not have any hole in this case.

Also have you considered the security aspect of this? If you have
two skbs sharing a page, and one gets transmitted to a third party
using zero-copy, the other unrelated skb's content may become visible
where it shouldn't.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
