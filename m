From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: Initial skb->dev and skb->protocol in
 ip6_output
Date: Fri, 09 Jun 2017 15:08:36 -0400 (EDT)
Message-ID: <20170609.150836.1427149901008136163.davem@davemloft.net>
References: <1497035168-9093-1-git-send-email-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lorenzo@google.com, edumazet@google.com,
        fengc@google.com
To: chenbofeng.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37230 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751554AbdFITIl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 15:08:41 -0400
In-Reply-To: <1497035168-9093-1-git-send-email-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Date: Fri,  9 Jun 2017 12:06:07 -0700

> From: Chenbo Feng <fengc@google.com>
> 
> Move the initialization of skb->dev and skb->protocol from
> ip6_finish_output2 to ip6_output. This can make the skb->dev and
> skb->protocol information avalaible to the CGROUP eBPF filter.
> 
> Signed-off-by: Chenbo Feng <fengc@google.com>
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.

This makes ipv6 consistent with ipv4.

I am surprised this wasn't noticed, for example, in netfilter.
