From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sch_netem: faster rb tree removal
Date: Mon, 25 Sep 2017 20:33:49 -0700 (PDT)
Message-ID: <20170925.203349.1305228974374102355.davem@davemloft.net>
References: <1506190048.29839.206.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40604 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933685AbdIZDdu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 23:33:50 -0400
In-Reply-To: <1506190048.29839.206.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 23 Sep 2017 11:07:28 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> While running TCP tests involving netem storing millions of packets,
> I had the idea to speed up tfifo_reset() and did experiments.
> 
> I tried the rbtree_postorder_for_each_entry_safe() method that is
> used in skb_rbtree_purge() but discovered it was slower than the
> current tfifo_reset() method.
> 
> I measured time taken to release skbs with three occupation levels :
> 10^4, 10^5 and 10^6 skbs with three methods :
 ...
> Results :
 ...
> I will also change skb_rbtree_purge() in a second patch.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
