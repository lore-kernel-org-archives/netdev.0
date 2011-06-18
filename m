From: David Miller <davem@davemloft.net>
Subject: Re: kernel 2.6.39 eats multicast packets
Date: Sat, 18 Jun 2011 11:59:57 -0700 (PDT)
Message-ID: <20110618.115957.404950645772655687.davem@davemloft.net>
References: <op.vw7on9im1qh6di@localhost.localdomain>
	<1308392724.3539.48.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: knut.andre.tidemann@jotron.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55283 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752028Ab1FRTAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jun 2011 15:00:08 -0400
In-Reply-To: <1308392724.3539.48.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 18 Jun 2011 12:25:24 +0200

> [PATCH] ipv4: fix multicast losses
> 
> Knut Tidemann found that first packet of a multicast flow was not
> correctly received, and bisected the regression to commit b23dd4fe42b4
> (Make output route lookup return rtable directly.)
> 
> Special thanks to Knut, who provided a very nice bug report, including
> sample programs to demonstrate the bug.
> 
> Reported-and-bisectedby: Knut Tidemann <knut.andre.tidemann@jotron.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks everyone.
