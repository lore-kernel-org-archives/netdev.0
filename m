From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: gso: send_check() & segment() cleanups
Date: Sat, 19 Oct 2013 19:12:34 -0400 (EDT)
Message-ID: <20131019.191234.1720465099173408081.davem@davemloft.net>
References: <1382127207.3284.36.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40411 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103Ab3JSXMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 19:12:35 -0400
In-Reply-To: <1382127207.3284.36.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 18 Oct 2013 13:13:27 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> inet_gso_segment() and inet_gso_send_check() are called by
> skb_mac_gso_segment() under rcu lock, no need to use
> rcu_read_lock() / rcu_read_unlock()
> 
> Avoid calling ip_hdr() twice per function.
> 
> We can use ip_send_check() helper.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
