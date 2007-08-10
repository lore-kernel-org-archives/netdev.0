From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/24] make atomic_read() behave consistently on alpha
Date: Fri, 10 Aug 2007 16:21:46 +0800
Message-ID: <E1IJPkg-0000x0-00@gondolin.me.apana.org.au>
References: <20070809161024.GC8424@linux.vnet.ibm.com>
Cc: csnook@redhat.com, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org, ak@suse.de,
	heiko.carstens@de.ibm.com, davem@davemloft.net,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3240 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757030AbXHJIjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 04:39:01 -0400
In-Reply-To: <20070809161024.GC8424@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
>
> The compiler is within its rights to read a 32-bit quantity 16 bits at
> at time, even on a 32-bit machine.  I would be glad to help pummel any
> compiler writer that pulls such a dirty trick, but the C standard really
> does permit this.

Code all over the kernel assumes that 32-bit reads/writes
are atomic so while such a compiler might be legal it certainly
can't compile Linux.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
