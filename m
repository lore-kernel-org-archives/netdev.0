From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPSEC] Merge xfrm4_bundle_ok/xfrm6_bundle_ok/stale_bundle
Date: Tue, 15 Feb 2005 15:31:04 -0800
Message-ID: <20050215153104.419b1b84.davem@davemloft.net>
References: <20050129123803.GA17390@gondor.apana.org.au>
	<20050215141743.1010f2e6.davem@davemloft.net>
	<20050215225442.GA28142@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050215225442.GA28142@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 16 Feb 2005 09:54:42 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> > Applied to my 2.6.12-pending tree.  Thanks a lot.
> 
> Sorry Dave, but that patch has a critical error in stale_bundle
> where I forgot to add an exclamation mark.

So the relative fix is to just add a "!" to the return statement
of stale_bundle() so that it reads:

	return !xfrm_bundle_ok((struct xfrm_dst *)dst, NULL, AF_UNSPEC);

right?  If so, I'll just add that to my tree.
