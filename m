From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] fix long-standing bug in 2.6/2.4 skb_copy/skb_copy_expand
Date: Mon, 09 May 2005 13:04:34 +1000
Message-ID: <E1DUyZO-0004Fp-00@gondolin.me.apana.org.au>
References: <20050508143259.GA30676@shaftnet.org>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S263029AbVEIDFN@vger.kernel.org>
To: pizza@shaftnet.org (Stuffed Crust)
In-Reply-To: <20050508143259.GA30676@shaftnet.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stuffed Crust <pizza@shaftnet.org> wrote:
> 
> This is, fortunately, generally true.  But if the alloc_skb function 
> allocates extra head room (ie calls skb_reserve() on the skb before it 
> passes it to the callee, this doesn't quite work.  Instead, it should be 
> rewritten as:

As far as I know the alloc_skb funciton in the kernel tree doesn't do
that so your patch is not necessary unless we decide to change the way
alloc_skb works.  If that's what you want then please provide a patch
to alloc_skb and a rationale as to why we should do that.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
