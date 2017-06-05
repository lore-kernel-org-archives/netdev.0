From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 3/6] net: phy: hook up clause 45 autonegotiation restart
Date: Mon, 5 Jun 2017 13:59:10 +0200
Message-ID: <20170605115910.GB28734@lunn.ch>
References: <20170605112203.GA10680@n2100.armlinux.org.uk>
 <E1dHq68-0005Wy-Na@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Russell King <rmk+kernel@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36497 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751293AbdFEL7L (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Jun 2017 07:59:11 -0400
Content-Disposition: inline
In-Reply-To: <E1dHq68-0005Wy-Na@rmk-PC.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 05, 2017 at 12:23:00PM +0100, Russell King wrote:
> genphy_restart_aneg() can only restart autonegotiation on clause 22
> PHYs.  Add a phy_restart_aneg() function which selects between the
> clause 22 and clause 45 restart functionality depending on the PHY
> type and whether the Clause 45 PHY supports the Clause 22 register set.
> 
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
