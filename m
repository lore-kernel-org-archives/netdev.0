From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: use page_ref_inc() in tcp_sendmsg()
Date: Fri, 17 Feb 2017 15:31:24 -0500 (EST)
Message-ID: <20170217.153124.658361697603050368.davem@davemloft.net>
References: <1487351502.1311.84.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48570 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935004AbdBQUh0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 15:37:26 -0500
In-Reply-To: <1487351502.1311.84.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 17 Feb 2017 09:11:42 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> sk_page_frag_refill() allocates either a compound page or an order-0
> page. We can use page_ref_inc() which is slightly faster than get_page()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
