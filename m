From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPSEC] Merge xfrm4_bundle_ok/xfrm6_bundle_ok/stale_bundle
Date: Wed, 16 Feb 2005 10:36:23 +1100
Message-ID: <20050215233623.GA28477@gondor.apana.org.au>
References: <20050129123803.GA17390@gondor.apana.org.au> <20050215141743.1010f2e6.davem@davemloft.net> <20050215225442.GA28142@gondor.apana.org.au> <20050215153104.419b1b84.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050215153104.419b1b84.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Feb 15, 2005 at 03:31:04PM -0800, David S. Miller wrote:
> On Wed, 16 Feb 2005 09:54:42 +1100
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > > Applied to my 2.6.12-pending tree.  Thanks a lot.
> > 
> > Sorry Dave, but that patch has a critical error in stale_bundle
> > where I forgot to add an exclamation mark.
> 
> So the relative fix is to just add a "!" to the return statement
> of stale_bundle() so that it reads:
> 
> 	return !xfrm_bundle_ok((struct xfrm_dst *)dst, NULL, AF_UNSPEC);
> 
> right?  If so, I'll just add that to my tree.

Yes.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
