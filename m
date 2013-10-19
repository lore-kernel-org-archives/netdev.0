From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: gso: remove redundant locking
Date: Sat, 19 Oct 2013 19:14:27 -0400 (EDT)
Message-ID: <20131019.191427.1916999419022666981.davem@davemloft.net>
References: <1382132635.3284.45.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40452 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750950Ab3JSXO3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 19:14:29 -0400
In-Reply-To: <1382132635.3284.45.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 18 Oct 2013 14:43:55 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> ipv6_gso_send_check() and ipv6_gso_segment() are called by
> skb_mac_gso_segment() under rcu lock, no need to use
> rcu_read_lock() / rcu_read_unlock()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
