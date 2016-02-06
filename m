From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: fastopen: call tcp_fin() if FIN present
 in SYNACK
Date: Sat, 06 Feb 2016 16:50:15 -0500 (EST)
Message-ID: <20160206.165015.2150156850444799755.davem@davemloft.net>
References: <20160206.031302.1262914455786911151.davem@davemloft.net>
	<1454784731.7627.329.camel@edumazet-glaptop2.roam.corp.google.com>
	<1454786188.7627.339.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org, sara@sinodun.com,
	ycheng@google.com, ncardwell@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53819 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752286AbcBFV4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2016 16:56:55 -0500
In-Reply-To: <1454786188.7627.339.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 06 Feb 2016 11:16:28 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> When we acknowledge a FIN, it is not enough to ack the sequence number
> and queue the skb into receive queue. We also have to call tcp_fin()
> to properly update socket state and send proper poll() notifications.
> 
> It seems we also had the problem if we received a SYN packet with the
> FIN flag set, but it does not seem an urgent issue, as no known
> implementation can do that.
> 
> Fixes: 61d2bcae99f6 ("tcp: fastopen: accept data/FIN present in SYNACK message")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
