From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v3] tcp: add a tracepoint for tcp
 retransmission
Date: Sat, 14 Oct 2017 18:45:28 -0700 (PDT)
Message-ID: <20171014.184528.1895579700537124041.davem@davemloft.net>
References: <20171013200316.28561-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
        alexei.starovoitov@gmail.com, hannes@stressinduktion.org,
        brendan.d.gregg@gmail.com, ncardwell@google.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38402 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751306AbdJOBp3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Oct 2017 21:45:29 -0400
In-Reply-To: <20171013200316.28561-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri, 13 Oct 2017 13:03:16 -0700

> We need a real-time notification for tcp retransmission
> for monitoring.
> 
> Of course we could use ftrace to dynamically instrument this
> kernel function too, however we can't retrieve the connection
> information at the same time, for example perf-tools [1] reads
> /proc/net/tcp for socket details, which is slow when we have
> a lots of connections.
> 
> Therefore, this patch adds a tracepoint for __tcp_retransmit_skb()
> and exposes src/dst IP addresses and ports of the connection.
> This also makes it easier to integrate into perf.
> 
> Note, I expose both IPv4 and IPv6 addresses at the same time:
> for a IPv4 socket, v4 mapped address is used as IPv6 addresses,
> for a IPv6 socket, LOOPBACK4_IPV6 is already filled by kernel.
> Also, add sk and skb pointers as they are useful for BPF.
> 
> 1. https://github.com/brendangregg/perf-tools/blob/master/net/tcpretrans
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Cc: Brendan Gregg <brendan.d.gregg@gmail.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thank you.
