From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: tcp_sendmsg() page recycling
Date: Sun, 04 Dec 2011 13:21:34 -0500 (EST)
Message-ID: <20111204.132134.2286148075037261295.davem@davemloft.net>
References: <1323018317.2762.143.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38072 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753247Ab1LDSVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2011 13:21:36 -0500
In-Reply-To: <1323018317.2762.143.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 04 Dec 2011 18:05:17 +0100

> If our TCP_PAGE(sk) is not shared (page_count() == 1), we can set page
> offset to 0.
> 
> This permits better filling of the pages on small to medium tcp writes.
> 
> "tbench 16" results on my dev server (2x4x2 machine) :
> 
> Before : 3072 MB/s
> After  : 3146 MB/s  (2.4 % gain)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
