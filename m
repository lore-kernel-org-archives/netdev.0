From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: guarantee forward progress in
 tcp_sendmsg()
Date: Tue, 03 May 2016 16:20:54 -0400 (EDT)
Message-ID: <20160503.162054.1321812964438781830.davem@davemloft.net>
References: <1461964613-4872-1-git-send-email-edumazet@google.com>
	<1461964613-4872-8-git-send-email-edumazet@google.com>
	<1462250965.5535.286.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org, soheil@google.com,
	ast@fb.com, marcelo.leitner@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52638 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756148AbcECUU4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 16:20:56 -0400
In-Reply-To: <1462250965.5535.286.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 02 May 2016 21:49:25 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Under high rx pressure, it is possible tcp_sendmsg() never has a
> chance to allocate an skb and loop forever as sk_flush_backlog()
> would always return true.
> 
> Fix this by calling sk_flush_backlog() only if one skb had been
> allocated and filled before last backlog check.
> 
> Fixes: d41a69f1d390 ("tcp: make tcp_sendmsg() aware of socket backlog")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
