From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [BUG] overflow in net/ipv4/route.c rt_check_expire()
Date: Sun, 3 Apr 2005 21:57:08 +0200
Message-ID: <16976.19092.562006.246545@robur.slu.se>
References: <E1DHdsP-0003Lr-00@gondolin.me.apana.org.au>
	<424E641A.1020609@cosmosbay.com>
	<16974.41648.568927.54429@robur.slu.se>
	<20050402193224.GA25157@gondor.apana.org.au>
	<20050402115528.11f71a3c.davem@davemloft.net>
	<20050403074337.GA8083@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, Robert.Olsson@data.slu.se,
        dada1@cosmosbay.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050403074337.GA8083@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Herbert Xu writes:

 > We could also move rt_cache_flush into a kernel thread.  When the
 > number of chains is large this function is really expensive for a
 > softirq handler.

 It can also be done via /proc and left to administrators to find 
 suitable policy. Kernel just provides the mechanism to rehash.


						--ro
