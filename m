From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v10 1/1] net: phy: Cleanup the Edge-Rate
 feature in Microsemi PHYs.
Date: Thu, 13 Oct 2016 10:01:41 -0400 (EDT)
Message-ID: <20161013.100141.1588302672560551253.davem@davemloft.net>
References: <1476108825-14613-1-git-send-email-allan.nielsen@microsemi.com>
        <1476108825-14613-2-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch, f.fainelli@gmail.com,
        raju.lakkaraju@microsemi.com
To: allan.nielsen@microsemi.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:32914 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932461AbcJMOHx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 10:07:53 -0400
In-Reply-To: <1476108825-14613-2-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Date: Mon, 10 Oct 2016 16:13:45 +0200

> Edge-Rate cleanup include the following:
> - Updated device tree bindings documentation for edge-rate
> - The edge-rate is now specified as a "slowdown", meaning that it is now
>   being specified as positive values instead of negative (both
>   documentation and implementation wise).
> - Only explicitly documented values for "vsc8531,vddmac" and
>   "vsc8531,edge-slowdown" are accepted by the device driver.
> - Deleted include/dt-bindings/net/mscc-phy-vsc8531.h as it was not needed.
> - Read/validate devicetree settings in probe instead of init
> 
> Signed-off-by: Allan W. Nielsen <allan.nielsen@microsemi.com>
> Signed-off-by: Raju Lakkaraju <raju.lakkaraju@microsemi.com>

This doesn't apply cleanly to net-next, please respin.

Thanks.
