From: Jan Killius <jkillius@arcor.de>
Subject: Re: r8169: page allocation failure
Date: Sun, 17 Oct 2004 12:13:04 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410171213.04418.jkillius@arcor.de>
References: <20041016204848.GB21849@electric-eye.fr.zoreil.com> <E1CJ5lg-0005eC-00@gondolin.me.apana.org.au> <20041017090837.GA24362@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@oss.sgi.com,
        davem@davemloft.net, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041017090837.GA24362@gondor.apana.org.au>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sunday 17 October 2004 11:08, Herbert Xu wrote:
> On Sun, Oct 17, 2004 at 05:47:52PM +1000, Herbert Xu wrote:
> > It should instead allocate a new skb of 1 mss.  I'll work on it.
>
> In fact it was allocating space that it wasn't even using :)
>
> The following patch makes it allocate skb_headlen(skb) - len instead
> of skb->len - len.  When skb is linear there is no difference.  When
> it's non-linear we only ever copy the bytes in the header.
>
> Please let me know whether this fixes your problem.
Yes the patch solved the problem completely
>
> Cheers,

-- 
        Jan
