From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: 64bit stats for netdev_queue
Date: Mon, 19 Jul 2010 09:35:49 -0700 (PDT)
Message-ID: <20100719.093549.223487047.davem@davemloft.net>
References: <1279546422.2553.45.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55842
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S936431Ab0GSQfd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 12:35:33 -0400
In-Reply-To: <1279546422.2553.45.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 19 Jul 2010 15:33:42 +0200

> Since struct netdev_queue tx_bytes/tx_packets/tx_dropped are already
> protected by _xmit_lock, its easy to convert these fields to u64 instead
> of unsigned long.
> This completes 64bit stats for devices using them (vlan, macvlan, ...)
> 
> Strictly, we could avoid the locking in dev_txq_stats_fold() on 64bit
> arches, but its slow path and we prefer keep it simple.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks a lot Eric.
