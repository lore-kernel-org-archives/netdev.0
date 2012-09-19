From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] tcp: use order-3 pages in tcp_sendmsg()
Date: Wed, 19 Sep 2012 13:56:55 -0400 (EDT)
Message-ID: <20120919.135655.381209248813843140.davem@davemloft.net>
References: <1347901493.26523.151.camel@edumazet-glaptop>
	<20120917.130732.1894375657044880827.davem@davemloft.net>
	<1348067659.26523.949.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55821 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932804Ab2ISR46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 13:56:58 -0400
In-Reply-To: <1348067659.26523.949.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 19 Sep 2012 17:14:19 +0200

> I did some tests and got no problem so far, even using splice() [ this
> one was tricky because it only deals with order-0 pages at this moment ]
> 
> NIC tested : ixgbe, igb, bnx2x, tg3, mellanox mlx4
> 
> On loopback, performance of netperf goes from 31900 Mb/s to 38500 Mb/s,
> thats a 20 % increase.

That's really a lot more than I expected, nice.
