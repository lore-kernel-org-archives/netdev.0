From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] latest net-next-2.6 doesnt fly
Date: Fri, 02 Apr 2010 13:35:04 -0700 (PDT)
Message-ID: <20100402.133504.134680676.davem@davemloft.net>
References: <1270200783.1989.4.camel@edumazet-laptop>
	<1270201248.1989.8.camel@edumazet-laptop>
	<1270202304.1989.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fujita.tomonori@lab.ntt.co.jp
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60714
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752969Ab0DBUfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Apr 2010 16:35:03 -0400
In-Reply-To: <1270202304.1989.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 02 Apr 2010 11:58:24 +0200

> [PATCH net-next-2.6] net: illegal_highdma() fix
> 
> Followup to commit 5acbbd428db47b12f137a8a2aa96b3c0a96b744e
> (net: change illegal_highdma to use dma_mask)
> 
> If dev->dev.parent is NULL, we should not try to dereference it.
> 
> Dont force inline illegal_highdma() as its pretty big now.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks for tracking this down.
