From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: gso: Attempt to handle mega-GRO packets
Date: Thu, 7 Nov 2013 15:33:49 +0800
Message-ID: <20131107073348.GA32083@gondor.apana.org.au>
References: <20131104041108.GA22823@gondor.apana.org.au>
 <20131106013038.GA14894@gondor.apana.org.au>
 <20131106123900.GA20259@gondor.apana.org.au>
 <20131106133045.GA20931@gondor.apana.org.au>
 <20131106143927.GA21604@gondor.apana.org.au>
 <1383767241.21999.9.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131107004339.GA28156@gondor.apana.org.au>
 <1383808262.9412.33.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131107071531.GA31857@gondor.apana.org.au>
 <1383809490.9412.50.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:59773 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754419Ab3KGHeA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 02:34:00 -0500
Content-Disposition: inline
In-Reply-To: <1383809490.9412.50.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 06, 2013 at 11:31:30PM -0800, Eric Dumazet wrote:
> On Thu, 2013-11-07 at 15:15 +0800, Herbert Xu wrote:
> 
> > So what in our stack violates this assumption? We've never handled
> > arbitrary frag_lists in GSO and I see no reason why we need to start
> > doing that now.
> 
> I do see this, skb_segment() is generic.

IOW there is nothing in our stack that violates this, great!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
