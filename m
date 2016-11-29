From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4: give precise rx/tx bytes/packets counters
Date: Tue, 29 Nov 2016 13:37:15 -0500 (EST)
Message-ID: <20161129.133715.278556028530429933.davem@davemloft.net>
References: <1480088780.8455.543.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tariqt@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52688 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753243AbcK2ShZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 13:37:25 -0500
In-Reply-To: <1480088780.8455.543.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 25 Nov 2016 07:46:20 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> mlx4 stats are chaotic because a deferred work queue is responsible
> to update them every 250 ms.
> 
> Even sampling stats every one second with "sar -n DEV 1" gives
> variations like the following :
 ...
> This patch allows rx/tx bytes/packets counters being folded at the
> time we need stats.
> 
> We now can fetch stats every 1 ms if we want to check NIC behavior
> on a small time window. It is also easier to detect anomalies.
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Tariq Toukan <tariqt@mellanox.com>

Applied to net-next, thanks Eric.
