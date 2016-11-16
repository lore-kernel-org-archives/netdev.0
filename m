From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] virtio-net: add a missing synchronize_net()
Date: Wed, 16 Nov 2016 15:12:14 -0500 (EST)
Message-ID: <20161116.151214.1324945416632519254.davem@davemloft.net>
References: <1479277452.8455.156.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jasowang@redhat.com, mst@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50078 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752375AbcKPUM1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 15:12:27 -0500
In-Reply-To: <1479277452.8455.156.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 15 Nov 2016 22:24:12 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> It seems many drivers do not respect napi_hash_del() contract.
> 
> When napi_hash_del() is used before netif_napi_del(), an RCU grace
> period is needed before freeing NAPI object.
> 
> Fixes: 91815639d880 ("virtio-net: rx busy polling support")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks Eric.
