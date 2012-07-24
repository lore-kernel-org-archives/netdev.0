From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] tcp: early_demux fixes
Date: Tue, 24 Jul 2012 13:56:46 -0700 (PDT)
Message-ID: <20120724.135646.458225356444764082.davem@davemloft.net>
References: <1343128771.2626.11059.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33662 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755800Ab2GXU4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 16:56:46 -0400
In-Reply-To: <1343128771.2626.11059.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 24 Jul 2012 13:19:31 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> 1) Remove a non needed pskb_may_pull() in tcp_v4_early_demux()
>    and fix a potential bug if skb->head was reallocated
>    (iph & th pointers were not reloaded)
> 
> TCP stack will pull/check headers anyway.
> 
> 2) must reload iph in ip_rcv_finish() after early_demux()
>  call since skb->head might have changed.
> 
> 3) skb->dev->ifindex can be now replaced by skb->skb_iif
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
