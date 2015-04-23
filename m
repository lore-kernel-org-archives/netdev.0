From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: CCM/GCM implementation defect
Date: Fri, 24 Apr 2015 07:17:03 +0800
Message-ID: <20150423231703.GB26635@gondor.apana.org.au>
References: <20150423032619.GA17648@gondor.apana.org.au>
 <20150423114533.GI8928@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Paul Wouters <pwouters@redhat.com>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150423114533.GI8928@secunet.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 23, 2015 at 01:45:34PM +0200, Steffen Klassert wrote:
>
> Adding a second template for the correct implementation is
> probaply the only thing that we can do if we don't want to
> break backwards compatibility. But maybe we can add a warning
> to the old implementation, such that users notice that they
> use a broken version.

If we are going to do a warning I think the place to do it would
be in xfrm_algo.c.  We could add an insecure/warning flag and if
then print a warning if said algorithm is used.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
