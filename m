From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: do not export tcp_gso_segment() and
 tcp_gro_receive()
Date: Tue, 14 Jan 2014 18:54:13 -0800 (PST)
Message-ID: <20140114.185413.1939315935185062882.davem@davemloft.net>
References: <1389745906.31367.294.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54627 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751942AbaAOCyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 21:54:13 -0500
In-Reply-To: <1389745906.31367.294.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 14 Jan 2014 16:31:46 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> tcp_gso_segment() and tcp_gro_receive() no longer need to be
> exported. IPv4 and IPv6 offloads are statically linked.
> 
> Note that tcp_gro_complete() is still used by bnx2x, unfortunately.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
