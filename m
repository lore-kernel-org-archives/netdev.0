From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mlx4: fix mlx4_en_set_rxfh()
Date: Sun, 23 Nov 2014 13:49:32 -0500 (EST)
Message-ID: <20141123.134932.1871037403219015509.davem@davemloft.net>
References: <1416692961.7215.31.camel@decadent.org.uk>
	<1416700690.20938.34.camel@edumazet-glaptop2.roam.corp.google.com>
	<1416705859.17888.7.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, netdev@vger.kernel.org, amirv@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34719 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751670AbaKWSte (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Nov 2014 13:49:34 -0500
In-Reply-To: <1416705859.17888.7.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 22 Nov 2014 17:24:19 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> mlx4_en_set_rxfh() can crash if no RSS indir table is provided.
> 
> While we are at it, allow RSS key to be changed with ethtool -X
> 
> Tested:
 ...
> Reported-by: Ben Hutchings <ben@decadent.org.uk>
> Fixes: b9d1ab7eb42e ("mlx4: use netdev_rss_key_fill() helper")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
