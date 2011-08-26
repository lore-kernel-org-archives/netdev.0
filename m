From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netpoll: fix incorrect access to skb data in
 __netpoll_rx
Date: Fri, 26 Aug 2011 12:50:28 -0400 (EDT)
Message-ID: <20110826.125028.2169093589404100341.davem@davemloft.net>
References: <1314375975.2563.8.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58597 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754154Ab1HZQuc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2011 12:50:32 -0400
In-Reply-To: <1314375975.2563.8.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 26 Aug 2011 18:26:15 +0200

> __netpoll_rx() doesnt properly handle skbs with small header
> 
> pskb_may_pull() or pskb_trim_rcsum() can change skb->data, we must
> reload it.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
