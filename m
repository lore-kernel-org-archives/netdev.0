From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 2/6] net: phy: avoid genphy_aneg_done() for PHYs without
 clause 22 support
Date: Mon, 5 Jun 2017 13:58:31 +0200
Message-ID: <20170605115831.GA28734@lunn.ch>
References: <20170605112203.GA10680@n2100.armlinux.org.uk>
 <E1dHq63-0005Wr-K2@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Russell King <rmk+kernel@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36492 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751370AbdFEL6d (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Jun 2017 07:58:33 -0400
Content-Disposition: inline
In-Reply-To: <E1dHq63-0005Wr-K2@rmk-PC.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 05, 2017 at 12:22:55PM +0100, Russell King wrote:
> Avoid calling genphy_aneg_done() for PHYs that do not implement the
> Clause 22 register set.
> 
> Clause 45 PHYs may implement the Clause 22 register set along with the
> Clause 22 extension MMD.  Hence, we can't simply block access to the
> Clause 22 functions based on the PHY being a Clause 45 PHY.
> 
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
