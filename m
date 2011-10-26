From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: tcp: fix TCLASS value in ACK messages sent from
 TIME_WAIT
Date: Wed, 26 Oct 2011 15:59:08 -0400 (EDT)
Message-ID: <20111026.155908.1133603039272144196.davem@davemloft.net>
References: <1319611331.18883.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59089 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751893Ab1JZT7K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2011 15:59:10 -0400
In-Reply-To: <1319611331.18883.13.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 26 Oct 2011 08:42:11 +0200

> commit 66b13d99d96a (ipv4: tcp: fix TOS value in ACK messages sent from
> TIME_WAIT) fixed IPv4 only.
> 
> This part is for the IPv6 side.
> 
> We alias tw_tclass and tw_tos, if socket family is INET6.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.

Did you happen to check to see that this does the right thing for
V4 mapped ipv6 sockets?

Thanks.
