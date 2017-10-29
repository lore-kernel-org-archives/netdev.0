From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: prevent user from adding cached routes
Date: Sun, 29 Oct 2017 12:19:54 +0900 (KST)
Message-ID: <20171029.121954.2114628342717563035.davem@davemloft.net>
References: <20171028003012.15609-1-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, kafai@fb.com
To: weiwan@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44170 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751676AbdJ2DT6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 23:19:58 -0400
In-Reply-To: <20171028003012.15609-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>
Date: Fri, 27 Oct 2017 17:30:12 -0700

> From: Wei Wang <weiwan@google.com>
> 
> Cached routes should only be created by the system when receiving pmtu
> discovery or ip redirect msg. Users should not be allowed to create
> cached routes.
> 
> Furthermore, after the patch series to move cached routes into exception
> table, user added cached routes will trigger the following warning in
> fib6_add():
 ...
> So we fix this by failing the attemp to add cached routes from userspace
> with returning EINVAL error.
> 
> Fixes: 2b760fcf5cfb ("ipv6: hook up exception table to store dst cache")
> Signed-off-by: Wei Wang <weiwan@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thank you.
