From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] af_key: do not use GFP_KERNEL in atomic contexts
Date: Mon, 14 Aug 2017 22:19:31 -0700 (PDT)
Message-ID: <20170814.221931.431071335638269294.davem@davemloft.net>
References: <1502731005.4936.29.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50524 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753100AbdHOFTc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 01:19:32 -0400
In-Reply-To: <1502731005.4936.29.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 14 Aug 2017 10:16:45 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> pfkey_broadcast() might be called from non process contexts,
> we can not use GFP_KERNEL in these cases [1].
> 
> This patch partially reverts commit ba51b6be38c1 ("net: Fix RCU splat in
> af_key"), only keeping the GFP_ATOMIC forcing under rcu_read_lock()
> section.
> 
> [1] : syzkaller reported :
 ...
> Fixes: ba51b6be38c1 ("net: Fix RCU splat in af_key")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>

Applied and queued up for -stable, thanks.
