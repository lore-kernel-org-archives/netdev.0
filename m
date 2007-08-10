From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 1/24] make atomic_read() behave consistently on alpha
Date: Fri, 10 Aug 2007 11:08:20 +0200
Message-ID: <200708101108.20897.ak@suse.de>
References: <E1IJPkg-0000x0-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, csnook@redhat.com,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, heiko.carstens@de.ibm.com,
	davem@davemloft.net, schwidefsky@de.ibm.com, wensong@linux-vs.org,
	horms@verge.net.au, wjiang@resilience.com, cfriesen@nortel.com,
	zlynx@acm.org, rpjday@mindspring.com, jesper.juhl@gmail.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:56256 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752842AbXHJJIf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 05:08:35 -0400
In-Reply-To: <E1IJPkg-0000x0-00@gondolin.me.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 10 August 2007 10:21:46 Herbert Xu wrote:
> Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> >
> > The compiler is within its rights to read a 32-bit quantity 16 bits at
> > at time, even on a 32-bit machine.  I would be glad to help pummel any
> > compiler writer that pulls such a dirty trick, but the C standard really
> > does permit this.
> 
> Code all over the kernel assumes that 32-bit reads/writes
> are atomic so while such a compiler might be legal it certainly
> can't compile Linux.

Yes, the kernel requirements are much stricter than ISO-C. And besides
it is a heavy user of C extensions anyways. On the other hand some of the
C99 extensions are not allowed. And then there is sparse, which enforces
a language which sometimes is quite far from standard C. You could say it is 
written in Linux-C, not ISO C. 

-Andi
