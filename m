From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] macvlan: use the right RCU api
Date: Sat, 30 Mar 2013 17:32:00 -0400 (EDT)
Message-ID: <20130330.173200.1869970263303871433.davem@davemloft.net>
References: <1364674124.5113.132.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40004 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753951Ab3C3VcB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Mar 2013 17:32:01 -0400
In-Reply-To: <1364674124.5113.132.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 30 Mar 2013 13:08:44 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Make sure we use proper API to fetch dev->rx_handler_data,
> instead of ugly casts.
> 
> Rename macvlan_port_get() to macvlan_port_get_rtnl() to document fact
> that we hold RTNL when needed, with lockdep support.
> 
> This removes sparse warnings as well (CONFIG_SPARSE_RCU_POINTER=y)
> 
> CHECK   drivers/net/macvlan.c
> drivers/net/macvlan.c:706:37: warning: cast removes address space of expression
> drivers/net/macvlan.c:775:16: warning: cast removes address space of expression
> drivers/net/macvlan.c:924:16: warning: cast removes address space of expression
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
