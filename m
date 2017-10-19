From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] tcp: Remove use of daddr_cache in
 tracepoint
Date: Thu, 19 Oct 2017 13:32:41 +0100 (WEST)
Message-ID: <20171019.133241.882635713749300990.davem@davemloft.net>
References: <1508270973-23789-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49186 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751760AbdJSMct (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 08:32:49 -0400
In-Reply-To: <1508270973-23789-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Tue, 17 Oct 2017 13:09:33 -0700

> Running perf in one window to capture tcp_retransmit_skb tracepoint:
>     $ perf record -e tcp:tcp_retransmit_skb -a
> 
> And causing a retransmission on an active TCP session (e.g., dropping
> packets in the receiver, changing MTU on the interface to 500 and back
> to 1500) triggers a panic:
 ...
> Remove use of ipv6_pinfo in favor of data in sock_common.
> 
> Fixes: e086101b150a ("tcp: add a tracepoint for tcp retransmission")
> Signed-off-by: David Ahern <dsahern@gmail.com>

This doesn't apply to net-next, please respin.

Thanks.
