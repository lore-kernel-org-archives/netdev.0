From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: arp_hash
Date: Mon, 23 Mar 2015 09:51:04 +1100
Message-ID: <20150322225104.GA8853@gondor.apana.org.au>
References: <20150322114204.GA5010@gondor.apana.org.au>
 <1427028981.25985.48.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150322215612.GA8274@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Roland Dreier <roland@purestorage.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:55880 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751854AbbCVWvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 18:51:07 -0400
Content-Disposition: inline
In-Reply-To: <20150322215612.GA8274@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 23, 2015 at 08:56:12AM +1100, Herbert Xu wrote:
> On Sun, Mar 22, 2015 at 05:56:21AM -0700, Eric Dumazet wrote:
> > On Sun, 2015-03-22 at 22:42 +1100, Herbert Xu wrote:
> > > 
> > > While googling I found the 2011 discussion on changing the arp_hash
> > > function.  I must say that I'm not really impressed by the new
> > > function that replaced jhash :)
> > > 
> > > 	u32 key = *(const u32 *)pkey;
> > > 	u32 val = key ^ hash32_ptr(dev);
> > > 
> > > 	return val * hash_rnd[0];
> 
> In fact this function is worse than I thought.  Because the IP

OK I'm wrong because net/core/neighbour.c uses only the high-order
bits of the hash.

Sorry for the noise.
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
