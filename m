From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Oops in tun: bisected to  Limit amount of queued packets per
	device
Date: Thu, 23 Apr 2009 08:17:56 +0800
Message-ID: <20090423001756.GA8556@gondor.apana.org.au>
References: <200904090952.01175.borntraeger@de.ibm.com> <20090409093817.GA5760@gondor.apana.org.au> <m2ws9c2zs7.fsf@igel.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christian Borntraeger <borntraeger@de.ibm.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Andreas Schwab <schwab@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:54210 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751075AbZDWASS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 20:18:18 -0400
Content-Disposition: inline
In-Reply-To: <m2ws9c2zs7.fsf@igel.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 22, 2009 at 10:34:32PM +0200, Andreas Schwab wrote:
>
> > This is weird.  It looks like it's dying on the wake_up_interruptible_sync
> > in tun_sock_write_space.  However, I can't see how that can cause this.
> 
> Any news on this?  It is still badly broken in 2.6.30-rc3.

I think the fixes are in Dave's tree, waiting to be pushed.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
