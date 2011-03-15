From: David Miller <davem@davemloft.net>
Subject: Re: IPsec tunnel forwarding in net-next-2.6 since 452edd59
Date: Tue, 15 Mar 2011 15:28:25 -0700 (PDT)
Message-ID: <20110315.152825.193708028.davem@davemloft.net>
References: <4D7FB054.2090902@cbnco.com>
	<1300227411.2565.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: msmith@cbnco.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48636
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752215Ab1COW1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 18:27:47 -0400
In-Reply-To: <1300227411.2565.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 15 Mar 2011 23:16:51 +0100

> Could you try following patch ?
> 
> [PATCH] xfrm: fix __xfrm_route_forward()
> 
> This function should return 0 in case of error, 1 if OK
> commit 452edd598f60522 (xfrm: Return dst directly from xfrm_lookup())
> got it wrong.
> 
> Reported-and-bisected-by: Michael Smith <msmith@cbnco.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks so much for fixing this Eric, sheesh you are so awesome that
you don't even give me enough time to fix my own bugs. :-))))

Applied, and indeed thanks to Michael for the excellent report.

