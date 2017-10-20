From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net-tun: fix panics at dismantle time
Date: Fri, 20 Oct 2017 13:31:58 +0100 (WEST)
Message-ID: <20171020.133158.705220443401891435.davem@davemloft.net>
References: <1508353929.31614.136.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peterpenkov96@gmail.com, maheshb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37506 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751624AbdJTMcD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 08:32:03 -0400
In-Reply-To: <1508353929.31614.136.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 18 Oct 2017 12:12:09 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> syzkaller got crashes at dismantle time [1]
> 
> It is not correct to test (tun->flags & IFF_NAPI) in tun_napi_disable()
> and tun_napi_del() : Each tun_file can have different mode, depending
> on how they were created.
> 
> Similarly I have changed tun_get_user() and tun_poll_controller()
> to use the new tfile->napi_enabled boolean.
 ...
> Fixes: 943170998b20 ("net-tun: enable NAPI for TUN/TAP driver")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
