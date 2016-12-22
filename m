From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: ipv4: Don't crash if passing a null sk to
 ip_do_redirect.
Date: Thu, 22 Dec 2016 11:13:56 -0500 (EST)
Message-ID: <20161222.111356.512268808563371509.davem@davemloft.net>
References: <1482420837-30324-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46582 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756986AbcLVQN7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2016 11:13:59 -0500
In-Reply-To: <1482420837-30324-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Fri, 23 Dec 2016 00:33:57 +0900

> Commit e2d118a1cb5e ("net: inet: Support UID-based routing in IP
> protocols.") made ip_do_redirect call sock_net(sk) to determine
> the network namespace of the passed-in socket. This crashes if sk
> is NULL.
> 
> Fix this by getting the network namespace from the skb instead.
> 
> Fixes: e2d118a1cb5e ("net: inet: Support UID-based routing in IP protocols.")
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>

Applied, thanks Lorenzo.
