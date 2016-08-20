From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: ipv4: fix sparse error in fib_good_nh()
Date: Fri, 19 Aug 2016 17:08:43 -0700 (PDT)
Message-ID: <20160819.170843.753011305283852425.davem@davemloft.net>
References: <1471540774.29842.76.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55968 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755815AbcHTAIo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 20:08:44 -0400
In-Reply-To: <1471540774.29842.76.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 18 Aug 2016 10:19:34 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Fixes following sparse errors :
> 
> net/ipv4/fib_semantics.c:1579:61: warning: incorrect type in argument 2
> (different base types)
> net/ipv4/fib_semantics.c:1579:61:    expected unsigned int [unsigned]
> [usertype] key
> net/ipv4/fib_semantics.c:1579:61:    got restricted __be32 const
> [usertype] nh_gw
> 
> 
> Fixes: a6db4494d218c ("net: ipv4: Consider failed nexthops in multipath routes")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
