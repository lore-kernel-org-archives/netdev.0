From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] slcan: ldisc generated skbs are received in softirq
 context
Date: Thu, 11 Aug 2011 05:56:14 -0700 (PDT)
Message-ID: <20110811.055614.415286593914229309.davem@davemloft.net>
References: <4E42A163.5030208@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, matvejchikov@gmail.com,
	alan@lxorguk.ukuu.org.uk
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36555 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755583Ab1HKM60 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2011 08:58:26 -0400
In-Reply-To: <4E42A163.5030208@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Wed, 10 Aug 2011 17:18:59 +0200

> As this discussion pointed out
> 
> http://marc.info/?l=linux-netdev&m=131257225602375
> 
> netdevices that are based on serial line disciplines should use netif_rx_ni()
> when pushing received socketbuffers into the netdev rx queue.
> 
> Following commit 614851601c121b1320a35757ab88292d6272f906 ("slip: fix NOHZ
> local_softirq_pending 08 warning") this patch updates the slcan driver
> accordingly.
> 
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
> CC: Matvejchikov Ilya <matvejchikov@gmail.com>
> CC: Alan Cox <alan@lxorguk.ukuu.org.uk>

Applied.
