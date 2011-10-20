From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] tcp: use TCP_DEFAULT_INIT_RCVWND in
 tcp_fixup_rcvbuf()
Date: Thu, 20 Oct 2011 16:54:08 -0400 (EDT)
Message-ID: <20111020.165408.182924681470815425.davem@davemloft.net>
References: <1319140954.2854.12.camel@edumazet-laptop>
	<20111020.161356.2120784879469409197.davem@davemloft.net>
	<1319143281.2854.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37894 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751012Ab1JTUyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 16:54:13 -0400
In-Reply-To: <1319143281.2854.25.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 20 Oct 2011 22:41:21 +0200

> Since commit 356f039822b (TCP: increase default initial receive
> window.), we allow sender to send 10 (TCP_DEFAULT_INIT_RCVWND) segments.
> 
> Change tcp_fixup_rcvbuf() to reflect this change, even if no real change
> is expected, since sysctl_tcp_rmem[1] = 87380 and this value
> is bigger than tcp_fixup_rcvbuf() computed rcvmem (~23720)
> 
> Note: Since commit 356f039822b limited default window to maximum of
> 10*1460 and 2*MSS, we use same heuristic in this patch.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks a lot Eric.
