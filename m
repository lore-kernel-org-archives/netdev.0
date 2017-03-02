From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: orphan skbs in reassembly unit
Date: Wed, 01 Mar 2017 20:58:47 -0800 (PST)
Message-ID: <20170301.205847.286271242445976841.davem@davemloft.net>
References: <1488408306.9415.322.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andreyknvl@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58846 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751630AbdCBKYR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 05:24:17 -0500
In-Reply-To: <1488408306.9415.322.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 01 Mar 2017 14:45:06 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Andrey reported a use-after-free in IPv6 stack.
> 
> Issue here is that we free the socket while it still has skb
> in TX path and in some queues.
> 
> It happens here because IPv6 reassembly unit messes skb->truesize,
> breaking skb_set_owner_w() badly.
> 
> We fixed a similar issue for IPV4 in commit 8282f27449bf ("inet: frag:
> Always orphan skbs inside ip_defrag()")
 ...
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable.

Thanks.
