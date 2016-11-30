From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv4: Don't crash if passing a null sk to
 ip_rt_update_pmtu.
Date: Wed, 30 Nov 2016 14:54:19 -0500 (EST)
Message-ID: <20161130.145419.801141163874925780.davem@davemloft.net>
References: <1480442207-43618-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, erezsh@dev.mellanox.co.il
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41090 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755215AbcK3Tyb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 14:54:31 -0500
In-Reply-To: <1480442207-43618-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Wed, 30 Nov 2016 02:56:47 +0900

> Commit e2d118a1cb5e ("net: inet: Support UID-based routing in IP
> protocols.") made __build_flow_key call sock_net(sk) to determine
> the network namespace of the passed-in socket. This crashes if sk
> is NULL.
> 
> Fix this by getting the network namespace from the skb instead.
> 
> Reported-by: Erez Shitrit <erezsh@dev.mellanox.co.il>
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>

Applied, thanks.
