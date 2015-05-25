From: Stephan Mueller <smueller@chronox.de>
Subject: Re: [v2 PATCH 13/13] crypto: algif_aead - Switch to new AEAD interface
Date: Mon, 25 May 2015 13:50:55 +0200
Message-ID: <3817112.GjAvZ3MSSX@tachyon.chronox.de>
References: <20150522082708.GA3507@gondor.apana.org.au> <3847514.ujeNcPGtgS@tachyon.chronox.de> <20150525102021.GA30038@gondor.apana.org.au>
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
In-Reply-To: <20150525102021.GA30038@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Montag, 25. Mai 2015, 18:20:21 schrieb Herbert Xu:

Hi Herbert,

> On Sun, May 24, 2015 at 12:52:02PM +0200, Stephan Mueller wrote:
> > [   29.653113] BUG: unable to handle kernel NULL pointer dereference at
> > 000000000000000c
> 
> Weird.  I tried running your test but it appears to pass.  The only
> failures were the nonsense strings and everything else says pased.

To simply verify that all passes is to check for the return code: the return 
code tells you the number of failures --- the value of 0 indicates that all 
pass.

And I see a simple test problem: I added a debug "return" that I forgot to 
remove in the test.sh. Thus, the large test is not executed with test.sh.

When you have my code local, simply execute libkcapi/test/kcapi -y twice or 
three times. That triggered the crash.
> 
> It certainly didn't crash for me.
> 
> Considering that I just killed cryptoff in my local tree, it is
> entirely possible that the patches that you are running are no
> longer the same as mine.
> 
> So let me merge the cryptoff patches and then I'll repost the
> algif_aead patch and ask you to retest.
> 
> Thanks,


-- 
Ciao
Stephan
