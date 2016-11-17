From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/mlx4_en: remove napi_hash_del() call
Date: Thu, 17 Nov 2016 11:17:37 -0500 (EST)
Message-ID: <20161117.111737.2006621470541369678.davem@davemloft.net>
References: <1479304162.8455.163.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tariqt@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39654 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752275AbcKQQ47 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 11:56:59 -0500
In-Reply-To: <1479304162.8455.163.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 16 Nov 2016 05:49:22 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> There is no need calling napi_hash_del()+synchronize_rcu() before
> calling netif_napi_del()
> 
> netif_napi_del() does this already.
> 
> Using napi_hash_del() in a driver is useful only when dealing with
> a batch of NAPI structures, so that a single synchronize_rcu() can
> be used. mlx4_en_deactivate_cq() is deactivating a single NAPI.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
