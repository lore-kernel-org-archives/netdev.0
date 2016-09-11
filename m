From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: better use ooo_last_skb in
 tcp_data_queue_ofo()
Date: Sat, 10 Sep 2016 21:43:59 -0700 (PDT)
Message-ID: <20160910.214359.2171314938577710732.davem@davemloft.net>
References: <1473456165.18970.66.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com, wygivan@google.com,
        ycheng@google.com, ncardwell@google.com, ilpo.jarvinen@helsinki.fi
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51584 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750912AbcIKEoA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Sep 2016 00:44:00 -0400
In-Reply-To: <1473456165.18970.66.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 09 Sep 2016 14:22:45 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Willem noticed that we could avoid an rbtree lookup if the
> the attempt to coalesce incoming skb to the last skb failed
> for some reason.
> 
> Since most ooo additions are at the tail, this is definitely
> worth adding a test and fast path.
> 
> Suggested-by: Willem de Bruijn <willemb@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
