From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: refresh skb timestamp at retransmit time
Date: Tue, 10 May 2016 15:59:18 -0400 (EDT)
Message-ID: <20160510.155918.891099747396899352.davem@davemloft.net>
References: <1462852516.23934.46.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43019 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751410AbcEJT7U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 15:59:20 -0400
In-Reply-To: <1462852516.23934.46.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 09 May 2016 20:55:16 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> In the very unlikely case __tcp_retransmit_skb() can not use the cloning
> done in tcp_transmit_skb(), we need to refresh skb_mstamp before doing
> the copy and transmit, otherwise TCP TS val will be an exact copy of
> original transmit.
> 
> Fixes: 7faee5c0d514 ("tcp: remove TCP_SKB_CB(skb)->when")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>

Applied and queued up for -stable, thanks.
