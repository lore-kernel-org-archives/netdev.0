From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Clean up fib_hash datastructures
Date: Tue, 21 Sep 2004 13:42:12 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040921034212.GA28462@gondor.apana.org.au>
References: <20040918203319.24004d6e.davem@davemloft.net> <1095645106.1048.190.camel@jzny.localdomain> <20040919195351.0b3560e6.davem@davemloft.net> <1095686672.1049.301.camel@jzny.localdomain> <20040920121123.70baf895.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040920121123.70baf895.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Sep 20, 2004 at 07:11:23PM +0000, David S. Miller wrote:
> 
> I believe I was successful in preserving existing behavior, but
> I wonder if it makes sense any longer.  CONFIG_IP_ROUTE_TOS
> changes not one data structure.  It does exactly:

Yes CONFIG_IP_ROUTE_TOS has out-lived its usefulness.  It has
always seemed half-hearted compared to CONFIG_IP_ROUTE_FWMARK.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
