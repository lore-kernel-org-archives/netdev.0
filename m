From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 0/4] tunnels: SMP safe accounting
Date: Mon, 27 Sep 2010 21:51:27 -0700 (PDT)
Message-ID: <20100927.215127.115942543.davem@davemloft.net>
References: <1285583568.23938.81.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56032
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750974Ab0I1EvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 00:51:06 -0400
In-Reply-To: <1285583568.23938.81.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 27 Sep 2010 12:32:48 +0200

> Before making ip_gre, ipip, and sit transmit path lockless, it is
> necessary to make accounting SMP safe, not only for correctness but to
> avoid cache line ping pongs.
> 
> This also takes care of receive path, already lockless and using unsafe
> stats accounting.
> 
> I chose to use small percpu structures, holding {rx|tx}_{packets|bytes}
> only, and keep all other counters in netdev->stats, since they should be
> seldom used.

Series applied, thanks a lot Eric!
