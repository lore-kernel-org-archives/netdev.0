From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v10 1/1] net: phy: Cleanup the Edge-Rate feature
 in Microsemi PHYs.
Date: Tue, 11 Oct 2016 15:09:00 +0200
Message-ID: <20161011130900.GE11534@lunn.ch>
References: <1476108825-14613-1-git-send-email-allan.nielsen@microsemi.com>
 <1476108825-14613-2-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
        raju.lakkaraju@microsemi.com
To: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43147 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753501AbcJKNJD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Oct 2016 09:09:03 -0400
Content-Disposition: inline
In-Reply-To: <1476108825-14613-2-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 10, 2016 at 04:13:45PM +0200, Allan W. Nielsen wrote:
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

Hi Raju, Allan

Thanks for keeping at this.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
