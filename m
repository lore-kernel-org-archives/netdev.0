From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] virtio_net: be drop monitor friend
Date: Thu, 24 Aug 2017 12:34:30 -0700
Message-ID: <1503603270.2499.82.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1503590569.2499.81.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170824.115053.1345828961956619603.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, jasowang@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:38219 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753803AbdHXTec (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 15:34:32 -0400
Received: by mail-pg0-f43.google.com with SMTP id b8so2245574pgn.5
        for <netdev@vger.kernel.org>; Thu, 24 Aug 2017 12:34:32 -0700 (PDT)
In-Reply-To: <20170824.115053.1345828961956619603.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-08-24 at 11:50 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 24 Aug 2017 09:02:49 -0700
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > This change is needed to not fool drop monitor.
> > (perf record ... -e skb:kfree_skb )
> > 
> > Packets were properly sent and are consumed after TX completion.
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> I'm pretty sure you meant "friendly" in the Subject line so I fixed
> it up to say that :-)
> 
> Applied, thanks.

Ah, great, thanks for fixing this ;)
