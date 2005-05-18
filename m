From: Andi Kleen <ak@muc.de>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Wed, 18 May 2005 02:04:14 +0200
Message-ID: <m11x85762p.fsf@muc.de>
References: <E1DYBED-0006wa-00@gondolin.me.apana.org.au>
	<Pine.LNX.4.61.0505171612440.3335@linux.site>
	<20050517232556.GA26846@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dlstevens@us.ibm.com, rick.jones2@hp.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050517232556.GA26846@gondor.apana.org.au> (Herbert Xu's
 message of "Wed, 18 May 2005 09:25:56 +1000")
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu <herbert@gondor.apana.org.au> writes:
>
> Perhaps you misunderstood what I was saying.  I meant are there any
> extant systems that would transmit 1 set of fragments to host A with
> id x, then 65535 packets host B, and then wrap around and send a new
> set of fragments to host A with idx.
>
> Linux will never do this thanks to inetpeer.c.

It will, you just need enough other hosts to thrash inetpeer. How many
you need depends on your available memory.

-Andi
