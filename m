From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: gso: Attempt to handle mega-GRO packets
Date: Thu, 7 Nov 2013 09:00:37 +0800
Message-ID: <20131107010037.GA28421@gondor.apana.org.au>
References: <1383499603.4291.71.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131104041108.GA22823@gondor.apana.org.au>
 <20131106013038.GA14894@gondor.apana.org.au>
 <20131106123900.GA20259@gondor.apana.org.au>
 <20131106133045.GA20931@gondor.apana.org.au>
 <20131106143927.GA21604@gondor.apana.org.au>
 <1383767241.21999.9.camel@edumazet-glaptop2.roam.corp.google.com>
 <1383783321.2878.6.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131107004704.GB28156@gondor.apana.org.au>
 <1383785763.2878.8.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:49656 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750841Ab3KGBAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 20:00:45 -0500
Content-Disposition: inline
In-Reply-To: <1383785763.2878.8.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 06, 2013 at 04:56:03PM -0800, Eric Dumazet wrote:
> On Thu, 2013-11-07 at 08:47 +0800, Herbert Xu wrote:
> > On Wed, Nov 06, 2013 at 04:15:21PM -0800, Eric Dumazet wrote:
> > >
> > > Here is the patch I came into (I tested it and it works very fine)
> > 
> > Thanks.  However, unless I'm missing something aren't you now
> > copying every linear skb frag_list?  With the current code we
> > just do a clone and add the headers.
> 
> No copy at all.
> 
> As explained, all RX skb are now backed to a page frag.  (see
> skb->head_frag)

Even if we have called pskb_expand_head on it?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
