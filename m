From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: tcp_make_synack() can use alloc_skb()
Date: Mon, 04 Jun 2012 11:33:12 -0400 (EDT)
Message-ID: <20120604.113312.1260669224865375791.davem@davemloft.net>
References: <1338789043.2760.1719.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40232 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752716Ab2FDPdT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 11:33:19 -0400
In-Reply-To: <1338789043.2760.1719.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 04 Jun 2012 07:50:43 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> There is no value using sock_wmalloc() in tcp_make_synack().
> 
> A listener socket only sends SYNACK packets, they are not queued in a
> socket queue, only in Qdisc and device layers, so the number of in
> flight packets is limited in these layers. We used sock_wmalloc() with
> the %force parameter set to 1 to ignore socket limits anyway.
> 
> This patch removes two atomic operations per SYNACK packet.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Looks good, applied.
