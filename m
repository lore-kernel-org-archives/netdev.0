From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] net: Always poll at least one device in
 net_rx_action
Date: Tue, 23 Dec 2014 23:20:48 -0500 (EST)
Message-ID: <20141223.232048.1089366511326338002.davem@davemloft.net>
References: <20141220201453.GA6924@gondor.apana.org.au>
	<E1Y2QRs-0001q5-6u@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, david.vrabel@citrix.com,
	netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	konrad.wilk@oracle.com, boris.ostrovsky@oracle.com,
	edumazet@google.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35975 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751048AbaLXEUu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2014 23:20:50 -0500
In-Reply-To: <E1Y2QRs-0001q5-6u@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 21 Dec 2014 07:16:24 +1100

> We should only perform the softnet_break check after we have polled
> at least one device in net_rx_action.  Otherwise a zero or negative
> setting of netdev_budget can lock up the whole system.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
