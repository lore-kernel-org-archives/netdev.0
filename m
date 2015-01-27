From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 0/2] rhashtable: Add walk iterator primitives and use them in
 netlink
Date: Wed, 28 Jan 2015 10:19:50 +1100
Message-ID: <20150127231950.GA11374@gondor.apana.org.au>
References: <cover.1421759056.git.tgraf@suug.ch>
 <cce004895ab6bcef267e2133a1c7ecab0fac403b.1421759056.git.tgraf@suug.ch>
 <54BF5FC4.4070808@windriver.com>
 <20150121121748.GD12570@casper.infradead.org>
 <20150122084924.GA4720@gondor.apana.org.au>
 <20150125232040.GA17936@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ying Xue <ying.xue@windriver.com>, davem@davemloft.net,
	kaber@trash.net, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150125232040.GA17936@gondor.apana.org.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 26, 2015 at 10:20:40AM +1100, Herbert Xu wrote:
> 
> Here are the first two patches, one to add the primitives and one
> to demonstrate its use in netlink.  In fact while testing this I
> found that the existing netlink walking code is totally broken.

So this is a repost of the same thing.  These lockless iterators
won't be usable by netfilter as it stands because it wants to do
nested walks and also isn't currently lockless.

However, I'll wait for Patrick to post his pending patches to see
what exactly he needs before implementing helpers for that case.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
