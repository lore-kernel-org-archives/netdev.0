From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: 16 slots in initial fib_info hash table
Date: Mon, 22 Oct 2012 15:11:49 -0400 (EDT)
Message-ID: <20121022.151149.1484294300015203756.davem@davemloft.net>
References: <1350886329.8609.276.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32829 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752162Ab2JVTLv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 15:11:51 -0400
In-Reply-To: <1350886329.8609.276.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 22 Oct 2012 08:12:09 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> A small host typically needs ~10 fib_info structures, so create initial
> hash table with 16 slots instead of only one. This removes potential
> false sharing and reallocs/rehashes (1->2->4->8->16)
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
