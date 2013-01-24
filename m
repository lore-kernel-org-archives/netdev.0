From: Tom St Denis <tstdenis@elliptictech.com>
Subject: Re: [PATCH] CMAC support for CryptoAPI, fixed patch issues, indent,
 and testmgr build issues
Date: Thu, 24 Jan 2013 07:37:50 -0500 (EST)
Message-ID: <909599053.113808.1359031070783.JavaMail.root@elliptictech.com>
References: <20130124123210.GK9147@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-crypto@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20130124123210.GK9147@secunet.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



----- Original Message -----
> From: "Steffen Klassert" <steffen.klassert@secunet.com>
> To: "Jussi Kivilinna" <jussi.kivilinna@mbnet.fi>
> Cc: "Herbert Xu" <herbert@gondor.apana.org.au>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
> linux-crypto@vger.kernel.org, "Tom St Denis" <tstdenis@elliptictech.com>, "David Miller" <davem@davemloft.net>
> Sent: Thursday, 24 January, 2013 7:32:10 AM
> Subject: Re: [PATCH] CMAC support for CryptoAPI, fixed patch issues, indent, and testmgr build issues
> 
> On Thu, Jan 24, 2013 at 01:25:46PM +0200, Jussi Kivilinna wrote:
> > 
> > Maybe it would be cleaner to not mess with pfkeyv2.h at all, but
> > instead mark algorithms that do not support pfkey with flag. See
> > patch below.
> > 
> 
> Yes, would be an option too. I would be fine with that,
> but let's here if someone else has an opinion on this.
> Anyway, we need a solution to integrate Tom's patch soon.

Has anyone addressed the testmgr issues too?  I wasn't able to run the self-tests so I don't even know if the vectors were copied correctly.

Also a question for the netdev folk, in order to be timely would it be acceptable to patch ah4 and then ah6 with the AEAD changes?  Or would the team require both to be patched simultaneously?
 
Tom
