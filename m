From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix two typos in a comment in xfrm6_init()
Date: Wed, 14 Nov 2012 18:55:28 -0500 (EST)
Message-ID: <20121114.185528.2167305838484743723.davem@davemloft.net>
References: <20121108.145939.2274479010583117059.davem@davemloft.net>
	<20121109075726.GD22290@secunet.com>
	<20121113090006.GI22290@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roy.qing.li@gmail.com, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36972 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755412Ab2KNXza (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 18:55:30 -0500
In-Reply-To: <20121113090006.GI22290@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 13 Nov 2012 10:00:06 +0100

> Subject: [PATCH] xfrm: Fix the gc threshold value for ipv4
> 
> The xfrm gc threshold value depends on ip_rt_max_size. This
> value was set to INT_MAX with the routing cache removal patch,
> so we start doing garbage collecting when we have INT_MAX/2
> IPsec routes cached. Fix this by going back to the static
> threshold of 1024 routes.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

This looks fine to me.
