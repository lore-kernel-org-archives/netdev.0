From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: Introduce IN_DEV_NET_ROUTE_LOCALNET
Date: Sat, 04 Aug 2012 01:28:17 -0700 (PDT)
Message-ID: <20120804.012817.197969934709246517.davem@davemloft.net>
References: <1344065245.9299.1477.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43902 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753516Ab2HDI2S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Aug 2012 04:28:18 -0400
In-Reply-To: <1344065245.9299.1477.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 04 Aug 2012 09:27:25 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> performance profiles show a high cost in the IN_DEV_ROUTE_LOCALNET()
> call done in ip_route_input_slow(), because of multiple dereferences,
> even if cache lines are clean and available in cpu caches.
> 
> Since we already have the 'net' pointer, introduce
> IN_DEV_NET_ROUTE_LOCALNET() macro avoiding two dereferences
> (dev_net(in_dev->dev))
> 
> Also change the tests to use IN_DEV_NET_ROUTE_LOCALNET() only if saddr
> or/and daddr are loopback addresse.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
