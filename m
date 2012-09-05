From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: qdisc busylock needs lockdep annotations
Date: Wed, 05 Sep 2012 17:51:05 -0400 (EDT)
Message-ID: <20120905.175105.1669145747033650498.davem@davemloft.net>
References: <1346842976.13121.143.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45075 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751811Ab2IEVvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 17:51:06 -0400
In-Reply-To: <1346842976.13121.143.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 05 Sep 2012 13:02:56 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> It seems we need to provide ability for stacked devices
> to use specific lock_class_key for sch->busylock
> 
> We could instead default l2tpeth tx_queue_len to 0 (no qdisc), but
> a user might use a qdisc anyway.
> 
> (So same fixes are probably needed on non LLTX stacked drivers)
> 
> Noticed while stressing L2TPV3 setup :
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
