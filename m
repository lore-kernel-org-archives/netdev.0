From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] bna: fix stats handling
Date: Thu, 02 Sep 2010 12:45:14 -0700 (PDT)
Message-ID: <20100902.124514.245410670.davem@davemloft.net>
References: <20100823.203552.63040549.davem@davemloft.net>
	<1282627901.2378.1451.camel@edumazet-laptop>
	<1283455623.3699.56.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rmody@brocade.com, netdev@vger.kernel.org, amathur@brocade.com,
	ddutt@brocade.com, huangj@brocade.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41175
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751113Ab0IBTo5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 15:44:57 -0400
In-Reply-To: <1283455623.3699.56.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 02 Sep 2010 21:27:03 +0200

> [PATCH net-next-2.6] bna: fix stats handling
> 
> get_stats() method incorrectly clears a global array before folding
> various stats. This can break SNMP applications.
> 
> Switch to 64 bit flavor to work on a user supplied buffer, and provide
> 64bit counters even on 32bit arches.
> 
> Fix a bug in bnad_netdev_hwstats_fill(), for rx_fifo_errors, missing a
> folding (only the last counter was taken into account)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Acked-by: Rasesh Mody <rmody@brocade.com>

Applied.
