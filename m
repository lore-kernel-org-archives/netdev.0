From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC] Replace scatterlist with crypto_frag
Date: Mon, 06 Jun 2005 16:18:14 -0700 (PDT)
Message-ID: <20050606.161814.130845728.davem@davemloft.net>
References: <20050606230437.GA7172@gondor.apana.org.au>
	<20050606.160947.75190168.davem@davemloft.net>
	<20050606231405.GA7385@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hch@infradead.org, jmorris@redhat.com, linux-crypto@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20050606231405.GA7385@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 7 Jun 2005 09:14:05 +1000

> 1) We use it directly as a scratch buffer for now since the
> frags are always linearised currently.

And since skb_shinfo(skb)->nr_frags will be zero, nobody
will mistakedly look at the contents and interpret it as
some valid frags.  Right?
