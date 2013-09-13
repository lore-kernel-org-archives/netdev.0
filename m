From: David Miller <davem@davemloft.net>
Subject: Re: bridge: Clamp forward_delay when enabling STP
Date: Thu, 12 Sep 2013 23:32:33 -0400 (EDT)
Message-ID: <20130912.233233.870577692268998436.davem@davemloft.net>
References: <20130912071204.GA16548@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41770 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968Ab3IMDce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 23:32:34 -0400
In-Reply-To: <20130912071204.GA16548@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 12 Sep 2013 17:12:05 +1000

> At some point limits were added to forward_delay.  However, the
> limits are only enforced when STP is enabled.  This created a
> scenario where you could have a value outside the allowed range
> while STP is disabled, which then stuck around even after STP
> is enabled.
> 
> This patch fixes this by clamping the value when we enable STP.
> 
> I had to move the locking around a bit to ensure that there is
> no window where someone could insert a value outside the range
> while we're in the middle of enabling STP.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied and queued up for -stable, thanks Herbert.
