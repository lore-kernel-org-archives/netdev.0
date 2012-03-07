From: David Miller <davem@davemloft.net>
Subject: Re: 3.3.0-rc6-next20120305 net/ipv4/tcp_ipv4.c:930 suspicious
 rcu_dereference_check() usage!
Date: Wed, 07 Mar 2012 15:16:25 -0500 (EST)
Message-ID: <20120307.151625.829659631072828076.davem@davemloft.net>
References: <30475.1331126726@turing-police.cc.vt.edu>
	<1331131543.2474.72.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Valdis.Kletnieks@vt.edu, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53308 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756772Ab2CGUit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2012 15:38:49 -0500
In-Reply-To: <1331131543.2474.72.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 07 Mar 2012 06:45:43 -0800

> [PATCH net-next] tcp: md5: correct a RCU lockdep splat
> 
> commit a8afca0329 (tcp: md5: protects md5sig_info with RCU) added a
> lockdep splat in tcp_md5_do_lookup() in case a timer fires a tcp
> retransmit.
> 
> At this point, socket lock is owned by the sofirq handler, not the user,
> so we should adjust a bit the lockdep condition, as we dont hold
> rcu_read_lock().
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Reported-by: Valdis Kletnieks <valdis.kletnieks@vt.edu>

Applied, thanks Eric.
