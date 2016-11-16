From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] net: busy-poll: allow preemption and
 other optimizations
Date: Wed, 16 Nov 2016 13:41:14 -0500 (EST)
Message-ID: <20161116.134114.806108837136085282.davem@davemloft.net>
References: <1479233715-9905-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com, abelay@google.com,
        zach.brown@ni.com, tariqt@mellanox.com, Yuval.Mintz@cavium.com,
        ariel.elior@cavium.com, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46914 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932177AbcKPSlQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 13:41:16 -0500
In-Reply-To: <1479233715-9905-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Tue, 15 Nov 2016 10:15:10 -0800

> It is time to have preemption points in sk_busy_loop() and improve
> its scalability.
> 
> Also napi_complete() and friends can tell drivers when it is safe to
> not re-enable device interrupts, saving some overhead under
> high busy polling.
> 
> mlx4 and bnx2x are changed accordingly, to show how this busy polling
> status can be exploited by drivers.
> 
> Next steps will implement Zach Brown suggestion, where NAPI polling
> would be enabled all the time for some chosen queues.
> This is needed for efficient epoll() support anyway.

Series applied, thanks a lot Eric.
