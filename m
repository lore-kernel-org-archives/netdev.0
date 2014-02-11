From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 6lowpan: fix lockdep splats
Date: Mon, 10 Feb 2014 17:51:56 -0800 (PST)
Message-ID: <20140210.175156.1760225535255103785.davem@davemloft.net>
References: <20140209102047.GA14770@omega>
	<1391949707.10160.130.camel@edumazet-glaptop2.roam.corp.google.com>
	<1392061355.6615.52.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.aring@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57522 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751503AbaBKBv5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 20:51:57 -0500
In-Reply-To: <1392061355.6615.52.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 10 Feb 2014 11:42:35 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> When a device ndo_start_xmit() calls again dev_queue_xmit(),
> lockdep can complain because dev_queue_xmit() is re-entered and the
> spinlocks protecting tx queues share a common lockdep class.
> 
> Same issue was fixed for bonding/l2tp/ppp in commits 
> 
> 0daa2303028a6 ("[PATCH] bonding: lockdep annotation")
> 49ee49202b4ac ("bonding: set qdisc_tx_busylock to avoid LOCKDEP splat")
> 23d3b8bfb8eb2 ("net: qdisc busylock needs lockdep annotations ")
> 303c07db487be ("ppp: set qdisc_tx_busylock to avoid LOCKDEP splat ")
> 
> Reported-by: Alexander Aring <alex.aring@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Tested-by: Alexander Aring <alex.aring@gmail.com>

Applied, thanks Eric.
