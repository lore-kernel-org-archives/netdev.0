From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix crashes in do_tcp_sendpages()
Date: Sat, 01 Dec 2012 20:41:15 -0500 (EST)
Message-ID: <20121201.204115.1249972818143982491.davem@davemloft.net>
References: <1354401121.20109.531.camel@edumazet-glaptop>
	<20121201224044.GL25450@1wt.eu>
	<1354403222.20109.539.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: w@1wt.eu, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56233 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751702Ab2LBBlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2012 20:41:19 -0500
In-Reply-To: <1354403222.20109.539.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 01 Dec 2012 15:07:02 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Recent network changes allowed high order pages being used
> for skb fragments.
> 
> This uncovered a bug in do_tcp_sendpages() which was assuming its caller
> provided an array of order-0 page pointers.
> 
> We only have to deal with a single page in this function, and its order
> is irrelevant.
> 
> Reported-by: Willy Tarreau <w@1wt.eu>
> Tested-by: Willy Tarreau <w@1wt.eu>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
