From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: pskb_expand_head() optimization
Date: Mon, 06 Sep 2010 18:25:30 -0700 (PDT)
Message-ID: <20100906.182530.116366191.davem@davemloft.net>
References: <20100902.204332.02275687.davem@davemloft.net>
	<1283492880.3699.1437.camel@edumazet-laptop>
	<1283504972.2453.257.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44215
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755502Ab0IGBZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 21:25:12 -0400
In-Reply-To: <1283504972.2453.257.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 03 Sep 2010 11:09:32 +0200

> [PATCH net-next-2.6] net: pskb_expand_head() optimization
> 
> pskb_expand_head() blindly takes references on fragments before calling
> skb_release_data(), potentially releasing these references.
> 
> We can add a fast path, avoiding these atomic operations, if we own the
> last reference on skb->head.
> 
> Based on a previous patch from David
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Eric, I ended up applying this patch after all, thanks!
