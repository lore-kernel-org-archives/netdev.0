From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: skbuff.c cleanup
Date: Wed, 01 Sep 2010 10:58:42 -0700 (PDT)
Message-ID: <20100901.105842.26933535.davem@davemloft.net>
References: <1283354710.2556.344.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58779
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755106Ab0IAR6Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 13:58:25 -0400
In-Reply-To: <1283354710.2556.344.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 01 Sep 2010 17:25:10 +0200

> (skb->data - skb->head) can be changed by skb_headroom(skb)
> 
> Remove some uses of NET_SKBUFF_DATA_USES_OFFSET, using
> (skb_end_pointer(skb) - skb->head) or 
> (skb_tail_pointer(skb) - skb->head) : compiler does the right thing,
> and this is more readable for us ;)
> 
> (struct skb_shared_info *) casts in pskb_expand_head() to help memcpy()
> to use aligned moves.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
