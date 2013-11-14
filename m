From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-tcp: fix panic in tcp_fastopen_cache_set()
Date: Thu, 14 Nov 2013 16:33:58 -0500 (EST)
Message-ID: <20131114.163358.326663574619567783.davem@davemloft.net>
References: <20131113204543.GA26715@redhat.com>
	<1384382413.28458.132.camel@edumazet-glaptop2.roam.corp.google.com>
	<1384383646.28458.138.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, netdev@vger.kernel.org, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52980 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757124Ab3KNVeB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 16:34:01 -0500
In-Reply-To: <1384383646.28458.138.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 13 Nov 2013 15:00:46 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> We had some reports of crashes using TCP fastopen, and Dave Jones
> gave a nice stack trace pointing to the error.
> 
> Issue is that tcp_get_metrics() should not be called with a NULL dst
> 
> Fixes: 1fe4c481ba637 ("net-tcp: Fast Open client - cookie cache")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dave Jones <davej@redhat.com>

Applied and queued up for -stable, thanks!
