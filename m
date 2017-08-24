From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] virtio_net: be drop monitor friend
Date: Thu, 24 Aug 2017 11:50:53 -0700 (PDT)
Message-ID: <20170824.115053.1345828961956619603.davem@davemloft.net>
References: <1503590569.2499.81.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, jasowang@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49964 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753474AbdHXSux (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 14:50:53 -0400
In-Reply-To: <1503590569.2499.81.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 24 Aug 2017 09:02:49 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> This change is needed to not fool drop monitor.
> (perf record ... -e skb:kfree_skb )
> 
> Packets were properly sent and are consumed after TX completion.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

I'm pretty sure you meant "friendly" in the Subject line so I fixed
it up to say that :-)

Applied, thanks.
