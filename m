From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
	dev_deactivate() race
Date: Thu, 11 Sep 2008 21:00:35 +1000
Message-ID: <20080911110035.GA22065@gondor.apana.org.au>
References: <20080821.005250.117238212.davem@davemloft.net> <20080911.033956.233317469.davem@davemloft.net> <20080911104531.GA21913@gondor.apana.org.au> <20080911.034955.111797743.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33485 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752196AbYIKLAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 07:00:49 -0400
Content-Disposition: inline
In-Reply-To: <20080911.034955.111797743.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 11, 2008 at 03:49:55AM -0700, David Miller wrote:
> 
> Well some kind of check has to be there.
> 
> I _did_ remove it during my initial implementation, and that
> turned into a reported performance regression.

I see.  How about looking at the queue that the head-of-qdisc
packet maps to? That should be fairly cheap to compute.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
