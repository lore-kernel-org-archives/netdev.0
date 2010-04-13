From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: Dont use netdev_warn()
Date: Tue, 13 Apr 2010 01:52:15 -0700 (PDT)
Message-ID: <20100413.015215.223470813.davem@davemloft.net>
References: <1270797973.2623.28.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, joe@perches.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42513
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751136Ab0DMIwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 04:52:11 -0400
In-Reply-To: <1270797973.2623.28.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 09 Apr 2010 09:26:13 +0200

> Dont use netdev_warn() in dev_cap_txqueue() and get_rps_cpu() so that we
> can catch following warnings without crash.
> 
> bond0.2240 received packet on queue 6, but number of RX queues is 1
> bond0.2240 received packet on queue 11, but number of RX queues is 1
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied to net-next-2.6, thanks Eric.
