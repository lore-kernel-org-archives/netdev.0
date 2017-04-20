From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2] net: arc_emac: switch to phy_start()/phy_stop()
Date: Thu, 20 Apr 2017 10:11:15 -0700
Message-ID: <19bf7cd3-e83c-62bf-3b01-f574811a9e65@gmail.com>
References: <1492694974-31023-1-git-send-email-al.kochet@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Alexander Kochetkov <al.kochet@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Philippe Reynes <tremyfr@gmail.com>,
        Peter Chen <peter.chen@nxp.com>,
        Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:34588 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S971442AbdDTRLX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 13:11:23 -0400
In-Reply-To: <1492694974-31023-1-git-send-email-al.kochet@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/20/2017 06:29 AM, Alexander Kochetkov wrote:
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

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
