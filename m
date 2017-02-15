From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: tcp_probe: use spin_lock_bh()
Date: Tue, 14 Feb 2017 22:21:06 -0500 (EST)
Message-ID: <20170214.222106.759474350285723219.davem@davemloft.net>
References: <20170214.144648.771654199689384203.davem@davemloft.net>
        <CAMyjOU+1CAC-VLL0JBABnbzWGZPLncqy6jXWQpVkd6vnXi-3pA@mail.gmail.com>
        <1487121074.8227.71.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rnsanchez@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48910 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751429AbdBODVn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 22:21:43 -0500
In-Reply-To: <1487121074.8227.71.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 14 Feb 2017 17:11:14 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> tcp_rcv_established() can now run in process context.
> 
> We need to disable BH while acquiring tcp probe spinlock,
> or risk a deadlock.
> 
> Fixes: 5413d1babe8f ("net: do not block BH while processing socket backlog")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Ricardo Nabinger Sanchez <rnsanchez@gmail.com>

Patch applied, thanks Eric.
