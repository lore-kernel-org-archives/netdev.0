From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v4 net-next] net: introduce dev_set_forwarding()
Date: Fri, 8 Nov 2013 11:23:59 +0800
Message-ID: <20131108032359.GA14132@gondor.apana.org.au>
References: <1383584130.1553.2.camel@bwh-desktop.uk.level5networks.com>
 <20131107.161755.355597965034457889.davem@davemloft.net>
 <20131107213111.GA6885@gondor.apana.org.au>
 <20131107.170651.1819930710384730745.davem@davemloft.net>
 <20131108021758.GA13467@gondor.apana.org.au>
 <1383878554.9412.153.camel@edumazet-glaptop2.roam.corp.google.com>
 <1383879113.9412.155.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:41229 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755679Ab3KHDYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 22:24:07 -0500
Content-Disposition: inline
In-Reply-To: <1383879113.9412.155.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 07, 2013 at 06:51:53PM -0800, Eric Dumazet wrote:
> On Thu, 2013-11-07 at 18:42 -0800, Eric Dumazet wrote:
> 
> > A normal TSO packets with 16 MSS setups a ~17 DMA descriptors,
> > while GSO requires 2 DMA descriptors per MSS, plus a lot of overhead
> > in sk_buff allocation/deallocation.
> 
> Not mentioning fact that a 64KB packet is adding latencies, since high
> prio packets have to wait the whole preceding 64KB packet has left the
> host.

That would be a bug in the GRO code since a high prio packet
shouldn't have been merged in the first place and therefore
the usual priority mechanism should allow it to preempt the
64KB packet.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
