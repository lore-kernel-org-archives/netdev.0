From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pch_gbe: fix transmit races
Date: Tue, 15 May 2012 13:43:00 -0400 (EDT)
Message-ID: <20120515.134300.588180020194758538.davem@davemloft.net>
References: <1336774254.31653.287.camel@edumazet-glaptop>
	<40680C535D6FE6498883F1640FACD44DDF93F1@ka-exchange-1.kontronamerica.local>
	<1337023566.8512.622.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy.cress@us.kontron.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40527 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966138Ab2EORnF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2012 13:43:05 -0400
In-Reply-To: <1337023566.8512.622.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 14 May 2012 21:26:06 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Andy reported pch_gbe triggered "NETDEV WATCHDOG" errors.
> 
> May 11 11:06:09 kontron kernel: WARNING: at net/sched/sch_generic.c:261
> dev_watchdog+0x1ec/0x200() (Not tainted)
> May 11 11:06:09 kontron kernel: Hardware name: N/A
> May 11 11:06:09 kontron kernel: NETDEV WATCHDOG: eth0 (pch_gbe):
> transmit queue 0 timed out
> 
> It seems pch_gbe has a racy tx path (races with TX completion path)
> 
> Remove tx_queue_lock lock since it has no purpose, we must use tx_lock
> instead.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Andy Cress <andy.cress@us.kontron.com>
> Tested-by: Andy Cress <andy.cress@us.kontron.com>

Applied.
