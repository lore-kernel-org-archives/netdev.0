From: Tadeusz Struk <tadeusz.struk@intel.com>
Subject: Re: [v2 PATCH 5/13] crypto: testmgr - Switch to new AEAD interface
Date: Fri, 05 Jun 2015 15:10:00 -0700
Message-ID: <55721E38.2060801@intel.com>
References: <20150522082708.GA3507@gondor.apana.org.au> <E1YviM1-0000xu-GV@gondolin.me.apana.org.au> <5570CDF7.4090308@intel.com> <20150605035747.GC527@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Stephan Mueller <smueller@chronox.de>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:24408 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750869AbbFEWJy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Jun 2015 18:09:54 -0400
In-Reply-To: <20150605035747.GC527@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/04/2015 08:57 PM, Herbert Xu wrote:
> Existing AEAD implementations should be completely unaware of
> the new interface because we recreate the old req->assoc in the
> crypto API.

Yes, assuming that one is using req->assoclen not only req->assoc ;)

> 
> However, if you are creating a new AEAD implementation then yes
> you should stop using req->assoc and fetch it from req->src instead.

When do you expect the assoc will be removed?
