From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: avoid one splat in fib_nl_delrule()
Date: Mon, 03 Jul 2017 03:29:53 -0700 (PDT)
Message-ID: <20170703.032953.1023023704387239192.davem@davemloft.net>
References: <1498817290-3368-1-git-send-email-elena.reshetova@intel.com>
        <1499074136.1462.0.camel@edumazet-glaptop3.roam.corp.google.com>
        <1499075673.1462.4.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: elena.reshetova@intel.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55472 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753004AbdGCK36 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2017 06:29:58 -0400
In-Reply-To: <1499075673.1462.4.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 03 Jul 2017 02:54:33 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> We need to use refcount_set() on a newly created rule to avoid
> following error :
 ...
> Fixes: 717d1e993ad8 ("net: convert fib_rule.refcnt from atomic_t to refcount_t") 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
