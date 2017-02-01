From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: reduce skb_warn_bad_offload() noise
Date: Wed, 01 Feb 2017 12:03:06 -0500 (EST)
Message-ID: <20170201.120306.1841734939749372887.davem@davemloft.net>
References: <1485886832.6360.133.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dvyukov@google.com, willemb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39366 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752863AbdBARDH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 12:03:07 -0500
In-Reply-To: <1485886832.6360.133.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 31 Jan 2017 10:20:32 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Dmitry reported warnings occurring in __skb_gso_segment() [1]
> 
> All SKB_GSO_DODGY producers can allow user space to feed
> packets that trigger the current check.
> 
> We could prevent them from doing so, rejecting packets, but
> this might add regressions to existing programs.
> 
> It turns out our SKB_GSO_DODGY handlers properly set up checksum
> information that is needed anyway when packets needs to be segmented.
> 
> By checking again skb_needs_check() after skb_mac_gso_segment(),
> we should remove these pesky warnings, at a very minor cost.
> 
> With help from Willem de Bruijn
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov  <dvyukov@google.com>
> Cc: Willem de Bruijn <willemb@google.com>

Applied, thanks Eric.
