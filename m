From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: use per task frag allocator in
 skb_append_datato_frags
Date: Fri, 28 Dec 2012 15:29:19 -0800 (PST)
Message-ID: <20121228.152919.278534013852665194.davem@davemloft.net>
References: <1356710797.21409.150.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55978 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755071Ab2L1X3U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Dec 2012 18:29:20 -0500
In-Reply-To: <1356710797.21409.150.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 28 Dec 2012 08:06:37 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Use the new per task frag allocator in skb_append_datato_frags(),
> to reduce number of frags and page allocator overhead.
> 
> Tested:
>  ifconfig lo mtu 16436
>  perf record netperf -t UDP_STREAM ; perf report 
> 
> before :
>  Throughput: 32928 Mbit/s
 ...
>  after:
>   Throughput: 47185 Mbit/s
 ...
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Very nice, applied, thanks Eric.
