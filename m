From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [v3 PATCH 0/8] crypto: Convert all AEAD users to new interface
Date: Wed, 27 May 2015 11:00:40 +0200
Message-ID: <1432717240.2159.5.camel@sipsolutions.net>
References: <20150521103938.GA23035@gondor.apana.org.au>
	 <20150522082708.GA3507@gondor.apana.org.au>
	 <20150527080105.GA26751@gondor.apana.org.au>
	 <1432714550.2159.4.camel@sipsolutions.net>
	 <20150527083911.GA27432@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Stephan Mueller <smueller@chronox.de>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20150527083911.GA27432@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-05-27 at 16:39 +0800, Herbert Xu wrote:
> On Wed, May 27, 2015 at 10:15:50AM +0200, Johannes Berg wrote:
> > 
> > Do you think it'd be feasible at all to somehow override the
> > aead_request_set_crypt() and aead_request_set_ad() functions or so to do
> > something that works on older kernels (and thus older crypto subsystems)
> > or do you think I just shouldn't bother looking at that and just add
> > ifdefs to "undo" your changes in this series on older kernels?
> 
> Another option is to backport the new interface to the older kernel.
> 
> You only need something like
> 
> https://patchwork.kernel.org/patch/6452601/
> 
> for the older kernel to support the new interface along with the
> old interface.

Right. Unfortunately, I can't typically rely on being able to make
changes to the kernel our driver is built against, and I don't think we
could do these changes otherwise.

johannes
