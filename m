From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] caif: fix leaks and race in caif_queue_rcv_skb()
Date: Tue, 21 Jul 2015 00:03:08 -0700 (PDT)
Message-ID: <20150721.000308.1914060070713511011.davem@davemloft.net>
References: <1437121163.1026.20.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55921 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751211AbbGUHDK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 03:03:10 -0400
In-Reply-To: <1437121163.1026.20.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 17 Jul 2015 10:19:23 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> 1) If sk_filter() is applied, skb was leaked (not freed)
> 2) Testing SOCK_DEAD twice is racy :
>    packet could be freed while already queued.
> 3) Remove obsolete comment about caching skb->len
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
