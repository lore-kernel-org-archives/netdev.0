From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 5/7] esp6: Switch to new AEAD interface
Date: Fri, 22 May 2015 14:45:54 +0800
Message-ID: <20150522064554.GA2522@gondor.apana.org.au>
References: <20150521103938.GA23035@gondor.apana.org.au>
 <E1YvNxL-00063M-DH@gondolin.me.apana.org.au>
 <2287044.Rx7bts6Hbt@tauon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Stephan Mueller <smueller@chronox.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:57015 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918AbbEVGqA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 02:46:00 -0400
Content-Disposition: inline
In-Reply-To: <2287044.Rx7bts6Hbt@tauon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 22, 2015 at 08:40:25AM +0200, Stephan Mueller wrote:
>
> If I may ask, where in your initial patch set is now decided that the IV 
> generator is used (i.e. so that the givcrypt API is not needed any more)?

Please see

https://www.mail-archive.com/linux-crypto@vger.kernel.org/msg14270.html

> Do I understand it correctly that you want to retire the givcrypt API 
> entirely?

Correct.  IV generation will be carried as normal AEAD algorithms.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
