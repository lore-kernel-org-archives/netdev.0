From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] kcm: do not attach PF_KCM sockets to avoid deadlock
Date: Wed, 30 Aug 2017 15:55:38 -0700 (PDT)
Message-ID: <20170830.155538.944885056033122938.davem@davemloft.net>
References: <1504110571.11498.120.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@quantonium.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36148 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750814AbdH3Wzj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 18:55:39 -0400
In-Reply-To: <1504110571.11498.120.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 30 Aug 2017 09:29:31 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> syzkaller had no problem to trigger a deadlock, attaching a KCM socket
> to another one (or itself). (original syzkaller report was a very
> confusing lockdep splat during a sendmsg())
> 
> It seems KCM claims to only support TCP, but no enforcement is done,
> so we might need to add additional checks.
> 
> Fixes: ab7ac4eb9832 ("kcm: Kernel Connection Multiplexor module")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>

Applied and queued up for -stable, thanks.
