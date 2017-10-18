From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] tcp: Check daddr_cache before use in
 tracepoint
Date: Wed, 18 Oct 2017 14:15:40 +0100 (WEST)
Message-ID: <20171018.141540.2101290573491932828.davem@davemloft.net>
References: <1508193127-17626-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33030 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753652AbdJRNPr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 09:15:47 -0400
In-Reply-To: <1508193127-17626-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Mon, 16 Oct 2017 15:32:07 -0700

> Running perf in one window to capture tcp_retransmit_skb tracepoint:
>     $ perf record -e tcp:tcp_retransmit_skb -a
> 
> And causing a retransmission on an active TCP session (e.g., dropping
> packets in the receiver, changing MTU on the interface to 500 and back
> to 1500) triggers a panic:
 ...
> Check that daddr_cache is non-NULL before de-referencing.
> 
> Fixes: e086101b150a ("tcp: add a tracepoint for tcp retransmission")
> Signed-off-by: David Ahern <dsahern@gmail.com>

Applied.
