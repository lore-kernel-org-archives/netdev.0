From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix 0 divide in __tcp_select_window()
Date: Wed, 01 Feb 2017 12:56:08 -0500 (EST)
Message-ID: <20170201.125608.445685471651002821.davem@davemloft.net>
References: <1485966833.6360.149.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dvyukov@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41816 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753022AbdBAR4J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 12:56:09 -0500
In-Reply-To: <1485966833.6360.149.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 01 Feb 2017 08:33:53 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> syszkaller fuzzer was able to trigger a divide by zero, when
> TCP window scaling is not enabled.
> 
> SO_RCVBUF can be used not only to increase sk_rcvbuf, also
> to decrease it below current receive buffers utilization.
> 
> If mss is negative or 0, just return a zero TCP window.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov  <dvyukov@google.com>
> ---
> No Fixes: tag, this is a day-0 bug.

Applied and queued up for -stable, thanks Eric.
