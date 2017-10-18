From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: fix tcp_xmit_retransmit_queue() after
 rbtree introduction
Date: Wed, 18 Oct 2017 14:19:44 +0100 (WEST)
Message-ID: <20171018.141944.210190324694064262.davem@davemloft.net>
References: <1508207915.31614.87.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33118 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752950AbdJRNT4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 09:19:56 -0400
In-Reply-To: <1508207915.31614.87.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 16 Oct 2017 19:38:35 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> I tried to hard avoiding a call to rb_first() (via tcp_rtx_queue_head)
> in tcp_xmit_retransmit_queue(). But this was probably too bold.
> 
> Quoting Yuchung :
> 
> We might miss re-arming the RTO if tp->retransmit_skb_hint is not NULL.
> This can happen when RACK marks the first packet lost again and resets
> tp->retransmit_skb_hint for example (tcp_rack_mark_skb_lost())
> 
> Fixes: 75c119afe14f ("tcp: implement rb-tree based retransmit queue")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Yuchung Cheng <ycheng@google.com>

Applied.
