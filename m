From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] inetpeer: fix RCU lookup()
Date: Fri, 01 Sep 2017 17:33:49 -0700 (PDT)
Message-ID: <20170901.173349.1060795224955256278.davem@davemloft.net>
References: <1504299812.15310.26.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55736 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752622AbdIBAdy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 20:33:54 -0400
In-Reply-To: <1504299812.15310.26.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 01 Sep 2017 14:03:32 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Excess of seafood or something happened while I cooked the commit
> adding RB tree to inetpeer.
> 
> Of course, RCU rules need to be respected or bad things can happen.
> 
> In this particular loop, we need to read *pp once per iteration, not
> twice.
> 
> Fixes: b145425f269a ("inetpeer: remove AVL implementation in favor of RB tree")
> Reported-by: John Sperbeck <jsperbeck@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Cheers for excess seafood :-)

Applied.
