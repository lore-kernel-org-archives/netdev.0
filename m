From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: tcp: fix TCLASS value in ACK messages sent from
 TIME_WAIT
Date: Thu, 27 Oct 2011 01:32:28 -0400 (EDT)
Message-ID: <20111027.013228.1551611920578436871.davem@davemloft.net>
References: <20111026.155908.1133603039272144196.davem@davemloft.net>
	<20111026.160159.696019885442921932.davem@davemloft.net>
	<1319690022.3436.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42325 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751565Ab1J0Fcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2011 01:32:32 -0400
In-Reply-To: <1319690022.3436.10.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 27 Oct 2011 06:33:42 +0200

> [PATCH] ipv6: tcp: fix TCLASS value in ACK messages sent from TIME_WAIT
> 
> commit 66b13d99d96a (ipv4: tcp: fix TOS value in ACK messages sent from
> TIME_WAIT) fixed IPv4 only.
> 
> This part is for the IPv6 side, adding a tclass param to ip6_xmit()
> 
> We alias tw_tclass and tw_tos, if socket family is INET6.
> 
> [ if sockets is ipv4-mapped, only IP_TOS socket option is used to fill
> TOS field, TCLASS is not taken into account ]
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks!
