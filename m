From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v2 PATCH 13/13] crypto: algif_aead - Switch to new AEAD
 interface
Date: Mon, 25 May 2015 18:20:21 +0800
Message-ID: <20150525102021.GA30038@gondor.apana.org.au>
References: <20150522082708.GA3507@gondor.apana.org.au>
 <1969904.xZlo35YxmK@tachyon.chronox.de>
 <20150524033420.GC20656@gondor.apana.org.au>
 <3847514.ujeNcPGtgS@tachyon.chronox.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Stephan Mueller <smueller@chronox.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:44934 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752454AbbEYKUc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 06:20:32 -0400
Content-Disposition: inline
In-Reply-To: <3847514.ujeNcPGtgS@tachyon.chronox.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 24, 2015 at 12:52:02PM +0200, Stephan Mueller wrote:
> 
> [   29.653113] BUG: unable to handle kernel NULL pointer dereference at 
> 000000000000000c

Weird.  I tried running your test but it appears to pass.  The only
failures were the nonsense strings and everything else says pased.

It certainly didn't crash for me.

Considering that I just killed cryptoff in my local tree, it is
entirely possible that the patches that you are running are no
longer the same as mine.

So let me merge the cryptoff patches and then I'll repost the
algif_aead patch and ask you to retest.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
