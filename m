From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] skb pcount with MTU discovery
Date: Sun, 3 Apr 2005 05:35:47 +1000
Message-ID: <20050402193547.GB25157@gondor.apana.org.au>
References: <E1DHUvP-00050C-00@gondolin.me.apana.org.au> <Pine.LNX.4.58.0504021030120.21013@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: John Heffner <jheffner@psc.edu>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0504021030120.21013@dexter.psc.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Apr 02, 2005 at 10:32:32AM -0500, John Heffner wrote:
> On Sat, 2 Apr 2005, Herbert Xu wrote:
> 
> > How about fixing tcp_snd_test directly like this?
> 
> I tried that first, but it caused a panic.  I assumed some other point in
> the code assumed that invariant that if TSO is disabled then tso_segs==1.
> I didn't investigate though.

Do you remember what the panic looked like? Perhaps it was because
tso_segs wasn't set at all?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
