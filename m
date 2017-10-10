From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: use rcu_dereference_bh() in
 ipv6_route_seq_next()
Date: Mon, 09 Oct 2017 20:00:18 -0700 (PDT)
Message-ID: <20171009.200018.1469919737024387506.davem@davemloft.net>
References: <20171010001726.77046-1-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, kafai@fb.com
To: weiwan@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33864 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755596AbdJJDAV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 23:00:21 -0400
In-Reply-To: <20171010001726.77046-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>
Date: Mon,  9 Oct 2017 17:17:26 -0700

> From: Wei Wang <weiwan@google.com>
> 
> This patch replaces rcu_deference() with rcu_dereference_bh() in
> ipv6_route_seq_next() to avoid the following warning:
 ...
> Fixes: 66f5d6ce53e6 ("ipv6: replace rwlock with rcu and spinlock in fib6_table")
> Reported-by: Xiaolong Ye <xiaolong.ye@intel.com>
> Signed-off-by: Wei Wang <weiwan@google.com>
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
