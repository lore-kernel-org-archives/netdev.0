From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/24] make atomic_read() behave consistently on alpha
Date: Sat, 11 Aug 2007 08:43:22 +0800
Message-ID: <20070811004322.GA13178@gondor.apana.org.au>
References: <E1IJPkg-0000x0-00@gondolin.me.apana.org.au> <442f95ba19f8622ce04cf0334f34be11@kernel.crashing.org> <20070811000029.GA12779@gondor.apana.org.au> <ef7e94b08a6515d33039d187e04db5db@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paulmck@linux.vnet.ibm.com, heiko.carstens@de.ibm.com,
	horms@verge.net.au, linux-kernel@vger.kernel.org,
	csnook@redhat.com, rpjday@mindspring.com, netdev@vger.kernel.org,
	ak@suse.de, cfriesen@nortel.com, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, jesper.juhl@gmail.com,
	linux-arch@vger.kernel.org, zlynx@acm.org, schwidefsky@de.ibm.com,
	davem@davemloft.net, wensong@linux-vs.org, wjiang@resilience.com
To: Segher Boessenkool <segher@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1395 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754653AbXHKAoF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 20:44:05 -0400
Content-Disposition: inline
In-Reply-To: <ef7e94b08a6515d33039d187e04db5db@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 11, 2007 at 02:38:40AM +0200, Segher Boessenkool wrote:
> >>That means GCC cannot compile Linux; it already optimises
> >>some accesses to scalars to smaller accesses when it knows
> >>it is allowed to.  Not often though, since it hardly ever
> >>helps in the cost model it employs.
> >
> >Please give an example code snippet + gcc version + arch
> >to back this up.
> 
> 	unsigned char f(unsigned long *p)
> 	{
> 	        return *p & 1;
> 	}

This doesn't really matter since we only care about the LSB.
Do you have an example where gcc reads it non-atmoically and
we care about all parts?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
