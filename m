From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH resend] Fix a lock problem in generic phy code
Date: Mon, 10 Sep 2007 16:58:59 +0800
Message-ID: <E1IUf6h-0006qu-00@gondolin.me.apana.org.au>
References: <200709092336.25634.hjk@linutronix.de>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jeff@garzik.org, afleming@freescale.com
To: hjk@linutronix.de (Hans-J??rgen Koch)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4123 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751130AbXIJI7d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2007 04:59:33 -0400
In-Reply-To: <200709092336.25634.hjk@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hans-J??rgen Koch <hjk@linutronix.de> wrote:
>
> The following patch fixes it. Tested on an AT91SAM9263-EK board, kernel 2.6.23-rc4 and -rc3-mm1.

Could you please audit all instances of physdev->lock and add
_bh where necessary?  I can see that at least phys_stop also
needs the _bh.

We should also consider whether it makes sense to move the
timer into a work queue.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
