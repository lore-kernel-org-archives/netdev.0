From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: cache skb_shinfo() in skb_try_coalesce()
Date: Wed, 04 Oct 2017 11:34:33 -0700 (PDT)
Message-ID: <20171004.113433.608816562592951176.davem@davemloft.net>
References: <1507139315.14419.5.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49498 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751177AbdJDSeg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 14:34:36 -0400
In-Reply-To: <1507139315.14419.5.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 04 Oct 2017 10:48:35 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Compiler does not really know that skb_shinfo(to|from) are constants
> in skb_try_coalesce(), lets cache their values to shrink code.
> 
> We might even take care of skb_zcopy() calls later.
> 
> $ size net/core/skbuff.o.before net/core/skbuff.o
>    text	   data	    bss	    dec	    hex	filename
>   40727	   1298	      0	  42025	   a429	net/core/skbuff.o.before
>   40631	   1298	      0	  41929	   a3c9	net/core/skbuff.o
> 
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
