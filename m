From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] inet: move ipv6only in sock_common
Date: Tue, 01 Jul 2014 23:46:36 -0700 (PDT)
Message-ID: <20140701.234636.65063413876214923.davem@davemloft.net>
References: <1403883376.15139.16.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37823 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752366AbaGBGqn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 02:46:43 -0400
In-Reply-To: <1403883376.15139.16.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 27 Jun 2014 08:36:16 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> When an UDP application switches from AF_INET to AF_INET6 sockets, we
> have a small performance degradation for IPv4 communications because of
> extra cache line misses to access ipv6only information.
> 
> This can also be noticed for TCP listeners, as ipv6_only_sock() is also
> used from __inet_lookup_listener()->compute_score()
> 
> This is magnified when SO_REUSEPORT is used.
> 
> Move ipv6only into struct sock_common so that it is available at
> no extra cost in lookups.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
