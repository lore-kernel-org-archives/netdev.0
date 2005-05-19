From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: assertion (!atomic_read(&sk->sk_rmem_alloc)) failed at net/netlink/af_netlink.c (122)
Date: Fri, 20 May 2005 07:34:57 +1000
Message-ID: <20050519213457.GB24024@gondor.apana.org.au>
References: <20050512104229.GB25631@gondor.apana.org.au> <1115895482.30106.95.camel@tsc-6.cph.tpack.net> <20050512110738.GA5937@gondor.apana.org.au> <20050519.124921.115910096.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tommy.christensen@tpack.net, chamas@h4.dion.ne.jp, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050519.124921.115910096.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 19, 2005 at 12:49:21PM -0700, David S. Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Thu, 12 May 2005 21:07:38 +1000
> 
> > On Thu, May 12, 2005 at 12:58:03PM +0200, Tommy Christensen wrote:
> > > 
> > > Signed-off-by: Tommy S. Christensen <tommy.christensen@tpack.net>
> > 
> > Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Hmmm, should I undo Tommy's one-liner skb_orphan() change
> then add this one instead?

Please do since the first one had a subtle bug.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
