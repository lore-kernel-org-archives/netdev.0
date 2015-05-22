From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 5/7] esp6: Switch to new AEAD interface
Date: Fri, 22 May 2015 15:19:23 +0800
Message-ID: <20150522071923.GA2777@gondor.apana.org.au>
References: <20150521103938.GA23035@gondor.apana.org.au>
 <2287044.Rx7bts6Hbt@tauon>
 <20150522064554.GA2522@gondor.apana.org.au>
 <2066513.Bca9qAkvxD@tauon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Stephan Mueller <smueller@chronox.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:56770 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752059AbbEVHT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 03:19:29 -0400
Content-Disposition: inline
In-Reply-To: <2066513.Bca9qAkvxD@tauon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 22, 2015 at 09:16:08AM +0200, Stephan Mueller wrote:
>
> Thanks for the pointer, but there I do not really see the functionality I am 
> looking for. I see patch 10/16 which seems to indicate that the geniv logic is 
> now to be invoked as a normal AEAD cipher. I yet fail to see where the 
> distinction is made in the code that an IV is to be generated versus the given 
> IV is to be used.

Only IV generators algorithms will generate IV.  The generated IV
will be placed at the start of cipher text.  See patches 14-16 for
the actual implementation.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
