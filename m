From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: design for TSO performance fix
Date: Fri, 28 Jan 2005 16:44:41 +1100
Message-ID: <20050128054441.GA8260@gondor.apana.org.au>
References: <20050127163146.33b01e95.davem@davemloft.net> <E1CuKzJ-0001mY-00@gondolin.me.apana.org.au> <20050127211940.31f97ed3.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050127211940.31f97ed3.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jan 27, 2005 at 09:19:40PM -0800, David S. Miller wrote:
>
> > Does this mean that we'll start counting bytes instead
> > of packets?
> > 
> > If not then please let me know on how you plan to do the
> > packet counting.
> 
> Things will be same as what we have now, except multi-packet
> SKBs will no longer exist in the retransmit queue.

Colour me confused then.  How are you going to remember the
packet boundaries which we need to do if we're going to keep
counting packets instead of bytes?
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
