From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mlx4: do not use rwlock in fast path
Date: Tue, 14 Feb 2017 11:28:51 -0500 (EST)
Message-ID: <20170214.112851.873582209944615021.davem@davemloft.net>
References: <1486660204.7793.104.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tariqt@mellanox.com,
        sbohrer@rgmadvisors.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35528 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752271AbdBNQ2x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 11:28:53 -0500
In-Reply-To: <1486660204.7793.104.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 09 Feb 2017 09:10:04 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Using a reader-writer lock in fast path is silly, when we can
> instead use RCU or a seqlock.
> 
> For mlx4 hwstamp clock, a seqlock is the way to go, removing
> two atomic operations and false sharing. 
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Tariq Toukan <tariqt@mellanox.com>

Tariq or someone else at Mellanox please review, this patch has been
rotting for 5 days in patchwork.

Thank you.
