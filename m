From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/2] chacha20poly1305: Skip encryption/decryption for
 0-len
Date: Wed, 9 Dec 2015 20:19:23 +0800
Message-ID: <20151209121923.GD27962@gondor.apana.org.au>
References: <1449366698-2422-1-git-send-email-Jason@zx2c4.com>
 <1449366698-2422-2-git-send-email-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-crypto@vger.kernel.org,
	linux-kernel@vger.kernel.org, Netdev <netdev@vger.kernel.org>,
	martin@strongswan.org, stable@vger.kernel.org
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:49358 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753954AbbLIMTu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 07:19:50 -0500
Content-Disposition: inline
In-Reply-To: <1449366698-2422-2-git-send-email-Jason@zx2c4.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 06, 2015 at 02:51:38AM +0100, Jason A. Donenfeld wrote:
> If the length of the plaintext is zero, there's no need to waste cycles
> on encryption and decryption. Using the chacha20poly1305 construction
> for zero-length plaintexts is a common way of using a shared encryption
> key for AAD authentication.
> 
> Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>

Patch applied.  Thanks.
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
