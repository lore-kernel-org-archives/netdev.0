From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2] ethtool: Protect {get,set}_phy_tunable with
 PHY device mutex
Date: Wed, 23 Nov 2016 23:43:05 +0100
Message-ID: <20161123224305.GF12343@lunn.ch>
References: <20161122215531.18212-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        bcm-kernel-feedback-list@broadcom.com, allan.nielsen@microsemi.com,
        raju.lakkaraju@microsemi.com, vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53163 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934383AbcKWWnJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Nov 2016 17:43:09 -0500
Content-Disposition: inline
In-Reply-To: <20161122215531.18212-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 22, 2016 at 01:55:31PM -0800, Florian Fainelli wrote:
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

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
