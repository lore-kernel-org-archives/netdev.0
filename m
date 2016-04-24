From: David Miller <davem@davemloft.net>
Subject: net merged into net-next
Date: Sat, 23 Apr 2016 20:12:30 -0400 (EDT)
Message-ID: <20160423.201230.364025148300253838.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45941 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751706AbcDXAMg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Apr 2016 20:12:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Eric, please double check my merge work for net/ipv4/udp.c

In net we fixed a soreuseport bug that added a hlist_nulls_add_tail_rcu()
call to net/ipv4/udp.c

And in net-next you converted UDP sockets away from nulls lists.

Therefore I had to add a hlist_add_tail_rcu() implementation to
linux/rculist.h and use it in net/ipv4/udp.c

Please make sure this is fine and will work safely.

Thanks!
