From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: fix NULL dereference in
 ip6_route_dev_notify()
Date: Tue, 15 Aug 2017 17:06:54 -0700 (PDT)
Message-ID: <20170815.170654.981410365504343461.davem@davemloft.net>
References: <1502795391.4936.60.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43884 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751095AbdHPAGy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 20:06:54 -0400
In-Reply-To: <1502795391.4936.60.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 15 Aug 2017 04:09:51 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Based on a syzkaller report [1], I found that a per cpu allocation
> failure in snmp6_alloc_dev() would then lead to NULL dereference in
> ip6_route_dev_notify().
> 
> It seems this is a very old bug, thus no Fixes tag in this submission.
> 
> Let's add in6_dev_put_clear() helper, as we will probably use
> it elsewhere (once available/present in net-next)
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>

Applied and queued up for -stable, thanks Eric.
