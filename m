From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: fix tcp_probe_timer() for
 TCP_USER_TIMEOUT
Date: Sun, 21 May 2017 13:51:11 -0400 (EDT)
Message-ID: <20170521.135111.1511992009561369461.davem@davemloft.net>
References: <1495388340.6465.50.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, soheil@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45294 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750972AbdEURvV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 13:51:21 -0400
In-Reply-To: <1495388340.6465.50.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 21 May 2017 10:39:00 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> TCP_USER_TIMEOUT is still converted to jiffies value in
> icsk_user_timeout
> 
> So we need to make a conversion for the cases HZ != 1000 
> 
> Fixes: 9a568de4818d ("tcp: switch TCP TS option (RFC 7323) to 1ms clock")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thank Eric.

I kinda expected a few pieces of fallout from the 1ms changes :)
