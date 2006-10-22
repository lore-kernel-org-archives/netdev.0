From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4][CRYPTO][IPsec] pass the flags to the internal tfm allocation
Date: Sun, 22 Oct 2006 14:53:57 +1000
Message-ID: <20061022045356.GA12203@gondor.apana.org.au>
References: <20061018112606.b4f40c18.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57865 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1422971AbWJVEzF
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Oct 2006 00:55:05 -0400
To: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Content-Disposition: inline
In-Reply-To: <20061018112606.b4f40c18.kazunori@miyazawa.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 18, 2006 at 11:26:06AM +0900, Kazunori MIYAZAWA wrote:
> XCBC needs to allocate the tfm as CBC mode to use
> "xor" function in the tfm.

I'm sorry but this isn't going to fly.  The mode argument is obsolete
and incompatible with the new bit-field flags setup.  So I'm not going
to add any new code that uses it.

In the medium term this code should be converted to use the block-cipher
interface.  For now, please either make a local copy of the xor function
or just export the one from crypto/cbc.c.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
