From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mlx4: reorganize struct mlx4_en_tx_ring
Date: Thu, 24 Nov 2016 16:04:13 -0500 (EST)
Message-ID: <20161124.160413.361550700742982089.davem@davemloft.net>
References: <1479858970.8455.461.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tariqt@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41706 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965980AbcKXVEP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 16:04:15 -0500
In-Reply-To: <1479858970.8455.461.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 22 Nov 2016 15:56:10 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Goal is to reorganize this critical structure to increase performance.
> 
> ndo_start_xmit() should only dirty one cache line, and access as few
> cache lines as possible.
> 
> Add sp_ (Slow Path) prefix to fields that are not used in fast path,
> to make clear what is going on.
> 
> After this patch pahole reports something much better, as all
> ndo_start_xmit() needed fields are packed into two cache lines instead
> of seven or eight
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
