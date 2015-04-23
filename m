From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: CCM/GCM implementation defect
Date: Thu, 23 Apr 2015 17:05:45 +0800
Message-ID: <20150423090545.GA20369@gondor.apana.org.au>
References: <20150423032619.GA17648@gondor.apana.org.au>
 <5538B56A.7060707@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Paul Wouters <pwouters@redhat.com>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
To: Horia =?utf-8?Q?Geant=C4=83?= <horia.geanta@freescale.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5538B56A.7060707@freescale.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 23, 2015 at 12:03:38PM +0300, Horia Geant=C4=83 wrote:
> This applies also to GMAC (rfc4543), right?

No RFC4543 appears to be correctly implemented.

> Does this mean that even the test vectors (crypto/testmgr.h) are brok=
en?

Indeed.  The test vectors appear to be generated either through
our implementation or by one that is identical to us.

Cheers,
--=20
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
