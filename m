From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] ipv6: ipv6_dev_get_saddr() rcu works
Date: Sun, 08 Oct 2017 21:17:53 -0700 (PDT)
Message-ID: <20171008.211753.1788739907621353976.davem@davemloft.net>
References: <20171008023028.32071-1-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
        yoshfuji@linux-ipv6.org
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38914 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751068AbdJIERy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 00:17:54 -0400
In-Reply-To: <20171008023028.32071-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Sat,  7 Oct 2017 19:30:22 -0700

> Sending IPv6 udp packets on non connected sockets is quite slow,
> because ipv6_dev_get_saddr() is still using an rwlock and silly
> references games on ifa.
> 
> Tested:
> 
> $ ./super_netperf 16 -H 4444::555:0786 -l 2000 -t UDP_STREAM -- -m 100 &
> [1] 12527
> 
> Performance is boosted from 2.02 Mpps to 4.28 Mpps

Awesome, series applied, thanks!
