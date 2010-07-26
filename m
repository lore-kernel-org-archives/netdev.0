From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] netlink: netlink_recvmsg() fix
Date: Sun, 25 Jul 2010 21:55:48 -0700 (PDT)
Message-ID: <20100725.215548.112589000.davem@davemloft.net>
References: <1279699529.3707.5.camel@jlt3.sipsolutions.net>
	<1279700420.2452.15.camel@edumazet-laptop>
	<1279701835.2452.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46422
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752624Ab0GZEzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jul 2010 00:55:31 -0400
In-Reply-To: <1279701835.2452.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 21 Jul 2010 10:43:55 +0200

> [PATCH net-next-2.6 v3] netlink: netlink_recvmsg() fix
> 
> commit 1dacc76d0014 
> (net/compat/wext: send different messages to compat tasks)
> introduced a race condition on netlink, in case MSG_PEEK is used.
> 
> An skb given by skb_recv_datagram() might be shared, we must copy it
> before any modification, or risk fatal corruption.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
