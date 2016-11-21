From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] net: l2tp: Treat NET_XMIT_CN as success in
 l2tp_eth_dev_xmit
Date: Mon, 21 Nov 2016 13:11:03 -0500 (EST)
Message-ID: <20161121.131103.949173064233453874.davem@davemloft.net>
References: <1479689781-2125-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, javier@osg.samsung.com,
        netdev@vger.kernel.org, gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55406 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753195AbcKUSLH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 13:11:07 -0500
In-Reply-To: <1479689781-2125-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fgao@ikuai8.com
Date: Mon, 21 Nov 2016 08:56:21 +0800

> From: Gao Feng <gfree.wind@gmail.com>
> 
> The tc could return NET_XMIT_CN as one congestion notification, but
> it does not mean the packe is lost. Other modules like ipvlan,
> macvlan, and others treat NET_XMIT_CN as success too.
> So l2tp_eth_dev_xmit should add the NET_XMIT_CN check.
> 
> Signed-off-by: Gao Feng <gfree.wind@gmail.com>

Applied.
