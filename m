From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [BUG] overflow in net/ipv4/route.c rt_check_expire()
Date: Sun, 3 Apr 2005 21:36:52 +0200
Message-ID: <16976.17876.832677.945878@robur.slu.se>
References: <E1DHdsP-0003Lr-00@gondolin.me.apana.org.au>
	<424E641A.1020609@cosmosbay.com>
	<16974.41648.568927.54429@robur.slu.se>
	<20050402193224.GA25157@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Eric Dumazet <dada1@cosmosbay.com>, davem@davemloft.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050402193224.GA25157@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Herbert Xu writes:

 > Incidentally we should change the way the rehashing is triggered.
 > Instead of doing it regularly, we can do it when we notice that a
 > specific hash chain grows beyond a certain size.

 > The idea is that if someone is attacking our hash then they can
 > only do so by lengthening the chains.  If they're not doing that
 > then even if they knew how to attack us we don't really care.


 Well I don't see how we detect the need for rehash just be looking
 at the hash chains. How does the the "lengthening" look like that
 are allowed to trigger a rehash?

 Agree with Dave that we can increase the interval to start with.


					  --ro
