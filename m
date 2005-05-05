From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: oops in ip_rcv
Date: Fri, 6 May 2005 09:49:11 +1000
Message-ID: <20050505234911.GA30980@gondor.apana.org.au>
References: <20050505101542.GB7916@krispykreme> <E1DTeis-0005gu-00@gondolin.me.apana.org.au> <20050505130904.GA16593@krispykreme> <20050505112624.3ffd7f3d.davem@davemloft.net> <20050505213740.GB29526@gondor.apana.org.au> <20050505214453.GA29853@gondor.apana.org.au> <20050505150943.566280f0.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050505150943.566280f0.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 05, 2005 at 03:09:43PM -0700, David S. Miller wrote:
> 
> Of course... But I don't want to apply this until Anton
> tells us how in the world he is receiving packets so
> early in the boot.

Alright, that's simply a matter of dropping a BUG into netif_rx.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
