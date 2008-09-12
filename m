From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm_state locking regression...
Date: Sat, 13 Sep 2008 02:08:25 +1000
Message-ID: <20080912160825.GA5690@gondor.apana.org.au>
References: <20080908.172513.162820960.davem@davemloft.net> <20080909143312.GA29952@gondor.apana.org.au> <20080911212459.GL6693@linux.vnet.ibm.com> <20080911.150006.53056393.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paulmck@linux.vnet.ibm.com, timo.teras@iki.fi,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:32990 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753529AbYILQIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2008 12:08:43 -0400
Content-Disposition: inline
In-Reply-To: <20080911.150006.53056393.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 11, 2008 at 03:00:06PM -0700, David Miller wrote:
>
> > There is only one reader at a time, right?  Otherwise, I don't see how
> > the increments and reads of xfrm_state_walk_completed line up.
> 
> The RTNL semaphore is held across the modifications of the counters.

s/RTNL/xfrm_cfg_mutex/

but otherwise what Dave said :)

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
