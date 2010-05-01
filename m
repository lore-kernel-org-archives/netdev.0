From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: sock_def_readable() and friends RCU
 conversion
Date: Sat, 01 May 2010 15:00:34 -0700 (PDT)
Message-ID: <20100501.150034.135987748.davem@davemloft.net>
References: <20100430.163519.133415203.davem@davemloft.net>
	<1272697367.2230.106.camel@edumazet-laptop>
	<1272701011.2230.134.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, xiaosuo@gmail.com, therbert@google.com,
	shemminger@vyatta.com, netdev@vger.kernel.org, eilong@broadcom.com,
	bmb@athenacr.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44665
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756409Ab0EAWAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 May 2010 18:00:30 -0400
In-Reply-To: <1272701011.2230.134.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 01 May 2010 10:03:31 +0200

> David, I also need this RCU thing in order to be able to group all
> wakeups at the end of net_rx_action().
> 
> Plan was to use RCU, so that I dont need to increase sk_refcnt when
> queueing a "wakeup" (and decrease sk_refcnt a long time after)
> 
> Previous attempt was a bit hacky,
> http://patchwork.ozlabs.org/patch/24179/
> 
> I expect 2010 one will be cleaner :)

Fair enough, I'm convinced now, applied thanks!
