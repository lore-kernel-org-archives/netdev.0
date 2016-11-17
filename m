From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net/mlx5e: remove napi_hash_del() calls
Date: Thu, 17 Nov 2016 12:06:57 -0500 (EST)
Message-ID: <20161117.120657.736403141939977185.davem@davemloft.net>
References: <1479304537.8455.167.camel@edumazet-glaptop3.roam.corp.google.com>
        <1479306094.8455.181.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm@mellanox.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39856 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932954AbcKQRG7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 12:06:59 -0500
In-Reply-To: <1479306094.8455.181.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 16 Nov 2016 06:21:34 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Calling napi_hash_del() after netif_napi_del() is pointless.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
