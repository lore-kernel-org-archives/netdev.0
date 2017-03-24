From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5] net: Add sysctl to toggle early demux for
 tcp and udp
Date: Fri, 24 Mar 2017 13:21:06 -0700 (PDT)
Message-ID: <20170324.132106.869851609280213495.davem@davemloft.net>
References: <1490297656-31068-1-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
        stephen@networkplumber.org, tom@herbertland.com
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44086 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755962AbdCXUVN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 16:21:13 -0400
In-Reply-To: <1490297656-31068-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Date: Thu, 23 Mar 2017 13:34:16 -0600

> Certain system process significant unconnected UDP workload.
> It would be preferrable to disable UDP early demux for those systems
> and enable it for TCP only.
> 
> By disabling UDP demux, we see these slight gains on an ARM64 system-
> 782 -> 788Mbps unconnected single stream UDPv4
> 633 -> 654Mbps unconnected UDPv4 different sources
> 
> The performance impact can change based on CPU architecure and cache
> sizes. There will not much difference seen if entire UDP hash table
> is in cache.
> 
> Both sysctls are enabled by default to preserve existing behavior.
> 
> v1->v2: Change function pointer instead of adding conditional as
> suggested by Stephen.
> 
> v2->v3: Read once in callers to avoid issues due to compiler
> optimizations. Also update commit message with the tests.
> 
> v3->v4: Store and use read once result instead of querying pointer
> again incorrectly.
> 
> v4->v5: Refactor to avoid errors due to compilation with IPV6={m,n}
> 
> Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
> Suggested-by: Eric Dumazet <edumazet@google.com>

Applied.
