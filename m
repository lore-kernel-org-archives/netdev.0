From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: get rid of rtable->idev
Date: Thu, 11 Nov 2010 10:41:53 -0800 (PST)
Message-ID: <20101111.104153.115922255.davem@davemloft.net>
References: <1289495647.17691.1536.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	rolandd@cisco.com, sean.hefty@intel.com, hal.rosenstock@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50595
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754737Ab0KKSl3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 13:41:29 -0500
In-Reply-To: <1289495647.17691.1536.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 11 Nov 2010 18:14:07 +0100

> It seems idev field in struct rtable has no special purpose, but adding
> extra atomic ops.
> 
> We hold refcounts on the device itself (using percpu data, so pretty
> cheap in current kernel).
> 
> infiniband case is solved using dst.dev instead of idev->dev
> 
> Removal of this field means routing without route cache is now using
> shared data, percpu data, and only potential contention is a pair of
> atomic ops on struct neighbour per forwarded packet.
> 
> About 5% speedup on routing test.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Roland Dreier <rolandd@cisco.com>
> Cc: Sean Hefty <sean.hefty@intel.com>
> Cc: Hal Rosenstock <hal.rosenstock@gmail.com>

Yes, let's remove as much unused crap as possible :-)

Applied, thanks!
