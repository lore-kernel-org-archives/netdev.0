From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6/addrconf: speedup /proc/net/if_inet6 filling
Date: Wed, 04 Jan 2012 16:01:15 -0500 (EST)
Message-ID: <20120104.160115.1628594967715806849.davem@davemloft.net>
References: <1325669495-5626-1-git-send-email-mmaruseac@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	mmaruseac@ixiacom.com, dbaluta@ixiacom.com
To: mihai.maruseac@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52786 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756825Ab2ADVEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2012 16:04:10 -0500
In-Reply-To: <1325669495-5626-1-git-send-email-mmaruseac@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mihai Maruseac <mihai.maruseac@gmail.com>
Date: Wed,  4 Jan 2012 11:31:35 +0200

> This ensures a linear behaviour when filling /proc/net/if_inet6 thus making
> ifconfig run really fast on IPv6 only addresses. In fact, with this patch and
> the IPv4 one sent a while ago, ifconfig will run in linear time regardless of
> address type.
> 
> IPv4 related patch: f04565ddf52e401880f8ba51de0dff8ba51c99fd
> 	 dev: use name hash for dev_seq_ops
> 	 ...
> 
> Some statistics (running ifconfig > /dev/null on a different setup):
> 
> iface count / IPv6 no-patch time / IPv6 patched time / IPv4 time
> ----------------------------------------------------------------
>       6250  |       0.23 s       |      0.13 s       |  0.11 s
>      12500  |       0.62 s       |      0.28 s       |  0.22 s
>      25000  |       2.91 s       |      0.57 s       |  0.46 s
>      50000  |      11.37 s       |      1.21 s       |  0.94 s
>     128000  |      86.78 s       |      3.05 s       |  2.54 s
> 
> Signed-off-by: Mihai Maruseac <mmaruseac@ixiacom.com>
> Cc: Daniel Baluta <dbaluta@ixiacom.com>

Applied, thanks.
