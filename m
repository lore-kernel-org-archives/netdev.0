From: "David S. Miller" <davem@davemloft.net>
Subject: Re: r8169: page allocation failure
Date: Tue, 19 Oct 2004 22:30:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041019223029.35be700b.davem@davemloft.net>
References: <20041016204848.GB21849@electric-eye.fr.zoreil.com>
	<E1CJ5lg-0005eC-00@gondolin.me.apana.org.au>
	<20041017090837.GA24362@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, jkillius@arcor.de, netdev@oss.sgi.com,
        jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041017090837.GA24362@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 17 Oct 2004 19:08:37 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Sun, Oct 17, 2004 at 05:47:52PM +1000, Herbert Xu wrote:
> > 
> > It should instead allocate a new skb of 1 mss.  I'll work on it.
> 
> In fact it was allocating space that it wasn't even using :)
> 
> The following patch makes it allocate skb_headlen(skb) - len instead
> of skb->len - len.  When skb is linear there is no difference.  When
> it's non-linear we only ever copy the bytes in the header.
> 
> Please let me know whether this fixes your problem.

Looks great, good catch.  Patch applied.
