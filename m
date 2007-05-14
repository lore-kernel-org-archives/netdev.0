From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tbf scheduler: TSO support (updated)
Date: Mon, 14 May 2007 16:04:40 +1000
Message-ID: <E1HnTfk-0004z5-00@gondolin.me.apana.org.au>
References: <20070514.012125.105712952.taka@valinux.co.jp>
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	kaber@trash.net, davem@davemloft.net, linux-net@vger.kernel.org
To: taka@valinux.co.jp (Hirokazu Takahashi)
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <20070514.012125.105712952.taka@valinux.co.jp>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hirokazu Takahashi <taka@valinux.co.jp> wrote:
>
> Uhh, you are right.
> skb_shinfo(skb)->gso_segs and skb_shinfo(skb)->gso_size should be used.

Actually forget about gso_segs, it's only filled in for TCP.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
