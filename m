From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] udp: ipv4: do not use sk_dst_lock from softirq context
Date: Tue, 17 Dec 2013 14:51:16 -0500 (EST)
Message-ID: <20131217.145116.186884795918524348.davem@davemloft.net>
References: <1387133626.19078.216.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48486 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752411Ab3LQTvR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 14:51:17 -0500
In-Reply-To: <1387133626.19078.216.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 15 Dec 2013 10:53:46 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Using sk_dst_lock from softirq context is not supported right now.
> 
> Instead of adding BH protection everywhere,
> udp_sk_rx_dst_set() can instead use xchg(), as suggested
> by David.
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Fixes: 975022310233 ("udp: ipv4: must add synchronization in udp_sk_rx_dst_set()")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
