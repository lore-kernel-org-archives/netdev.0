From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] tcp: implement rb-tree based retransmit
 queue
Date: Sat, 07 Oct 2017 00:31:34 +0100 (WEST)
Message-ID: <20171007.003134.133270352885522371.davem@davemloft.net>
References: <20171006052127.19913-1-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, ycheng@google.com, netdev@vger.kernel.org,
        eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49710 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751485AbdJFXbw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 19:31:52 -0400
In-Reply-To: <20171006052127.19913-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Thu,  5 Oct 2017 22:21:20 -0700

> This patch series implement RB-tree based retransmit queue for TCP,
> to better match modern BDP.

Indeed, there was a lot of resistence to this due to the overhead
for small retransmit queue sizes, but with today's scale this is
long overdue.

So, series applied, nice work!

Maybe we can look into dynamic schemes where when the queue never
goes over N entries we elide the rbtree and use a list.  I'm not
so sure how practical that would be.

Thanks!
