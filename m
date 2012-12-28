From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 0/3] Make rfc3686 template work with asynchronous
 block ciphers
Date: Sat, 29 Dec 2012 09:42:49 +1100
Message-ID: <20121228224248.GA29448@gondor.apana.org.au>
References: <20121228100448.11073.25546.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sting.hengli.com.au ([178.18.18.71]:52725 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753834Ab2L1WnW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Dec 2012 17:43:22 -0500
Content-Disposition: inline
In-Reply-To: <20121228100448.11073.25546.stgit@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 28, 2012 at 12:04:48PM +0200, Jussi Kivilinna wrote:
> I'm not sure how this patchset should be dealt with (should 1st patch go
> through different tree than 2nd and 3rd?), so therefore it's RFC.
> 
> Second patch makes rfc3686 template work with asynchronous block ciphers and
> third patch changes aesni-intel to use this template. First patch fixed problem
> in xfrm_algo found with help of 2nd and 3rd patches and without 1st patch
> 2nd patch breaks aes-ctr with IPSEC.

I think the easiest way is to have these patches go through Dave's
tree.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
