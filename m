From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] CMAC support for CryptoAPI, fixed patch issues, indent,
 and testmgr build issues
Date: Tue, 29 Jan 2013 10:33:31 +0100
Message-ID: <20130129093331.GA23291@secunet.com>
References: <20130124094337.GJ9147@secunet.com>
 <20130124112410.8535.75598.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-crypto@vger.kernel.org,
	Tom St Denis <tstdenis@elliptictech.com>,
	David Miller <davem@davemloft.net>
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130124112410.8535.75598.stgit@localhost6.localdomain6>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 24, 2013 at 01:25:46PM +0200, Jussi Kivilinna wrote:
> 
> Maybe it would be cleaner to not mess with pfkeyv2.h at all, but instead mark algorithms that do not support pfkey with flag. See patch below.
> 

As nobody seems to have another opinion, we could go either with your
approach, or we can invert the logic and mark all existing algorithms
as pfkey supported. Then we would not need to bother about pfkey again.

I'd be fine with both. Do you want to submit a patch?
