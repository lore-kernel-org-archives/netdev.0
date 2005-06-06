From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC] Replace scatterlist with crypto_frag
Date: Mon, 06 Jun 2005 16:09:47 -0700 (PDT)
Message-ID: <20050606.160947.75190168.davem@davemloft.net>
References: <20050606124043.GA625@gondor.apana.org.au>
	<20050606.154653.64001264.davem@davemloft.net>
	<20050606230437.GA7172@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hch@infradead.org, jmorris@redhat.com, linux-crypto@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20050606230437.GA7172@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 7 Jun 2005 09:04:37 +1000

> Bigger is better actually :) I'm now thinking of using the
> memory occupied by the frags array for IPsec crypto operations.
> So if it's bigger then it simply means that we can store more
> fragments.

So you want to use this area as a sort-of temporary
scratch pad for something other than scatterlist
information?  That's interesting if so...
