From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: CCM/GCM implementation defect
Date: Thu, 23 Apr 2015 18:01:52 +0800
Message-ID: <20150423100152.GA20693@gondor.apana.org.au>
References: <20150423032619.GA17648@gondor.apana.org.au>
 <5538B56A.7060707@freescale.com>
 <20150423090545.GA20369@gondor.apana.org.au>
 <1429783132.3083.15.camel@martin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Horia =?utf-8?Q?Geant=C4=83?= <horia.geanta@freescale.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Paul Wouters <pwouters@redhat.com>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
To: Martin Willi <martin@strongswan.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1429783132.3083.15.camel@martin>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 23, 2015 at 11:58:52AM +0200, Martin Willi wrote:
>
> I'm not sure about that. RFC4106 refers to [1] for test vectors, which
> is still available at web.archive.org [2].
> 
> When looking for example at Test Case 3, this is the same as in a newer
> revision of the document [3]. That looks exactly the same as
> aes_gcm_enc_tv_template[2] from testmgr.h.

These are GCM test vectors, not RFC4106 test vectors so they are
of no use when you're testing whether the IPsec IV (which is not
the same thing as the GCM IV) is included in the authentication
or not.

AFAIK GCM itself is implemented correctly.  It's only the IPsec
wrapper around it (rfc4106 in particular) that's broken.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
