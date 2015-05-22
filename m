From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/7] crypto: Convert all AEAD users to new interface
Date: Fri, 22 May 2015 08:18:15 +0800
Message-ID: <20150522001813.GA29073@gondor.apana.org.au>
References: <20150521103938.GA23035@gondor.apana.org.au>
 <6790442.0xoTQWpjSd@tauon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Stephan Mueller <smueller@chronox.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:33502 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755225AbbEVASz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 20:18:55 -0400
Content-Disposition: inline
In-Reply-To: <6790442.0xoTQWpjSd@tauon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 21, 2015 at 02:29:10PM +0200, Stephan Mueller wrote:
>
> Wouldn't algif_aead be also a candiate for the transition? The current 
> implementation of aead_recvmsg() splits the one SGL it received from user 
> space into two: one for AD and one for the ciphertext.

Yes of course, that's what inspired this :)

I just want to do the users outside crypto first before the rest.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
