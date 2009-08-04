From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netpoll + xmit_lock == deadlock
Date: Tue, 4 Aug 2009 08:15:54 +0800
Message-ID: <20090804001554.GA26942@gondor.apana.org.au>
References: <20090729073523.GA4515@gondor.apana.org.au> <20090802.130704.133993421.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mpm@selenic.com, netdev@vger.kernel.org, mcarlson@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42757 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753879AbZHDAQB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2009 20:16:01 -0400
Content-Disposition: inline
In-Reply-To: <20090802.130704.133993421.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 02, 2009 at 01:07:04PM -0700, David Miller wrote:
>
> My position has always been that such printk's are simply
> not allowed.  (check archives if you don't believe me :-)

Well that means we'd also have to ban printks from all IRQ handlers
etc.

Not that I dislike your way since it would makes things so much
simpler :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
