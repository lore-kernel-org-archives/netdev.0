From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V1] net/ipv4: Use proper RCU APIs for writer-side
 in udp_offload.c
Date: Tue, 04 Feb 2014 20:03:26 -0800 (PST)
Message-ID: <20140204.200326.1370432247105523133.davem@davemloft.net>
References: <1391348530-31643-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shlomop@mellanox.com, edumazet@google.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48756 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899AbaBEED1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Feb 2014 23:03:27 -0500
In-Reply-To: <1391348530-31643-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Sun,  2 Feb 2014 15:42:10 +0200

> From: Shlomo Pongratz <shlomop@mellanox.com>
> 
> RCU writer side should use rcu_dereference_protected() and not
> rcu_dereference(), fix that. This also removes the "suspicious RCU usage"
> warning seen when running with CONFIG_PROVE_RCU.
> 
> Also, don't use rcu_assign_pointer/rcu_dereference for pointers
> which are invisible beyond the udp offload code.
> 
> Fixes: b582ef0 ('net: Add GRO support for UDP encapsulating protocols')
> Reported-by: Eric Dumazet <edumazet@google.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> Signed-off-by: Shlomo Pongratz <shlomop@mellanox.com>

Applied, thank you.
