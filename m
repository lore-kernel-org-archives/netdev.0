From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv6: don't count addrconf generated routes against
 gc limit
Date: Mon, 09 Dec 2013 21:01:17 -0500 (EST)
Message-ID: <20131209.210117.1956125698162907886.davem@davemloft.net>
References: <20131206172556.GF26746@order.stressinduktion.org>
	<20131206.162124.1642753475890720004.davem@davemloft.net>
	<20131207023345.GA16799@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brett.ciphery@windriver.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45051 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740Ab3LJCBS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 21:01:18 -0500
In-Reply-To: <20131207023345.GA16799@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sat, 7 Dec 2013 03:33:45 +0100

> Brett Ciphery reported that new ipv6 addresses failed to get installed
> because the addrconf generated dsts where counted against the dst gc
> limit. We don't need to count those routes like we currently don't count
> administratively added routes.
> 
> Because the max_addresses check enforces a limit on unbounded address
> generation first in case someone plays with router advertisments, we
> are still safe here.
> 
> Reported-by: Brett Ciphery <brett.ciphery@windriver.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable, thanks!
