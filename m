From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: fix typo in fib6_net_exit()
Date: Fri, 08 Sep 2017 16:09:27 -0700 (PDT)
Message-ID: <20170908.160927.1991574183822549972.davem@davemloft.net>
References: <204659713af1979c26b8defb2b52e1668b4e5aad.1504859062.git.sd@queasysnail.net>
        <1504893592.15310.80.camel@edumazet-glaptop3.roam.corp.google.com>
        <1504910927.15310.105.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sd@queasysnail.net, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37802 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753166AbdIHXJ2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 19:09:28 -0400
In-Reply-To: <1504910927.15310.105.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 08 Sep 2017 15:48:47 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> IPv6 FIB should use FIB6_TABLE_HASHSZ, not FIB_TABLE_HASHSZ.
> 
> Fixes: ba1cc08d9488 ("ipv6: fix memory leak with multiple tables during netns destruction")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
