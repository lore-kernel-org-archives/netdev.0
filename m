From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: speed up skb_rbtree_purge()
Date: Mon, 25 Sep 2017 20:36:11 -0700 (PDT)
Message-ID: <20170925.203611.1769058727594321517.davem@davemloft.net>
References: <1506195552.29839.214.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40696 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933685AbdIZDgM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 23:36:12 -0400
In-Reply-To: <1506195552.29839.214.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 23 Sep 2017 12:39:12 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> As measured in my prior patch ("sch_netem: faster rb tree removal"),
> rbtree_postorder_for_each_entry_safe() is nice looking but much slower
> than using rb_next() directly, except when tree is small enough
> to fit in CPU caches (then the cost is the same)
> 
> Also note that there is not even an increase of text size :
> $ size net/core/skbuff.o.before net/core/skbuff.o
>    text	   data	    bss	    dec	    hex	filename
>   40711	   1298	      0	  42009	   a419	net/core/skbuff.o.before
>   40711	   1298	      0	  42009	   a419	net/core/skbuff.o
> 
> 
> From: Eric Dumazet <edumazet@google.com>

Applied.
