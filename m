From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: arc_emac: switch to phy_start()/phy_stop()
Date: Fri, 21 Apr 2017 15:24:09 -0400 (EDT)
Message-ID: <20170421.152409.337926359354412729.davem@davemloft.net>
References: <1492694974-31023-1-git-send-email-al.kochet@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tremyfr@gmail.com, peter.chen@nxp.com, weiyongjun1@huawei.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: al.kochet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37278 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1424850AbdDUTYL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 15:24:11 -0400
In-Reply-To: <1492694974-31023-1-git-send-email-al.kochet@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Kochetkov <al.kochet@gmail.com>
Date: Thu, 20 Apr 2017 16:29:34 +0300

> Currently driver use phy_start_aneg() in arc_emac_open() to bring
> up PHY. But phy_start() function is more appropriate for this purposes.
> Besides that it call phy_start_aneg() as part of PHY startup sequence
> it also can correctly bring up PHY from error and suspended states.
> So the patch replace phy_start_aneg() to phy_start().
> 
> Also the patch add call to phy_stop() to arc_emac_stop() to allow
> the PHY device to be fully suspended when the interface is unused.
> 
> Signed-off-by: Alexander Kochetkov <al.kochet@gmail.com>

Applied to net-next, thanks.
