From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 0/2] rhashtable: Add walk iterator primitives and use them in
 netlink
Date: Mon, 26 Jan 2015 10:20:40 +1100
Message-ID: <20150125232040.GA17936@gondor.apana.org.au>
References: <cover.1421759056.git.tgraf@suug.ch>
 <cce004895ab6bcef267e2133a1c7ecab0fac403b.1421759056.git.tgraf@suug.ch>
 <54BF5FC4.4070808@windriver.com>
 <20150121121748.GD12570@casper.infradead.org>
 <20150122084924.GA4720@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ying Xue <ying.xue@windriver.com>, davem@davemloft.net,
	kaber@trash.net, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150122084924.GA4720@gondor.apana.org.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 22, 2015 at 07:49:24PM +1100, Herbert Xu wrote:
>
> Could you hold off for a bit? I've got some changes that touch
> this area that I'd like to push out.  Basically I'm trying to
> eliminate direct access of rhashtable internals from the existing
> users.

Here are the first two patches, one to add the primitives and one
to demonstrate its use in netlink.  In fact while testing this I
found that the existing netlink walking code is totally broken.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
