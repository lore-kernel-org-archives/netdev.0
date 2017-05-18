From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: fix tcp_rearm_rto()
Date: Thu, 18 May 2017 13:20:59 -0400 (EDT)
Message-ID: <20170518.132059.1279235795595365192.davem@davemloft.net>
References: <20170516210014.31176-16-edumazet@google.com>
        <1495110825.6465.22.camel@edumazet-glaptop3.roam.corp.google.com>
        <1495124158.6465.30.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, ncardwell@google.com, ycheng@google.com,
        soheil@google.com, weiwan@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45340 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933159AbdERRVE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 13:21:04 -0400
In-Reply-To: <1495124158.6465.30.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 18 May 2017 09:15:58 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> skbs in (re)transmit queue no longer have a copy of jiffies
> at the time of the transmit : skb->skb_mstamp is now in usec unit,
> with no correlation to tcp_jiffies32.
> 
> We have to convert rto from jiffies to usec, compute a time difference
> in usec, then convert the delta to HZ units.
> 
> Fixes: 9a568de4818d ("tcp: switch TCP TS option (RFC 7323) to 1ms clock")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
