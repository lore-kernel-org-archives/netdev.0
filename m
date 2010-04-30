From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: speedup sock_recv_ts_and_drops()
Date: Fri, 30 Apr 2010 16:30:29 -0700 (PDT)
Message-ID: <20100430.163029.223465540.davem@davemloft.net>
References: <1272518083.2201.119.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36987
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756711Ab0D3XaX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 19:30:23 -0400
In-Reply-To: <1272518083.2201.119.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 29 Apr 2010 07:14:43 +0200

> sock_recv_ts_and_drops() is fat and slow (~ 4% of cpu time on some
> profiles)
> 
> We can test all socket flags at once to make fast path fast again.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Nice, applied, thanks Eric.

I have a sneaking suspicion that there may be a few other places
like this. :-)
