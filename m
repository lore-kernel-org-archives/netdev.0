From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: optimize some skb_shinfo(skb) uses
Date: Fri, 06 Dec 2013 12:53:46 -0500 (EST)
Message-ID: <20131206.125346.2255922273599914894.davem@davemloft.net>
References: <1386311490.30495.243.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40761 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758388Ab3LFRxu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 12:53:50 -0500
In-Reply-To: <1386311490.30495.243.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 05 Dec 2013 22:31:30 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Compiler doesn't know skb_shinfo(skb) pointer is usually constant.
> 
> By using a temporary variable, we help generating smaller code.
> 
> For example, tcp_init_nondata_skb() is inlined after this patch.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
