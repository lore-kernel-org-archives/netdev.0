From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 v2] net: build_ehash_secret() and
 rt_bind_peer() cleanups
Date: Fri, 20 Aug 2010 00:51:15 -0700 (PDT)
Message-ID: <20100820.005115.91322239.davem@davemloft.net>
References: <1282232815.2549.61.camel@edumazet-laptop>
	<AANLkTinpqNa3cgEb=86H0sYXdLmo-RP1G2icJgWpfyN1@mail.gmail.com>
	<1282234245.25476.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, netdev@vger.kernel.org,
	mathieu.desnoyers@polymtl.ca
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49290
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751028Ab0HTHu6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Aug 2010 03:50:58 -0400
In-Reply-To: <1282234245.25476.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 19 Aug 2010 18:10:45 +0200

> [PATCH net-next-2.6] net: build_ehash_secret() and rt_bind_peer() cleanups
> 
> Now cmpxchg() is available on all arches, we can use it in
> build_ehash_secret() and rt_bind_peer() instead of using spinlocks.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
