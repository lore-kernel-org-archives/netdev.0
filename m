From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] l2tp: dont play with skb->truesize
Date: Fri, 08 Feb 2013 01:50:46 -0500 (EST)
Message-ID: <20130208.015045.564376676195476016.davem@davemloft.net>
References: <1360281634.28557.71.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com, bircoph@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57596 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753031Ab3BHGut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 01:50:49 -0500
In-Reply-To: <1360281634.28557.71.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 07 Feb 2013 16:00:34 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Andrew Savchenko reported a DNS failure and we diagnosed that
> some UDP sockets were unable to send more packets because their
> sk_wmem_alloc was corrupted after a while (tx_queue column in
> following trace)
 ...
> Playing with skb->truesize is tricky, especially when
> skb is attached to a socket, as we can fool memory charging.
> 
> Just remove this code, its not worth trying to be ultra
> precise in xmit path.
> 
> Reported-by: Andrew Savchenko <bircoph@gmail.com>
> Tested-by: Andrew Savchenko <bircoph@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.
