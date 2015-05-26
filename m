From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 5/7] esp6: Switch to new AEAD interface
Date: Tue, 26 May 2015 15:57:59 +0800
Message-ID: <20150526075759.GA6849@gondor.apana.org.au>
References: <20150521103938.GA23035@gondor.apana.org.au>
 <1712288.Rcrx4S4ED0@tauon>
 <20150526073858.GA6634@gondor.apana.org.au>
 <2094137.hWyJz1gPAp@tauon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Stephan Mueller <smueller@chronox.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:53460 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751548AbbEZH6E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 03:58:04 -0400
Content-Disposition: inline
In-Reply-To: <2094137.hWyJz1gPAp@tauon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 26, 2015 at 09:56:17AM +0200, Stephan Mueller wrote:
>
> Actually, I mean the real in-kernel crypto API: the IKE daemon would set up 
> the SA via XFRM where the rfc4106(gcm(aes)) cipher is set, is it not? So, user 
> space is responsible to set the right IPSEC cipher.
> 
> As that user space cipher name is now changed, user space would need to be 
> aware of that modification, would it not?

No the change was done in a backwards compatible way.  So if you
allocate rfc4106(gcm(aes)) and use the givencrypt interface (not
encrypt) then you still get the old behaviour.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
