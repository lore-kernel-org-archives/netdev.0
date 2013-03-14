From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix skb_availroom()
Date: Thu, 14 Mar 2013 11:51:27 -0400 (EDT)
Message-ID: <20130314.115127.1235077957822193794.davem@davemloft.net>
References: <1363275632.29475.32.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, quiche@chromium.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34978 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933961Ab3CNPvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 11:51:13 -0400
In-Reply-To: <1363275632.29475.32.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 14 Mar 2013 16:40:32 +0100

> From: Eric Dumazet <edumazet@google.com>
> 
> Chrome OS team reported a crash on a Pixel ChromeBook in TCP stack :
> 
> https://code.google.com/p/chromium/issues/detail?id=182056
> 
> commit a21d45726acac (tcp: avoid order-1 allocations on wifi and tx
> path) did a poor choice adding an 'avail_size' field to skb, while
> what we really needed was a 'reserved_tailroom' one.
> 
> It would have avoided commit 22b4a4f22da (tcp: fix retransmit of
> partially acked frames) and this commit.
> 
> Crash occurs because skb_split() is not aware of the 'avail_size'
> management (and should not be aware)
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Mukesh Agrawal <quiche@chromium.org>

Applied and queued up for -stable, thanks Eric.
