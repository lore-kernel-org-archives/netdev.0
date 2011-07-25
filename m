From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next] skbuff: clear tx zero-copy flag
Date: Mon, 25 Jul 2011 17:57:11 +0800
Message-ID: <20110725095711.GA30831@gondor.apana.org.au>
References: <1310195566.25391.6.camel@localhost.localdomain> <20110725004200.GA25794@gondor.apana.org.au> <20110725080743.GC7840@redhat.com> <20110725084057.GA30311@gondor.apana.org.au> <20110725094414.GA11776@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shirley Ma <mashirle@us.ibm.com>, davem@davemloft.net,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110725094414.GA11776@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 25, 2011 at 12:44:14PM +0300, Michael S. Tsirkin wrote:
>
> if yes that seems to always clone an skb, which in turn
> does the copy so we are fine?

Yes you're right, it should be safe.

However, I think we should add a WARN_ON to the splice skb path
so that should a packet find its way through a path that we haven't
thought of then at least we'll know about it.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
