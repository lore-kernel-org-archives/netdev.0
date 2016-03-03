From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: sched: use pfifo_fast for non real queues
Date: Thu, 03 Mar 2016 17:53:40 -0500 (EST)
Message-ID: <20160303.175340.904754717870625377.davem@davemloft.net>
References: <1456935703-27585-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48600 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932234AbcCCWxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 17:53:42 -0500
In-Reply-To: <1456935703-27585-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Wed,  2 Mar 2016 08:21:43 -0800

> Some devices declare a high number of TX queues, then set a much
> lower real_num_tx_queues
> 
> This cause setups using fq_codel, sfq or fq as the default qdisc to consume
> more memory than really needed.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
