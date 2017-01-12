From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: sr: static percpu allocation for
 hmac_ring
Date: Thu, 12 Jan 2017 16:53:06 -0500 (EST)
Message-ID: <20170112.165306.201677819273533443.davem@davemloft.net>
References: <1484239810.15816.47.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, david.lebrun@uclouvain.be
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58638 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750730AbdALVxI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 16:53:08 -0500
In-Reply-To: <1484239810.15816.47.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 12 Jan 2017 08:50:10 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Current allocations are not NUMA aware, and lack proper
> cleanup in case of error.
> 
> It is perfectly fine to use static per cpu allocations for 256 bytes
> per cpu.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: David Lebrun <david.lebrun@uclouvain.be>

Applied.
