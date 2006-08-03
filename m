From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH -rt DO NOT APPLY] Fix for tg3 networking lockup
Date: Fri, 4 Aug 2006 09:59:27 +1000
Message-ID: <20060803235927.GB10932@gondor.apana.org.au>
References: <20060803201741.GA7894@thunk.org> <20060803.144845.66061203.davem@davemloft.net> <20060803235326.GC7894@thunk.org> <20060803.165654.45876296.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tytso@mit.edu, mchan@broadcom.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:12296 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1030233AbWHCX7j
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 19:59:39 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060803.165654.45876296.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 03, 2006 at 04:56:54PM -0700, David Miller wrote:
> 
> As Michael explained, it's the ASF heartbeat sent by tg3_timer() that
> must be delivered to the chip within certain timing constraints.
> 
> If you had any watchdog devices on this machine, they would likely
> trigger too and reset your machine :)

Watchdogs usually require one heartbeat every 30 seconds or so.  Does
the ASF heartbeat need to be that frequent?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
