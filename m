From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] inetpeer: lower false sharing effect
Date: Wed, 08 Jun 2011 23:31:45 -0700 (PDT)
Message-ID: <20110608.233145.255635792817750847.davem@davemloft.net>
References: <1307600810.3980.85.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andi@firstfloor.org,
	tim.c.chen@linux.intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50944 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752547Ab1FIGbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 02:31:52 -0400
In-Reply-To: <1307600810.3980.85.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 09 Jun 2011 08:26:50 +0200

> Profiles show false sharing in addr_compare() because refcnt/dtime
> changes dirty the first inet_peer cache line, where are lying the keys
> used at lookup time. If many cpus are calling inet_getpeer() and
> inet_putpeer(), or need frag ids, addr_compare() is in 2nd position in
> "perf top".
> 
> Before patch, my udpflood bench (16 threads) on my 2x4x2 machine :
 ..
> After patch, no more addr_compare() in profiles :
 ..
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Andi Kleen <andi@firstfloor.org>
> CC: Tim Chen <tim.c.chen@linux.intel.com>

Applied, thanks!
