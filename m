From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [TCP] Fixed mss in tcp_init_cwnd
Date: Tue, 28 Sep 2004 08:02:40 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927220240.GA7633@gondor.apana.org.au>
References: <20040927080828.GA12056@gondor.apana.org.au> <20040927120031.55fb4a49.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040927120031.55fb4a49.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Sep 27, 2004 at 12:00:31PM -0700, David S. Miller wrote:
> On Mon, 27 Sep 2004 18:08:28 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > The MSS in tcp_init_cwnd should be the real one instead of the TSO value.
> 
> This happens too early in the connections lifetime
> to make a difference for anything.

I know.  That's why I put it in a different thread.

IMHO we should still fix it though at least for consistency.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
