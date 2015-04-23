From: =?UTF-8?B?SG9yaWEgR2VhbnTEgw==?= <horia.geanta@freescale.com>
Subject: Re: CCM/GCM implementation defect
Date: Thu, 23 Apr 2015 12:03:38 +0300
Message-ID: <5538B56A.7060707@freescale.com>
References: <20150423032619.GA17648@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Paul Wouters <pwouters@redhat.com>,
	"Linux Crypto Mailing List" <linux-crypto@vger.kernel.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20150423032619.GA17648@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/23/2015 6:26 AM, Herbert Xu wrote:
> Hi:
>
> It looks like our IPsec implementations of CCM and GCM are buggy
This applies also to GMAC (rfc4543), right?

> in that they don't include the IV in the authentication calculation.
>
> This definitely breaks interoperability with anyone who implements
> them correctly.  The fact that there have been no reports on this
> probably means that nobody has run into this in the field yet.
Does this mean that even the test vectors (crypto/testmgr.h) are broken?

Thanks,
Horia
