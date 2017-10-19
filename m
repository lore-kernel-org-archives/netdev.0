From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tun: relax check on eth_get_headlen() return
 value
Date: Thu, 19 Oct 2017 13:18:48 +0100 (WEST)
Message-ID: <20171019.131848.1359990254656797334.davem@davemloft.net>
References: <1508260064.31614.108.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peterpenkov96@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48864 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751320AbdJSMSx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 08:18:53 -0400
In-Reply-To: <1508260064.31614.108.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 17 Oct 2017 10:07:44 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> syzkaller hit the WARN() in tun_get_user(), providing skb
> with payload in fragments only, and nothing in skb->head
> 
> GRO layer is fine with this, so relax the check.
> 
> Fixes: 90e33d459407 ("tun: enable napi_gro_frags() for TUN/TAP driver")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
