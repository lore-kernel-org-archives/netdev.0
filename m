From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: Remove duplicate tcp_filter hook in ipv6
Date: Sat, 10 Jun 2017 16:08:19 -0400 (EDT)
Message-ID: <20170610.160819.564348879790810911.davem@davemloft.net>
References: <1497035857-9927-1-git-send-email-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lorenzo@google.com, edumazet@google.com,
        fengc@google.com
To: chenbofeng.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33486 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751563AbdFJUIV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 16:08:21 -0400
In-Reply-To: <1497035857-9927-1-git-send-email-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Date: Fri,  9 Jun 2017 12:17:37 -0700

> From: Chenbo Feng <fengc@google.com>
> 
> There are two tcp_filter hooks in tcp_ipv6 ingress path currently.
> One is at tcp_v6_rcv and another is in tcp_v6_do_rcv. It seems the
> tcp_filter() call inside tcp_v6_do_rcv is redundent and some packet
> will be filtered twice in this situation. This will cause trouble
> when using eBPF filters to account traffic data.
> 
> Signed-off-by: Chenbo Feng <fengc@google.com>
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thank you.
