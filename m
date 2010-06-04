From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] arp: RCU changes
Date: Thu, 03 Jun 2010 20:04:55 -0700 (PDT)
Message-ID: <20100603.200455.189719159.davem@davemloft.net>
References: <1275574150.2456.52.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44923
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932346Ab0FDDEp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 23:04:45 -0400
In-Reply-To: <1275574150.2456.52.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 Jun 2010 16:09:10 +0200

> Avoid two atomic ops in arp_fwd_proxy()
> 
> Avoid two atomic ops in arp_process()
> 
> Valid optims since arp_rcv() is run under rcu_read_lock()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
