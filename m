From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: using software TSO on non-TSO capable netdevices
Date: Sun, 3 Aug 2008 16:55:53 +0800
Message-ID: <20080803085553.GA1512@gondor.apana.org.au>
References: <20080731.053516.185810642.davem@davemloft.net> <20080731131929.GO10471@solarflare.com> <20080731132735.GA9085@gondor.apana.org.au> <20080803.011945.249059359.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhutchings@solarflare.com, buytenh@wantstofly.org,
	netdev@vger.kernel.org, akarkare@marvell.com, nico@cam.org,
	dale@farnsworth.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:55678 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751196AbYHCI4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Aug 2008 04:56:05 -0400
Content-Disposition: inline
In-Reply-To: <20080803.011945.249059359.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 03, 2008 at 01:19:45AM -0700, David Miller wrote:
>
> I would start hacking on this beast but I haven't yet come up with
> a clean way to share a lot of code with the existing sw GSO engine.
> That's the key to implementing this properly.

I think it's doable.  We could refactor the software GSO so that
it spits out one fragment at a time and the output could either
be written to some memory provided by the caller or fed through
a callback.

BTW, loner term we should start thinking about breaking the 64K
barrier.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
