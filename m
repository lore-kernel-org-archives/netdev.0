From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v2 PATCH 5/13] crypto: testmgr - Switch to new AEAD interface
Date: Sun, 7 Jun 2015 15:06:43 +0800
Message-ID: <20150607070643.GA19281@gondor.apana.org.au>
References: <20150522082708.GA3507@gondor.apana.org.au>
 <E1YviM1-0000xu-GV@gondolin.me.apana.org.au>
 <5570CDF7.4090308@intel.com>
 <20150605035747.GC527@gondor.apana.org.au>
 <55721E38.2060801@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Stephan Mueller <smueller@chronox.de>
To: Tadeusz Struk <tadeusz.struk@intel.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55721E38.2060801@intel.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 05, 2015 at 03:10:00PM -0700, Tadeusz Struk wrote:
> 
> Yes, assuming that one is using req->assoclen not only req->assoc ;)

You're quite right.  I found two more drivers that need to be fixed
before this goes mainline.

> When do you expect the assoc will be removed?

It will be removed once every single driver has been converted.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
