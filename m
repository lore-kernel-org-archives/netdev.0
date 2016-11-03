From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix potential memory corruption
Date: Thu, 03 Nov 2016 15:34:57 -0400 (EDT)
Message-ID: <20161103.153457.2072176771493256903.davem@davemloft.net>
References: <1478098397.7065.370.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hans.westgaard.ry@oracle.com,
        haakon.bugge@oracle.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41598 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752308AbcKCTfB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 15:35:01 -0400
In-Reply-To: <1478098397.7065.370.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 02 Nov 2016 07:53:17 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Imagine initial value of max_skb_frags is 17, and last
> skb in write queue has 15 frags.
> 
> Then max_skb_frags is lowered to 14 or smaller value.
> 
> tcp_sendmsg() will then be allowed to add additional page frags
> and eventually go past MAX_SKB_FRAGS, overflowing struct
> skb_shared_info.
> 
> Fixes: 5f74f82ea34c ("net:Add sysctl_max_skb_frags")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.
