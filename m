From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] net: remove MTU limits for dummy and ifb device
Date: Mon, 25 Sep 2017 16:26:19 -0700 (PDT)
Message-ID: <20170925.162619.1038803923818046972.davem@davemloft.net>
References: <1506095869-5465-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sd@queasysnail.net, edumazet@google.com, netdev@vger.kernel.org
To: zhangshengju@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35152 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966079AbdIYX0U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 19:26:20 -0400
In-Reply-To: <1506095869-5465-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Date: Fri, 22 Sep 2017 23:57:49 +0800

> These two drivers (dummy and ifb) call ether_setup(), after commit
> 61e84623ace3 ("net: centralize net_device min/max MTU checking"), the
> range of mtu is [min_mtu, max_mtu], which is [68, 1500] by default.
> 
> These two devices should not have limits on MTU. This patch set their
> min_mtu/max_mtu to 0. So that dev_set_mtu() will not check the mtu range,
> and can be set with any value.
> 
> CC: Eric Dumazet <edumazet@google.com>
> CC: Sabrina Dubroca <sd@queasysnail.net>
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>

Applied.
