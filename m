From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/4] virtio_net: return NETDEV_TX_BUSY instead of
	queueing an extra skb.
Date: Tue, 23 Jun 2009 10:54:59 +0800
Message-ID: <20090623025459.GA5991@gondor.apana.org.au>
References: <200905292346.04815.rusty@rustcorp.com.au> <200906181647.51045.rusty@rustcorp.com.au> <20090618073422.GA4087@gondor.apana.org.au> <200906191307.20360.rusty@rustcorp.com.au> <20090619043613.GA15163@gondor.apana.org.au> <OF1B3705AA.30E31D1D-ON652575DD.001F2CCD-652575DD.001FAE94@in.ibm.com> <20090622073417.GA21698@gondor.apana.org.au> <20090622182529.GA4990@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58285 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751576AbZFWCzG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 22:55:06 -0400
Content-Disposition: inline
In-Reply-To: <20090622182529.GA4990@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 22, 2009 at 11:25:29AM -0700, Matt Carlson wrote:
>
> As was said elsewhere, from the driver writer's perspective every packet
> that has already been submitted (queued) to the hardware cannot be
> preempted.  Slightly extending that logic doesn't seem like that much of
> a problem, especially if it saves the troublesome requeuing logic higher up.

I think this is pretty much the same as returning TX_BUSY :)

Do you have access to one of these buggy cards? Can you run some
tests to see what the difference between TSO and GSO is on them?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
