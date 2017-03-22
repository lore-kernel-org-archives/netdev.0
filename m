From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sch_dsmark: fix invalid skb_cow() usage
Date: Tue, 21 Mar 2017 17:22:08 -0700 (PDT)
Message-ID: <20170321.172208.1665261530100272388.davem@davemloft.net>
References: <1489763128.28631.286.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
        weiwan@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59108 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757217AbdCVAWK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 20:22:10 -0400
In-Reply-To: <1489763128.28631.286.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 17 Mar 2017 08:05:28 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> skb_cow(skb, sizeof(ip header)) is not very helpful in this context.
> 
> First we need to use pskb_may_pull() to make sure the ip header
> is in skb linear part, then use skb_try_make_writable() to
> address clones issues.
> 
> Fixes: 4c30719f4f55 ("[PKT_SCHED] dsmark: handle cloned and non-linear skb's")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.
