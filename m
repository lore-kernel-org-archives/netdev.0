From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: dsa: use consume_skb()
Date: Wed, 23 Aug 2017 22:14:09 -0700 (PDT)
Message-ID: <20170823.221409.491043070928113860.davem@davemloft.net>
References: <20170822221215.16305-1-f.fainelli@gmail.com>
        <20170823.203725.2147193612476095021.davem@davemloft.net>
        <1503549632.2499.77.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        vivien.didelot@savoirfairelinux.com, Woojung.Huh@microchip.com,
        UNGLinuxDriver@microchip.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60342 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750806AbdHXFOM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 01:14:12 -0400
In-Reply-To: <1503549632.2499.77.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 23 Aug 2017 21:40:32 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Two kfree_skb() should be consume_skb(), to be friend with drop monitor
> (perf record ... -e skb:kfree_skb)
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
