From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] sched: Optimize return value of qdisc_restart
Date: Thu, 10 May 2007 23:52:20 +1000
Message-ID: <20070510135220.GA26655@gondor.apana.org.au>
References: <E1Hm8Ey-0006oe-00@gondolin.me.apana.org.au> <1178803084.4074.48.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, krkumar2@in.ibm.com, netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3602 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754453AbXEJNxH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 09:53:07 -0400
Content-Disposition: inline
In-Reply-To: <1178803084.4074.48.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 10, 2007 at 09:18:04AM -0400, jamal wrote:
> 
> I wonder how much performance improvement this give now that the extra
> incursion into qdisc_restart is avoided.

Probably very little since the only way it can make a difference is if
there is lots of contention.  But if there is lots of contention we
should stay in the function anyway.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
