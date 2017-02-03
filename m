From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: skb_needs_check() accepts CHECKSUM_NONE
 for tx
Date: Fri, 03 Feb 2017 17:33:12 -0500 (EST)
Message-ID: <20170203.173312.1885097526291277012.davem@davemloft.net>
References: <1486160982.21871.111.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com, maze@google.com,
        edumazet@google.com, dvyukov@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57716 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752356AbdBCWdO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 17:33:14 -0500
In-Reply-To: <1486160982.21871.111.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 03 Feb 2017 14:29:42 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> My recent change missed fact that UFO would perform a complete
> UDP checksum before segmenting in frags.
> 
> In this case skb->ip_summed is set to CHECKSUM_NONE.
> 
> We need to add this valid case to skb_needs_check()
> 
> Fixes: b2504a5dbef3 ("net: reduce skb_warn_bad_offload() noise")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
