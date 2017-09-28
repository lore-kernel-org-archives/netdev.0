From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] inetpeer: fix RCU lookup() again
Date: Thu, 28 Sep 2017 09:40:15 -0700 (PDT)
Message-ID: <20170928.094015.241020246197384618.davem@davemloft.net>
References: <1506354002.6617.10.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48458 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751590AbdI1QkQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 12:40:16 -0400
In-Reply-To: <1506354002.6617.10.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 25 Sep 2017 08:40:02 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> My prior fix was not complete, as we were dereferencing a pointer
> three times per node, not twice as I initially thought.
> 
> Fixes: 4cc5b44b29a9 ("inetpeer: fix RCU lookup()")
> Fixes: b145425f269a ("inetpeer: remove AVL implementation in favor of RB tree")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
