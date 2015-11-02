From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp/dccp: fix ireq->pktopts race
Date: Mon, 02 Nov 2015 15:39:26 -0500 (EST)
Message-ID: <20151102.153926.1266009648322963748.davem@davemloft.net>
References: <1446223572.6254.19.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35274 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753239AbbKBUj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 15:39:28 -0500
In-Reply-To: <1446223572.6254.19.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 30 Oct 2015 09:46:12 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> IPv6 request sockets store a pointer to skb containing the SYN packet
> to be able to transfer it to full blown socket when 3WHS is done
> (ireq->pktopts -> np->pktoptions)
> 
> As explained in commit 5e0724d027f0 ("tcp/dccp: fix hashdance race for
> passive sessions"), we must transfer the skb only if we won the
> hashdance race, if multiple cpus receive the 'ack' packet completing
> 3WHS at the same time.
> 
> Fixes: e994b2f0fb92 ("tcp: do not lock listener to process SYN packets")
> Fixes: 079096f103fa ("tcp/dccp: install syn_recv requests into ehash table")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
