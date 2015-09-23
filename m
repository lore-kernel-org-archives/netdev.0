From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: factorize sk_txhash init
Date: Tue, 22 Sep 2015 17:31:01 -0700 (PDT)
Message-ID: <20150922.173101.2074818900453085610.davem@davemloft.net>
References: <1442878107.29850.69.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37537 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759465AbbIWAbC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 20:31:02 -0400
In-Reply-To: <1442878107.29850.69.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 21 Sep 2015 16:28:27 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Neal suggested to move sk_txhash init into tcp_create_openreq_child(),
> called both from IPv4 and IPv6.
> 
> This opportunity was missed in commit 58d607d3e52f ("tcp: provide
> skb->hash to synack packets")
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

This doesn't apply to net-next, please respin.

Thanks.
