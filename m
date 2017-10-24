From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: add ip6_null_entry check in rt6_select()
Date: Tue, 24 Oct 2017 18:52:07 +0900 (KST)
Message-ID: <20171024.185207.1157240336408066887.davem@davemloft.net>
References: <20171023215935.52136-1-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, kafai@fb.com
To: weiwan@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58412 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751921AbdJXJwL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 05:52:11 -0400
In-Reply-To: <20171023215935.52136-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>
Date: Mon, 23 Oct 2017 14:59:35 -0700

> From: Wei Wang <weiwan@google.com>
> 
> In rt6_select(), fn->leaf could be pointing to net->ipv6.ip6_null_entry.
> In this case, we should directly return instead of trying to carry on
> with the rest of the process.
> If not, we could crash at:
>   spin_lock_bh(&leaf->rt6i_table->rt6_lock);
> because net->ipv6.ip6_null_entry does not have rt6i_table set.
 ...
> Fixes: 66f5d6ce53e6 ("ipv6: replace rwlock with rcu and spinlock in fib6_table")
> Signed-off-by: Wei Wang <weiwan@google.com>
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
