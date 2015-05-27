From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v3 PATCH 0/8] crypto: Convert all AEAD users to new interface
Date: Wed, 27 May 2015 16:39:11 +0800
Message-ID: <20150527083911.GA27432@gondor.apana.org.au>
References: <20150521103938.GA23035@gondor.apana.org.au>
 <20150522082708.GA3507@gondor.apana.org.au>
 <20150527080105.GA26751@gondor.apana.org.au>
 <1432714550.2159.4.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Stephan Mueller <smueller@chronox.de>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1432714550.2159.4.camel@sipsolutions.net>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 27, 2015 at 10:15:50AM +0200, Johannes Berg wrote:
> 
> Do you think it'd be feasible at all to somehow override the
> aead_request_set_crypt() and aead_request_set_ad() functions or so to do
> something that works on older kernels (and thus older crypto subsystems)
> or do you think I just shouldn't bother looking at that and just add
> ifdefs to "undo" your changes in this series on older kernels?

Another option is to backport the new interface to the older kernel.

You only need something like

https://patchwork.kernel.org/patch/6452601/

for the older kernel to support the new interface along with the
old interface.

Note that this patch itself won't be good enough because I have since
removed cryptoff.  But it illustrates the amount of code you need.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
