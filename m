From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Tue, 28 Sep 2004 07:32:33 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927213233.GC7243@gondor.apana.org.au>
References: <20040923164149.5368d291.davem@davemloft.net> <E1CBkIW-0001dF-00@gondolin.me.apana.org.au> <20040927025048.GA6723@gondor.apana.org.au> <20040926210029.22750d47.davem@davemloft.net> <20040927054541.GA8858@gondor.apana.org.au> <20040927120154.09fdcadf.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ak@suse.de, niv@us.ibm.com, andy.grover@gmail.com, anton@samba.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040927120154.09fdcadf.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Sep 27, 2004 at 12:01:54PM -0700, David S. Miller wrote:
>
> > tcp_current_mss() doesn't call tcp_sync_mss() unless the PMTU changes.
> 
> Good catch, probably we should make it do so when sk_route_caps
> indicates we are doing TSO.

Alternatively we could move the TSO code out of tcp_sync_mss() and
put it in tcp_current_mss() instead.  It seems to be the only one
using the factor anyway.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
