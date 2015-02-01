From: Patrick McHardy <kaber@trash.net>
Subject: Re: netfilter: Use rhashtable walk iterator
Date: Sun, 1 Feb 2015 07:45:27 +0000
Message-ID: <20150201074527.GA10054@acer.localdomain>
References: <20150122084924.GA4720@gondor.apana.org.au>
 <20150125232040.GA17936@gondor.apana.org.au>
 <20150127231950.GA11374@gondor.apana.org.au>
 <20150129.144246.1383921666389409323.davem@davemloft.net>
 <20150131031356.GA26781@gondor.apana.org.au>
 <20150131043151.GA27524@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, tgraf@suug.ch,
	ying.xue@windriver.com, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150131043151.GA27524@gondor.apana.org.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 31.01, Herbert Xu wrote:
> On Sat, Jan 31, 2015 at 02:13:56PM +1100, Herbert Xu wrote:
> > 
> > No problems.  Here is a new version of these two patches which
> > hopefully should work on netfilter as well.
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

Acked-by: Patrick McHardy <kaber@trash.net>

Thanks Herbert!
