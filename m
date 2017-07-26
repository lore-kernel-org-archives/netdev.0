From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 03/13] net: phy: move phy_lookup_setting() and guts
 of phy_supported_speeds() to phy-core
Date: Thu, 27 Jul 2017 00:21:30 +0200
Message-ID: <20170726222130.GD7966@lunn.ch>
References: <20170725140138.GK31807@n2100.armlinux.org.uk>
 <E1da0QB-0007L2-Rk@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Russell King <rmk+kernel@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41550 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751141AbdGZWVc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 18:21:32 -0400
Content-Disposition: inline
In-Reply-To: <E1da0QB-0007L2-Rk@rmk-PC.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 25, 2017 at 03:02:47PM +0100, Russell King wrote:
> phy_lookup_setting() provides useful functionality in ethtool code
> outside phylib.  Move it to phy-core and allow it to be re-used (eg,
> in phylink) rather than duplicated elsewhere.  Note that this supports
> the larger linkmode space.
> 
> As we move the phy settings table, we also need to move the guts of
> phy_supported_speeds() as well.
> 
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
