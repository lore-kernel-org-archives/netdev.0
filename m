From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: tcp: add a missing tcp_v6_restore_cb()
Date: Mon, 06 Feb 2017 10:53:22 -0500 (EST)
Message-ID: <20170206.105322.954692203927224.davem@davemloft.net>
References: <1486355002.7793.39.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dvyukov@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41274 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754126AbdBFPxY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 10:53:24 -0500
In-Reply-To: <1486355002.7793.39.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 05 Feb 2017 20:23:22 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Dmitry reported use-after-free in ip6_datagram_recv_specific_ctl()
> 
> A similar bug was fixed in commit 8ce48623f0cf ("ipv6: tcp: restore
> IP6CB for pktoptions skbs"), but I missed another spot.
> 
> tcp_v6_syn_recv_sock() can indeed set np->pktoptions from ireq->pktopts
> 
> Fixes: 971f10eca186 ("tcp: better TCP_SKB_CB layout to reduce cache line misses")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>

APplied and queued up for -stable, thanks Eric.
