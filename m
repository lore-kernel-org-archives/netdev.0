From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: remove useless pfmemalloc setting
Date: Thu, 02 Feb 2017 23:03:24 -0500 (EST)
Message-ID: <20170202.230324.936684079633234077.davem@davemloft.net>
References: <1485992285.6360.168.camel@edumazet-glaptop3.roam.corp.google.com>
        <1485993427.6360.170.camel@edumazet-glaptop3.roam.corp.google.com>
        <1486001603.13103.10.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbacik@fb.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40374 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752280AbdBCED0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 23:03:26 -0500
In-Reply-To: <1486001603.13103.10.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 01 Feb 2017 18:13:23 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> When __alloc_skb() allocates an skb from fast clone cache,
> setting pfmemalloc on the clone is not needed.
> 
> Clone will be properly initialized later at skb_clone() time,
> including pfmemalloc field, as it is included in the
> headers_start/headers_end section which is fully copied.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
