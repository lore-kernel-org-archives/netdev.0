From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Set truesize in pskb_expand_head
Date: Mon, 27 Sep 2004 12:27:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927122700.4696e416.davem@davemloft.net>
References: <20040924232053.GA7807@gondor.apana.org.au>
	<20040924163328.7597352c.davem@davemloft.net>
	<20040924233555.GA7962@gondor.apana.org.au>
	<20040924233713.GA8001@gondor.apana.org.au>
	<20040924164540.2d750572.davem@davemloft.net>
	<20040925000503.GA10873@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040925000503.GA10873@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 25 Sep 2004 10:05:03 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Here is the real patch.

Ok.. idea wise.  But, why are you subtracting 'delta' from
skb->truesize?  That's the amount actually used not the
amount trimmed by pskb_expand_head().
