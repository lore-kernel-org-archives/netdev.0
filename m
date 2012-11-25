From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: ipmr: various fixes and cleanups
Date: Sun, 25 Nov 2012 16:40:23 -0500 (EST)
Message-ID: <20121125.164023.2066404892904383568.davem@davemloft.net>
References: <1353861705.30446.675.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40894 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753455Ab2KYVk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Nov 2012 16:40:29 -0500
In-Reply-To: <1353861705.30446.675.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 25 Nov 2012 08:41:45 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> 1) ip_mroute_setsockopt() & ip_mroute_getsockopt() should not
>    access/set raw_sk(sk)->ipmr_table before making sure the socket
>    is a raw socket, and protocol is IGMP
> 
> 2) MRT_INIT should return -EINVAL if optlen != sizeof(int), not
>    -ENOPROTOOPT
> 
> 3) MRT_ASSERT & MRT_PIM should validate optlen
> 
> 4) " (v) ? 1 : 0 " can be written as " !!v "
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
