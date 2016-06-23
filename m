From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netem: fix a use after free
Date: Thu, 23 Jun 2016 15:08:29 -0400 (EDT)
Message-ID: <20160623.150829.1562725878285580078.davem@davemloft.net>
References: <1466459980.6850.20.camel@edumazet-glaptop3.roam.corp.google.com>
	<1466460043.6850.21.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
	stephen@networkplumber.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34793 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751014AbcFWTIm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 15:08:42 -0400
In-Reply-To: <1466460043.6850.21.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 20 Jun 2016 15:00:43 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> If the packet was dropped by lower qdisc, then we must not
> access it later.
> 
> Save qdisc_pkt_len(skb) in a temp variable.
> 
> Fixes: 2ccccf5fb43f ("net_sched: update hierarchical backlog too")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.
