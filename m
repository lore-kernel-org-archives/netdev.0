From: Stephan Mueller <smueller@chronox.de>
Subject: Re: [v2 PATCH 13/13] crypto: algif_aead - Switch to new AEAD interface
Date: Tue, 26 May 2015 08:44:29 +0200
Message-ID: <1720790.K1nOQU1Nxi@tachyon.chronox.de>
References: <20150522082708.GA3507@gondor.apana.org.au> <20150525115341.GA30627@gondor.apana.org.au> <20150526062433.GA6025@gondor.apana.org.au>
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
In-Reply-To: <20150526062433.GA6025@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Dienstag, 26. Mai 2015, 14:24:33 schrieb Herbert Xu:

Hi Herbert,

> On Mon, May 25, 2015 at 07:53:41PM +0800, Herbert Xu wrote:
> > On Mon, May 25, 2015 at 01:50:55PM +0200, Stephan Mueller wrote:
> > > When you have my code local, simply execute libkcapi/test/kcapi -y twice
> > > or
> > > three times. That triggered the crash.
> > 
> > Aha that's what I was missing.  I'll look into the crash.
> 
> OK I forgot to initialise the SG list.  This patch fixes it for me.

Confirmed. I see no more issues on the AF_ALG side.

-- 
Ciao
Stephan
