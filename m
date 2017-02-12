From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net_sched: fix error recovery at qdisc
 creation
Date: Sat, 11 Feb 2017 21:39:23 -0500 (EST)
Message-ID: <20170211.213923.229808067383794475.davem@davemloft.net>
References: <1486751509.7793.162.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44692 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751076AbdBLCjZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Feb 2017 21:39:25 -0500
In-Reply-To: <1486751509.7793.162.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 10 Feb 2017 10:31:49 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Dmitry reported uses after free in qdisc code [1]
> 
> The problem here is that ops->init() can return an error.
> 
> qdisc_create_dflt() then call ops->destroy(),
> while qdisc_create() does _not_ call it.
> 
> Four qdisc chose to call their own ops->destroy(), assuming their caller
> would not.
> 
> This patch makes sure qdisc_create() calls ops->destroy()
> and fixes the four qdisc to avoid double free.
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>

Applied, thanks Eric.
