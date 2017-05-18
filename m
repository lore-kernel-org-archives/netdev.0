From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: fix __skb_try_recv_from_queue to
 return the old behavior
Date: Thu, 18 May 2017 10:33:19 -0400 (EDT)
Message-ID: <20170518.103319.1210941190107364339.davem@davemloft.net>
References: <1495011889.2644.5.camel@redhat.com>
        <20170517183905.10971-1-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pabeni@redhat.com, edumazet@google.com
To: avagin@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43536 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755400AbdEROdU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 10:33:20 -0400
In-Reply-To: <20170517183905.10971-1-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrei Vagin <avagin@openvz.org>
Date: Wed, 17 May 2017 11:39:05 -0700

> This function has to return NULL on a error case, because there is a
> separate error variable.
> 
> The offset has to be changed only if skb is returned
> 
> v2: fix udp code to not use an extra variable
> 
> Cc: Paolo Abeni <pabeni@redhat.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: David S. Miller <davem@davemloft.net>
> Fixes: 65101aeca522 ("net/sock: factor out dequeue/peek with offset cod")
> Signed-off-by: Andrei Vagin <avagin@openvz.org>

Applied.
