From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net_sched: sch_fq: use hash_ptr()
Date: Thu, 17 Nov 2016 13:29:29 -0500 (EST)
Message-ID: <20161117.132929.1483259003226796827.davem@davemloft.net>
References: <1479404910.8455.269.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hughd@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40938 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752500AbcKQS3a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 13:29:30 -0500
In-Reply-To: <1479404910.8455.269.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 17 Nov 2016 09:48:30 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> When I wrote sch_fq.c, hash_ptr() on 64bit arches was awful,
> and I chose hash_32().
> 
> Linus Torvalds and George Spelvin fixed this issue, so we can
> use hash_ptr() to get more entropy on 64bit arches with Terabytes
> of memory, and avoid the cast games.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Hugh Dickins <hughd@google.com>

Applied, thanks Eric.
