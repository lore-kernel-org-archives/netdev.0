From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: Re: [PATCH net-next v2] ethtool: Protect {get,set}_phy_tunable with
 PHY device mutex
Date: Thu, 24 Nov 2016 12:48:10 +0100
Message-ID: <20161124114809.GG4457@microsemi.com>
References: <20161122215531.18212-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
        <bcm-kernel-feedback-list@broadcom.com>, <andrew@lunn.ch>,
        <raju.lakkaraju@microsemi.com>,
        <vivien.didelot@savoirfairelinux.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0071.outbound.protection.outlook.com ([104.47.38.71]:17680
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S965060AbcKXLsX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Nov 2016 06:48:23 -0500
Content-Disposition: inline
In-Reply-To: <20161122215531.18212-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/11/16 13:55, Florian Fainelli wrote:
> EXTERNAL EMAIL
> 
> 
> PHY drivers should be able to rely on the caller of {get,set}_tunable to
> have acquired the PHY device mutex, in order to both serialize against
> concurrent calls of these functions, but also against PHY state machine
> changes. All ethtool PHY-level functions do this, except
> {get,set}_tunable, so we make them consistent here as well.
> 
> We need to update the Microsemi PHY driver in the same commit to avoid
> introducing either deadlocks, or lack of proper locking.
> 
> Fixes: 968ad9da7e0e ("ethtool: Implements ETHTOOL_PHY_GTUNABLE/ETHTOOL_PHY_STUNABLE")
> Fixes: 310d9ad57ae0 ("net: phy: Add downshift get/set support in Microsemi PHYs driver")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
Reviewed-by: Allan W. Nielsen <allan.nielsen@microsemi.com>
