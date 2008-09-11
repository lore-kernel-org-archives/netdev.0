From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
	dev_deactivate() race
Date: Thu, 11 Sep 2008 21:45:02 +1000
Message-ID: <20080911114502.GA22698@gondor.apana.org.au>
References: <20080911104531.GA21913@gondor.apana.org.au> <20080911.034955.111797743.davem@davemloft.net> <20080911110035.GA22065@gondor.apana.org.au> <20080911.044255.245121628.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44866 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751850AbYIKLpI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 07:45:08 -0400
Content-Disposition: inline
In-Reply-To: <20080911.044255.245121628.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 11, 2008 at 04:42:55AM -0700, David Miller wrote:
>
> This gets us back to the whole qdisc->ops->peek() discussion :)

That just proves it's a good idea :)

> And we don't have the qdisc lock here, taking it is undesirable,
> and if we do take it we have to transfer that lock down into
> __qdisc_run() which means adjusting all the other __qdisc_run()
> callers.

Last I checked qdisc_run did run under the root lock...

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
