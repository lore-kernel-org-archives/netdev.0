From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: defer sacked assignment
Date: Thu, 18 Aug 2016 23:27:54 -0700 (PDT)
Message-ID: <20160818.232754.1763766189050385307.davem@davemloft.net>
References: <1471445316.4943.40.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42396 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752380AbcHSG1z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 02:27:55 -0400
In-Reply-To: <1471445316.4943.40.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 17 Aug 2016 07:48:36 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> While chasing tcp_xmit_retransmit_queue() kasan issue, I found
> that we could avoid reading sacked field of skb that we wont send,
> possibly removing one cache line miss.
> 
> Very minor change in slow path, but why not ? ;) 
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
