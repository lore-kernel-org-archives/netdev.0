From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: add a comment on netdev->last_rx
Date: Tue, 31 Aug 2010 13:37:27 -0700 (PDT)
Message-ID: <20100831.133727.235702469.davem@davemloft.net>
References: <1283276416.2550.140.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39915
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754603Ab0HaUhL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Aug 2010 16:37:11 -0400
In-Reply-To: <1283276416.2550.140.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 31 Aug 2010 19:40:16 +0200

> As some driver authors seem to reintroduce dev->last_rx use,
> add a comment to strongly discourage this.
> 
> Since commit 6cf3f41e6c0 (bonding, net: Move last_rx update into bonding
> recv logic), network drivers dont need to update last_rx themselves,
> unless they use this field to implement a timeout.
> 
> Not updating last_rx helps not dirtying a cache line, improving
> performance in SMP.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
