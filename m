From: "David S. Miller" <davem@davemloft.net>
Subject: Re: oops in ip_rcv
Date: Thu, 5 May 2005 15:09:43 -0700
Message-ID: <20050505150943.566280f0.davem@davemloft.net>
References: <20050505101542.GB7916@krispykreme>
	<E1DTeis-0005gu-00@gondolin.me.apana.org.au>
	<20050505130904.GA16593@krispykreme>
	<20050505112624.3ffd7f3d.davem@davemloft.net>
	<20050505213740.GB29526@gondor.apana.org.au>
	<20050505214453.GA29853@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050505214453.GA29853@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 6 May 2005 07:44:53 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Fri, May 06, 2005 at 07:37:40AM +1000, herbert wrote:
> > 
> > Could we delay the call of dev_add_pack(&ip_packet_type) until
> > the very end of inet_init? That way we're guaranteed to not
> > receive anything until it's ready.
> 
> This patch should do the trick.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Of course... But I don't want to apply this until Anton
tells us how in the world he is receiving packets so
early in the boot.

If I put this patch in now, he may get lazy just like me
and never try and figure out where they are coming from :)
