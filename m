From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] infiniband: addr: Avoid unnecessary neigh lookup.
Date: Fri, 02 Dec 2011 21:48:54 -0500 (EST)
Message-ID: <20111202.214854.1347753621091554078.davem@davemloft.net>
References: <20111202.145525.1679807360238725746.davem@davemloft.net>
	<CAL1RGDU8=G_TKRirxm6pMni3H3a-FbvDz+pzG_oaZo-LYBQ0bg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roland@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52015 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754087Ab1LCCs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 21:48:58 -0500
In-Reply-To: <CAL1RGDU8=G_TKRirxm6pMni3H3a-FbvDz+pzG_oaZo-LYBQ0bg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <roland@kernel.org>
Date: Fri, 2 Dec 2011 15:18:00 -0800

>> So if it's OK with you I'd like to merge this stuff directly in the
>> net-next tree after getting your ACK on each patch.
> 
> Sure, that's fine, and for this particular patch:
> 
> Acked-by: Roland Dreier <roland@purestorage.com>

Thanks for reviewing Roland.

I reread this code and it turns out that the ipv6 handling does
the same exact thing as what I transformed ipv4 to do, so it's
better to have a helper function and make ipv4 and ipv6 use it.

I've sanitized the neighbour handling in the entire Infiniband
stack tonight, and I'll send that series out for review right now.
It will include an updated version of this patch.
