From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [TCP] Fixed mss in tcp_init_cwnd
Date: Tue, 28 Sep 2004 09:09:38 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927230938.GA8022@gondor.apana.org.au>
References: <20040927080828.GA12056@gondor.apana.org.au> <20040927120031.55fb4a49.davem@davemloft.net> <20040927220240.GA7633@gondor.apana.org.au> <20040927160454.67cd1e11.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040927160454.67cd1e11.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Sep 27, 2004 at 04:04:54PM -0700, David S. Miller wrote:
>
> > IMHO we should still fix it though at least for consistency.
> 
> That early on in the connection, it should be setting both
> values, right?  If so your patch still needs a tweak. :)

I'm not saying that this patch makes any difference in terms of
run-time results.  At that point both mss_cache and mss_cache_std
should contain the same values.

However, since the value that's intended here is the physical MSS,
we should use mss_cache_std for the sake of consistency.

The only reason I spotted this at all is because I grepped -w for
mss_cache and found this function as one of the very few users.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
