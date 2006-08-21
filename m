From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [0/7] [CRYPTO]: Add hash type and hmac template
Date: Tue, 22 Aug 2006 00:24:07 +1000
Message-ID: <20060821142407.GA26988@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-crypto-owner@vger.kernel.org>
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
Content-Disposition: inline
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:

Dave, these patches are for cryptodev-2.6.

This series of patches adds the new hash crypto type.  It completely
replaces the existing digest type from the user's side.  For now the
digest algorithm interface will remain and coexist with the new hash
algorithm interface.

The main reasons for the new type are:

1) Be able to return errors from init/update/final/digest.
2) Take a descriptor argument in init/update/final/digest.
3) Use SG on algorithm side for update/digest.
4) Compatibility on the algorithm side.

The first three are needed for async crypto.

For now only the HMAC users have been converted over to the new hash
interface.  The rest will follow next.  I do not currently plan to
convert the algorithms to the new interface because there is little
benefit.  In fact one of the main advantages of the crypto_type setup
is the ability to have multiple algorithm types supported by the same
user interface.

Apart from that this series is a respin of the HMAC patches which I've
posted before.  The only difference is that HMAC is now a hash algorithm
rather than digest.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
