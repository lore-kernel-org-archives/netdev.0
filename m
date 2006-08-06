From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Sun, 06 Aug 2006 18:27:35 +1000
Message-ID: <E1G9dyx-0007Yv-00@gondolin.me.apana.org.au>
References: <20060806080659.GA22168@edgar.underground.se.axis.com>
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
	edgar.iglesias@axis.com, hadi@cyberus.ca, shemminger@osdl.org,
	mchan@broadcom.com, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:9235 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932591AbWHFI2I
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Aug 2006 04:28:08 -0400
To: edgar.iglesias@axis.com (Edgar E. Iglesias)
In-Reply-To: <20060806080659.GA22168@edgar.underground.se.axis.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Edgar E. Iglesias <edgar.iglesias@axis.com> wrote:
> 
> It makes sense, but I see a problem with this. It will remove some of the
> control applications have on how much of their data gets queued on local
> queues. Small SNDBUF's are sometimes used to somewhat avoid/control latency.

For UDP yes but does this really make sense for TCP?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
