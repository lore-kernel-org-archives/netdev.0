From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ZD1211RW unaligned accesses...
Date: Fri, 30 Nov 2007 20:50:39 +1100
Message-ID: <20071130095039.GA17911@gondor.apana.org.au>
References: <20071120.040546.222294375.davem@davemloft.net> <47442BFC.8090008@hotmail.com> <20071124150216.GA28153@gondor.apana.org.au> <20071129214533.GD32730@tuxdriver.com> <20071129234327.GA23769@gondor.apana.org.au> <474FBD20.10202@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	David Miller <davem@davemloft.net>, dsd@gentoo.org,
	kune@deine-taler.de
To: Shaddy Baddah <shaddy_baddah@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2667 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751414AbXK3Jus (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2007 04:50:48 -0500
Content-Disposition: inline
In-Reply-To: <474FBD20.10202@hotmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 30, 2007 at 06:34:56PM +1100, Shaddy Baddah wrote:
> 
> OK... so I've applied patches left right and centre. As there have been 
> a few, I'll in-line them all at the bottom of this email.
> 
> The result is that there are no more unaligned access messages at all. 

Good stuff! I was sort of worried that you might end up getting unaligned
traps in the IP stack but it's good to see that you didn't.  Of course
it's still something that we need to fix up at some point for other
configurations.

John, you can apply my patch now.

> However, I still can only scan one (occasionally two) AP, using iwlist 
> eth2 scanning command before a bus error. Jean, I missed your emails 
> regarding compiling the wireless-tools, I will try these and see if they 
> help.

That's kind of expected because we haven't completely fixed up the
user-kernel wireless interface for the 32-in-64 case.  But rest assured
we will be working on that.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
