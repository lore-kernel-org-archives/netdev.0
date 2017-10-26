From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: call tcp_rate_skb_sent() when retransmit with
 unaligned skb->data
Date: Thu, 26 Oct 2017 17:51:06 +0900 (KST)
Message-ID: <20171026.175106.59899352471128775.davem@davemloft.net>
References: <20171024234442.1464-1-ysseung@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, soheil@google.com
To: ysseung@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59594 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751236AbdJZIvK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 04:51:10 -0400
In-Reply-To: <20171024234442.1464-1-ysseung@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yousuk Seung <ysseung@google.com>
Date: Tue, 24 Oct 2017 16:44:42 -0700

> Current implementation calls tcp_rate_skb_sent() when tcp_transmit_skb()
> is called when it clones skb only. Not calling tcp_rate_skb_sent() is OK
> for all such code paths except from __tcp_retransmit_skb() which happens
> when skb->data address is not aligned. This may rarely happen e.g. when
> small amount of data is sent initially and the receiver partially acks
> odd number of bytes for some reason, possibly malicious.
> 
> Signed-off-by: Yousuk Seung <ysseung@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> Acked-by: Eric Dumazet <edumazet@google.com>

This doesn't apply to any of m trees.
