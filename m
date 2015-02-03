From: David Miller <davem@davemloft.net>
Subject: Re: netfilter: Use rhashtable walk iterator
Date: Mon, 02 Feb 2015 19:19:42 -0800 (PST)
Message-ID: <20150202.191942.1642188549383264965.davem@davemloft.net>
References: <20150129.144246.1383921666389409323.davem@davemloft.net>
	<20150131031356.GA26781@gondor.apana.org.au>
	<20150131043151.GA27524@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, ying.xue@windriver.com, kaber@trash.net,
	paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150131043151.GA27524@gondor.apana.org.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 31 Jan 2015 15:31:51 +1100

> On Sat, Jan 31, 2015 at 02:13:56PM +1100, Herbert Xu wrote:
>> 
>> No problems.  Here is a new version of these two patches which
>> hopefully should work on netfilter as well.
> 
> And here is the patch for netfilter.
> 
> -- >8 --
> This patch gets rid of the manual rhashtable walk in nft_hash
> which touches rhashtable internals that should not be exposed.
> It does so by using the rhashtable iterator primitives.
>     
> Note that I'm leaving nft_hash_destroy alone since it's only
> invoked on shutdown and it shouldn't be affected by changes
> to rhashtable internals (or at least not what I'm planning to
> change).
>     
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-next.
