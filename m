From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] driver: ipvlan: Remove useless member
 mtu_adj of struct ipvl_dev
Date: Wed, 30 Nov 2016 15:02:11 -0500 (EST)
Message-ID: <20161130.150211.1130717424873353750.davem@davemloft.net>
References: <1480466924-2436-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maheshb@google.com, edumazet@google.com, netdev@vger.kernel.org,
        gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41476 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755154AbcK3UCN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 15:02:13 -0500
In-Reply-To: <1480466924-2436-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fgao@ikuai8.com
Date: Wed, 30 Nov 2016 08:48:44 +0800

> From: Gao Feng <fgao@ikuai8.com>
> 
> The mtu_adj is initialized to zero when alloc mem, there is no any
> assignment to mtu_adj. It is only used in ipvlan_adjust_mtu as one
> right value.
> So it is useless member of struct ipvl_dev, then remove it.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>

Applied, thank you.
