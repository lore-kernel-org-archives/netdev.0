From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Introduce skb_tunnel_rx() helper
Date: Mon, 17 May 2010 22:37:07 -0700 (PDT)
Message-ID: <20100517.223707.186297988.davem@davemloft.net>
References: <1274136636.2567.23.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45299
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756612Ab0ERFg6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 01:36:58 -0400
In-Reply-To: <1274136636.2567.23.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 18 May 2010 00:50:36 +0200

> skb rxhash should be cleared when a skb is handled by a tunnel before
> being delivered again, so that correct packet steering can take place.
> 
> There are other cleanups and accounting that we can factorize in a new
> helper, skb_tunnel_rx()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
