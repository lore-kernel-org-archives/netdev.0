From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 0/3] Make rfc3686 template work with asynchronous
 block ciphers
Date: Sat, 29 Dec 2012 11:08:12 +1100
Message-ID: <20121229000812.GA29866@gondor.apana.org.au>
References: <20121228100448.11073.25546.stgit@localhost6.localdomain6>
 <20121228224248.GA29448@gondor.apana.org.au>
 <20121228.152311.290755667605168896.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jussi.kivilinna@mbnet.fi, linux-crypto@vger.kernel.org,
	steffen.klassert@secunet.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20121228.152311.290755667605168896.davem@davemloft.net>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 28, 2012 at 03:23:11PM -0800, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Sat, 29 Dec 2012 09:42:49 +1100
> 
> > On Fri, Dec 28, 2012 at 12:04:48PM +0200, Jussi Kivilinna wrote:
> >> I'm not sure how this patchset should be dealt with (should 1st patch go
> >> through different tree than 2nd and 3rd?), so therefore it's RFC.
> >> 
> >> Second patch makes rfc3686 template work with asynchronous block ciphers and
> >> third patch changes aesni-intel to use this template. First patch fixed problem
> >> in xfrm_algo found with help of 2nd and 3rd patches and without 1st patch
> >> 2nd patch breaks aes-ctr with IPSEC.
> > 
> > I think the easiest way is to have these patches go through Dave's
> > tree.
> 
> Better yet, Steffen's IPSEC tree :-)

Of course :)
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
