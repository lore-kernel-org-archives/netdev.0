From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] ipv6: compare sernum when walking fib for
 /proc/net/ipv6_route as safety net
Date: Fri, 27 Sep 2013 17:33:13 -0400 (EDT)
Message-ID: <20130927.173313.1429984635743435628.davem@davemloft.net>
References: <20130921145610.GA20769@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, greearb@candelatech.com, kaber@trash.net,
	yoshfuji@linux-ipv6.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50858 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754537Ab3I0VdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 17:33:15 -0400
In-Reply-To: <20130921145610.GA20769@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sat, 21 Sep 2013 16:56:10 +0200

> This patch provides an additional safety net against NULL
> pointer dereferences while walking the fib trie for the new
> /proc/net/ipv6_route walkers. I never needed it myself and am unsure
> if it is needed at all, but the same checks where introduced in
> 2bec5a369ee79576a3eea2c23863325089785a2c ("ipv6: fib: fix crash when
> changing large fib while dumping it") to fix NULL pointer bugs.
> 
> This patch is separated from the first patch to make it easier to revert
> if we are sure we can drop this logic.
> 
> Cc: Ben Greear <greearb@candelatech.com>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
