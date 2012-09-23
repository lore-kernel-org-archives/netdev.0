From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] tcp: use order-3 pages in tcp_sendmsg()
Date: Sun, 23 Sep 2012 12:16:01 -0400 (EDT)
Message-ID: <20120923.121601.2244503178301624422.davem@davemloft.net>
References: <1348242511.2669.635.camel@edumazet-glaptop>
	<20120921.122705.1344923255084267186.davem@davemloft.net>
	<alpine.LNX.2.01.1209231446170.9625@nerf07.vanv.qr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, rick.jones2@hp.com,
	subramanian.vijay@gmail.com, netdev@vger.kernel.org
To: jengelh@inai.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41250 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754080Ab2IWQQC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Sep 2012 12:16:02 -0400
In-Reply-To: <alpine.LNX.2.01.1209231446170.9625@nerf07.vanv.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@inai.de>
Date: Sun, 23 Sep 2012 14:47:28 +0200 (CEST)

> On Friday 2012-09-21 18:27, David Miller wrote:
> 
>>From: Eric Dumazet <eric.dumazet@gmail.com>
>>Date: Fri, 21 Sep 2012 17:48:31 +0200
>>
>>> There is probably a reason why lo default MTU is 16436 ?
>>
>>That's what fit into L1 caches back in 1999
> 
> Would it make sense to automatically set lo's MTU on device
> registration to the actual size of the L1 that the $running system
> has?

I think a fixed value of 64K would be a easiest, because another issue
is that back in 1999 we didn't have GRO/GSO/etc.
