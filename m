From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix a compile error in DBGUNDO()
Date: Fri, 23 Sep 2016 08:27:15 -0400 (EDT)
Message-ID: <20160923.082715.1450483434821240471.davem@davemloft.net>
References: <1474592040.28155.15.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52082 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758823AbcIWM1S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 08:27:18 -0400
In-Reply-To: <1474592040.28155.15.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 22 Sep 2016 17:54:00 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> If DBGUNDO() is enabled (FASTRETRANS_DEBUG > 1), a compile
> error will happen, since inet6_sk(sk)->daddr became sk->sk_v6_daddr
> 
> Fixes: efe4208f47f9 ("ipv6: make lookups simpler and faster")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.
