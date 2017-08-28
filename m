From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: fix sparse warning on rt6i_node
Date: Mon, 28 Aug 2017 15:35:43 -0700 (PDT)
Message-ID: <20170828.153543.1829810467947750597.davem@davemloft.net>
References: <20170825220310.24863-1-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, kafai@fb.com
To: weiwan@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49964 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751207AbdH1Wfo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 18:35:44 -0400
In-Reply-To: <20170825220310.24863-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>
Date: Fri, 25 Aug 2017 15:03:10 -0700

> From: Wei Wang <weiwan@google.com>
> 
> Commit c5cff8561d2d adds rcu grace period before freeing fib6_node. This
> generates a new sparse warning on rt->rt6i_node related code:
>   net/ipv6/route.c:1394:30: error: incompatible types in comparison
>   expression (different address spaces)
>   ./include/net/ip6_fib.h:187:14: error: incompatible types in comparison
>   expression (different address spaces)
> 
> This commit adds "__rcu" tag for rt6i_node and makes sure corresponding
> rcu API is used for it.
> After this fix, sparse no longer generates the above warning.
> 
> Fixes: c5cff8561d2d ("ipv6: add rcu grace period before freeing fib6_node")
> Signed-off-by: Wei Wang <weiwan@google.com>
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied.
