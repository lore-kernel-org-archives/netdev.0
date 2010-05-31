From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: remove zap_completion_queue
Date: Mon, 31 May 2010 00:30:12 -0700 (PDT)
Message-ID: <20100531.003012.183030076.davem@davemloft.net>
References: <1274346963.4046.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54281
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756397Ab0EaHaE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 May 2010 03:30:04 -0400
In-Reply-To: <1274346963.4046.25.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 20 May 2010 11:16:03 +0200

> netpoll does an interesting work in zap_completion_queue(), but this was
> before we did skb orphaning before delivering packets to device.
> 
> It now makes sense to add a test in dev_kfree_skb_irq() to not queue a
> skb if already orphaned, and to remove netpoll zap_completion_queue() as
> a bonus.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
