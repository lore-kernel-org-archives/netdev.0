From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] ipv6: avoid high order memory allocations
 for /proc/net/ipv6_route
Date: Fri, 27 Sep 2013 17:33:02 -0400 (EDT)
Message-ID: <20130927.173302.304054571363734165.davem@davemloft.net>
References: <20130921145559.GA20730@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, greearb@candelatech.com, kaber@trash.net,
	yoshfuji@linux-ipv6.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50843 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754537Ab3I0VdE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 17:33:04 -0400
In-Reply-To: <20130921145559.GA20730@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sat, 21 Sep 2013 16:55:59 +0200

> Dumping routes on a system with lots rt6_infos in the fibs causes up to
> 11-order allocations in seq_file (which fail). While we could switch
> there to vmalloc we could just implement the streaming interface for
> /proc/net/ipv6_route. This patch switches /proc/net/ipv6_route from
> single_open_net to seq_open_net.
> 
> loff_t *pos tracks dst entries.
> 
> Also kill never used struct rt6_proc_arg and now unused function
> fib6_clean_all_ro.
> 
> Cc: Ben Greear <greearb@candelatech.com>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, nice work.
