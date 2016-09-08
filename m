From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fastopen: avoid negative sk_forward_alloc
Date: Thu, 08 Sep 2016 16:08:31 -0700 (PDT)
Message-ID: <20160908.160831.1125164231859991114.davem@davemloft.net>
References: <1473262451.10725.43.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johunt@akamai.com, hkchu@google.com,
        ycheng@google.com, ncardwell@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41840 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752430AbcIHXIc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 19:08:32 -0400
In-Reply-To: <1473262451.10725.43.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 07 Sep 2016 08:34:11 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> When DATA and/or FIN are carried in a SYN/ACK message or SYN message,
> we append an skb in socket receive queue, but we forget to call
> sk_forced_mem_schedule().
> 
> Effect is that the socket has a negative sk->sk_forward_alloc as long as
> the message is not read by the application.
> 
> Josh Hunt fixed a similar issue in commit d22e15371811 ("tcp: fix tcp
> fin memory accounting")
>  
> Fixes: 168a8f58059a ("tcp: TCP Fast Open Server - main code path")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable.
