From: "David S. Miller" <davem@davemloft.net>
Subject: Re: design for TSO performance fix
Date: Thu, 27 Jan 2005 21:19:40 -0800
Message-ID: <20050127211940.31f97ed3.davem@davemloft.net>
References: <20050127163146.33b01e95.davem@davemloft.net>
	<E1CuKzJ-0001mY-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1CuKzJ-0001mY-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 28 Jan 2005 12:31:53 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> > 2) As a result of #1, all the pcount crap goes away.
> >   The need for two MSS state variables (mss_cache,
> >   and mss_cache_std) and assosciated complexity is
> >   eliminated as well.
> 
> Does this mean that we'll start counting bytes instead
> of packets?
> 
> If not then please let me know on how you plan to do the
> packet counting.

Things will be same as what we have now, except multi-packet
SKBs will no longer exist in the retransmit queue.

> The other good thing about this is that if we do this for all
> packets including non-TSO ones, then the TCP stack doesn't have
> to own the TCP/IP headers at all.  Then we can stop worrying
> about the TSO/COW mangling.

Hmmm, have to think about that some more.
