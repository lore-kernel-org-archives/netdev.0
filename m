From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: increment retransmit counters in tlp and fast
 open
Date: Wed, 30 Apr 2014 16:15:11 -0400 (EDT)
Message-ID: <20140430.161511.665163855966614835.davem@davemloft.net>
References: <1398747629.29914.143.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nanditad@google.com, ycheng@google.com,
	ncardwell@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43634 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946025AbaD3UPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 16:15:12 -0400
In-Reply-To: <1398747629.29914.143.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 28 Apr 2014 22:00:29 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Both TLP and Fast Open call __tcp_retransmit_skb() instead of
> tcp_retransmit_skb() to avoid changing tp->retrans_out.
> 
> This has the side effect of missing SNMP counters increments as well
> as tcp_info tcpi_total_retrans updates.
> 
> Fix this by moving the stats increments of into __tcp_retransmit_skb()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
