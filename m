From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bridge: fix br_multicast_query_expired() bug
Date: Sat, 30 May 2015 23:33:12 -0700 (PDT)
Message-ID: <20150530.233312.180465980506007204.davem@davemloft.net>
References: <1432813374.16878.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linus.luessing@web.de, sesse@samfundet.no,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39179 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754884AbbEaGdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 May 2015 02:33:13 -0400
In-Reply-To: <1432813374.16878.5.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 28 May 2015 04:42:54 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> br_multicast_query_expired() querier argument is a pointer to
> a struct bridge_mcast_querier :
> 
> struct bridge_mcast_querier {
>         struct br_ip addr;
>         struct net_bridge_port __rcu    *port;
> };
> 
> Intent of the code was to clear port field, not the pointer to querier.
> 
> Fixes: 2cd4143192e8 ("bridge: memorize and export selected IGMP/MLD querier port")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
