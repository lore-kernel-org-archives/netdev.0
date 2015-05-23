From: Stephan Mueller <smueller@chronox.de>
Subject: Re: [v2 PATCH 13/13] crypto: algif_aead - Switch to new AEAD interface
Date: Sat, 23 May 2015 20:04:50 +0200
Message-ID: <43408506.iDYSmTTTDp@tachyon.chronox.de>
References: <20150522082708.GA3507@gondor.apana.org.au> <13023896.hEcYqcIc2j@myon.chronox.de> <20150522215818.GB11512@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20150522215818.GB11512@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Samstag, 23. Mai 2015, 05:58:18 schrieb Herbert Xu:

Hi Herbert,

> On Fri, May 22, 2015 at 11:04:39PM +0200, Stephan Mueller wrote:
> > Note, gcm(aes) looks good. Only rfc4106(gcm(aes)) causes the crash.
> 
> Actually it looks like the culprit hasn't been merged yet so I'll
> just respin the series.
> 
> Anyway, this patch should fix your crash:

That fixes the rfc4106(gcm(aes)) issue. Thanks.

-- 
Ciao
Stephan
