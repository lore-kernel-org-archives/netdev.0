From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [QUESTION] multi-core, multi-crypto,  ipsec/udp out of order.
Date: Wed, 4 Jun 2014 08:00:49 +0800
Message-ID: <20140604000049.GA27951@gondor.apana.org.au>
References: <A83C99F8370D4D42BEB2D2B3153A6BBC30807AE1@NASANEXD02C.na.qualcomm.com>
 <20140602124649.GA2503@gondor.apana.org.au>
 <A83C99F8370D4D42BEB2D2B3153A6BBC30808594@NASANEXD02C.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	"Bronstein, Dan" <dbronste@qti.qualcomm.com>
To: "Hsieh, Che-Min" <cheminh@qti.qualcomm.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <A83C99F8370D4D42BEB2D2B3153A6BBC30808594@NASANEXD02C.na.qualcomm.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 03, 2014 at 01:48:56PM +0000, Hsieh, Che-Min wrote:
> Herbert:
> Sorry, what is "in-tree" driver? This is Qcom crypto driver. It is part of android linux 3-10. I think Stanimir Varbanov is working on upstreaming the crypto driver. The driver version he cuts off, does static crypto engine assignment, i.e. crypto HW is assigned to a TFM on  cra_init. That scheme is simple. But, under the same TFM, it does not take advantage of multiple crypto HW working in parallel. Later, we put in dynamic engine assignment per request, as described in the previous mail thread.

An in-tree driver is one that's in the mainline kernel.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
