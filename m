From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4/ipmr and ipv6/ip6mr: Convert int mroute_do_<foo>
 to bool
Date: Sun, 25 Nov 2012 16:40:36 -0500 (EST)
Message-ID: <20121125.164036.1283541826012498001.davem@davemloft.net>
References: <1353868023.6558.10.camel@joe-AO722>
	<1353870787.30446.831.camel@edumazet-glaptop>
	<1353872130.6558.17.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40902 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753455Ab2KYVkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Nov 2012 16:40:42 -0500
In-Reply-To: <1353872130.6558.17.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Sun, 25 Nov 2012 11:35:30 -0800

> Save a few bytes per table by convert mroute_do_assert and
> mroute_do_pim from int to bool.
> 
> Remove !! as the compiler does that when assigning int to bool.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
