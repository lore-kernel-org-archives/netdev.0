From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: strengthen fallback fragmentation id
 generation
Date: Mon, 31 Mar 2014 16:33:55 -0400 (EDT)
Message-ID: <20140331.163355.390252980549735250.davem@davemloft.net>
References: <20140330162803.GG11063@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42970 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751206AbaCaUd4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 16:33:56 -0400
In-Reply-To: <20140330162803.GG11063@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sun, 30 Mar 2014 18:28:03 +0200

> First off, we don't need to check for non-NULL rt any more, as we are
> guaranteed to always get a valid rt6_info. Drop the check.
> 
> In case we couldn't allocate an inet_peer for fragmentation information
> we currently generate strictly incrementing fragmentation ids for all
> destination. This is done to maximize the cycle and avoid collisions.
> 
> Those fragmentation ids are very predictable. At least we should try to
> mix in the destination address.
> 
> While it should make no difference to simply use a PRNG at this point,
> secure_ipv6_id ensures that we don't leak information from prandom,
> so its internal state could be recoverable.
> 
> This fallback function should normally not get used thus this should
> not affect performance at all. It is just meant as a safety net.
> 
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Looks good, thanks Hannes.
