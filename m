From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: splice: fix __splice_segment()
Date: Fri, 11 Jan 2013 16:48:30 -0800 (PST)
Message-ID: <20130111.164830.1939655866109021139.davem@davemloft.net>
References: <20130110072136.GK9943@1wt.eu>
	<1357831787.27446.2168.camel@edumazet-glaptop>
	<1357951597.20249.247.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: w@1wt.eu, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48954 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755744Ab3ALAsb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2013 19:48:31 -0500
In-Reply-To: <1357951597.20249.247.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 11 Jan 2013 16:46:37 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> commit 9ca1b22d6d2 (net: splice: avoid high order page splitting)
> forgot that skb->head could need a copy into several page frags.
> 
> This could be the case for loopback traffic mostly.
> 
> Also remove now useless skb argument from linear_to_page()
> and __splice_segment() prototypes.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Willy Tarreau <w@1wt.eu>

Applied, thanks Eric.
