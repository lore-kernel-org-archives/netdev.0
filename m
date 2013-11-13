From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: gso: Handle new frag_list of frags GRO packets
Date: Wed, 13 Nov 2013 10:25:25 +0800
Message-ID: <20131113022525.GA28236@gondor.apana.org.au>
References: <1383767241.21999.9.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131107004339.GA28156@gondor.apana.org.au>
 <20131107062234.GA31156@gondor.apana.org.au>
 <20131107070335.GA31638@gondor.apana.org.au>
 <20131107070647.GB31638@gondor.apana.org.au>
 <20131111185207.GA12277@gondor.apana.org.au>
 <1384305223.28458.58.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131113012920.GA27897@gondor.apana.org.au>
 <1384309034.28458.69.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131113022243.GA28204@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:53421 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755513Ab3KMCZc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 21:25:32 -0500
Content-Disposition: inline
In-Reply-To: <20131113022243.GA28204@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 13, 2013 at 10:22:43AM +0800, Herbert Xu wrote:
> On Tue, Nov 12, 2013 at 06:17:14PM -0800, Eric Dumazet wrote:
> > On Wed, 2013-11-13 at 09:29 +0800, Herbert Xu wrote:
> > 
> > > I presume this is on a NIC that produces completely linear packets?
> > 
> > Sorry : with mlx4 driver, GRO builds nice skbs with one page frag per
> > MSS, so each skb found on frag_list is fully loaded with 16 MSS
> 
> OK, so what are the numbers when GRO is off completely?

Actually don't bother, it's not a fair comparison at all.  In the
first case we're doing TSO and with my patch we're only doing GSO.

So a better test for the time being would be to test with TSO
disabled in both cases.

In the mean time I'm cooking up a patch to generate TSO packets.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
