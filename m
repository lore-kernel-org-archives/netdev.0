From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix overflow in __tcp_retransmit_skb()
Date: Sat, 17 Sep 2016 10:00:24 -0400 (EDT)
Message-ID: <20160917.100024.377016575232308074.davem@davemloft.net>
References: <1473952353.22679.25.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60098 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751269AbcIQOA0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2016 10:00:26 -0400
In-Reply-To: <1473952353.22679.25.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 15 Sep 2016 08:12:33 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> If a TCP socket gets a large write queue, an overflow can happen
> in a test in __tcp_retransmit_skb() preventing all retransmits.
> 
> The flow then stalls and resets after timeouts.
> 
> Tested:
> 
> sysctl -w net.core.wmem_max=1000000000
> netperf -H dest -- -s 1000000000
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
