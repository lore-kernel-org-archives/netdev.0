From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM]: Always reroute in tunnel mode
Date: Fri, 18 Feb 2005 09:10:31 +1100
Message-ID: <20050217221031.GA4554@gondor.apana.org.au>
References: <4214381F.5020507@trash.net> <20050217113654.GA10346@gondor.apana.org.au> <4214DF5B.3010608@trash.net> <20050217203805.GA4047@gondor.apana.org.au> <42150B36.5080609@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Maillist netdev <netdev@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <42150B36.5080609@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Feb 17, 2005 at 10:23:02PM +0100, Patrick McHardy wrote:
> 
> I don't consider this inconsistent, in fact it is consistent to what
> happens with other tunnels. We could get the behaviour you want (my

Well we'll have to disagree on that.  IMHO the flow with the internal
addresses equal to the external addresses over a tunnel mode SA should
be treated the same as that over a transport mode SA.

> patch + old behaviour for host-to-host tunnels) by looking at the
> policy selector, but I would prefer to always reroute. The change
> doesn't affect existing setups, as I said in my previous mail, it
> doesn't work properly since __xfrm4_find_bundle() ignores tos/fwmark
> and uses the route for src/dst that made the cache (first one used)
> for all tos/fwmark values, even if other routes exist.

Are you sure that it doesn't change existing behaviour? Suppose that
I had a socket bound to a specific device, doesn't the current code
use that device as long as we're sending to the remote IPsec gateway?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
