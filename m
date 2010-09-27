From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: update SOCK_MIN_RCVBUF
Date: Sun, 26 Sep 2010 18:53:20 -0700 (PDT)
Message-ID: <20100926.185320.15237220.davem@davemloft.net>
References: <1285345177.2503.346.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43111
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757758Ab0I0BxA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Sep 2010 21:53:00 -0400
In-Reply-To: <1285345177.2503.346.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 24 Sep 2010 18:19:37 +0200

> SOCK_MIN_RCVBUF current value is 256 bytes
> 
> It doesnt permit to receive the smallest possible frame, considering
> socket sk_rmem_alloc/sk_rcvbuf account skb truesizes. On 64bit arches,
> sizeof(struct sk_buff) is 240 bytes. Add the typical 64 bytes of
> headroom, and we go over the limit.
> 
> With old kernels and 32bit arches, we were under the limit, if netdriver
> was doing copybreak.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Fair enough, applied, thanks Eric.
