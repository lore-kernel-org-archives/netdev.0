From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 5/7] esp6: Switch to new AEAD interface
Date: Tue, 26 May 2015 16:18:01 +0800
Message-ID: <20150526081801.GA7067@gondor.apana.org.au>
References: <20150521103938.GA23035@gondor.apana.org.au>
 <2094137.hWyJz1gPAp@tauon>
 <20150526075759.GA6849@gondor.apana.org.au>
 <2896909.aPhD1VIluo@tauon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Stephan Mueller <smueller@chronox.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:60394 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751494AbbEZISG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 04:18:06 -0400
Content-Disposition: inline
In-Reply-To: <2896909.aPhD1VIluo@tauon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 26, 2015 at 10:15:37AM +0200, Stephan Mueller wrote:
>
> I fully understand that. But the current patch set that we discuss modifies 
> the IPSEC implementation of esp_ouput to use the new interface. Therefore, to 
> use rfc4106(gcm(aes)) *with* the IV generator (i.e. to get the old removed 
> givcrypt logic), the AEAD cipher handle must be allocated with 
> seqniv(rfc4106(gcm(aes))), would it not?
> 
> Therfore, I would assume that user space has to use the new cipher name when 
> setting up IPSEC that uses the new interface.

No I have not exposed IV generation to user-space.  If and when we
do that we can easily set a default IV generator.

This is all in the patch series that you're responding.  So please
actually read it rather than making assumptions :)

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
