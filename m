From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: fix refcount leak in fib_check_nh()
Date: Sun, 16 Aug 2015 22:14:53 -0700 (PDT)
Message-ID: <20150816.221453.687679180841395897.davem@davemloft.net>
References: <55CE7776.5000706@cumulusnetworks.com>
	<1439595092.7507.14.camel@edumazet-glaptop2.roam.corp.google.com>
	<1439661247.7258.10.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dsa@cumulusnetworks.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60286 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750759AbbHQFO5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 01:14:57 -0400
In-Reply-To: <1439661247.7258.10.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 15 Aug 2015 10:54:07 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> fib_lookup() forces FIB_LOOKUP_NOREF flag, while fib_table_lookup()
> does not.
> 
> This patch solves the typical message at reboot time or device
> dismantle :
> 
> unregister_netdevice: waiting for eth0 to become free. Usage count = 4
> 
> Fixes: 3bfd847203c6 ("net: Use passed in table for nexthop lookups")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: David Ahern <dsa@cumulusnetworks.com>

Applied, thanks Eric.
