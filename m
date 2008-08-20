From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Fix qdisc_watchdog() vs. dev_deactivate() race
Date: Wed, 20 Aug 2008 22:16:18 +1000
Message-ID: <20080820121618.GA18652@gondor.apana.org.au>
References: <20080819.040200.155911269.davem@davemloft.net> <20080819164830.GA2533@ami.dom.local> <20080819222329.GA10297@gondor.apana.org.au> <20080820115656.GA7078@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:52129 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753199AbYHTMQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 08:16:28 -0400
Content-Disposition: inline
In-Reply-To: <20080820115656.GA7078@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 20, 2008 at 11:56:56AM +0000, Jarek Poplawski wrote:
> 
> pkt_sched: Fix qdisc_watchdog() vs. dev_deactivate() race
> 
> dev_deactivate() can skip rescheduling of a qdisc by qdisc_watchdog()
> or other timer calling netif_schedule() after dev_queue_deactivate().
> We prevent this checking aliveness before scheduling the timer.
> 
> With feedback from Herbert Xu <herbert@gondor.apana.org.au>
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Looks good to me.

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
