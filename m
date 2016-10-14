From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Need help with mdiobus_register and phy
Date: Fri, 14 Oct 2016 14:49:28 +0200
Message-ID: <20161014124928.GJ5822@lunn.ch>
References: <5800159B.3080708@codeaurora.org>
 <20161014040641.GE5822@lunn.ch>
 <5800C3C7.60705@codeaurora.org>
 <20161014120624.GG5822@lunn.ch>
 <5800D214.70808@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Timur Tabi <timur@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45396 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752447AbcJNMuJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 14 Oct 2016 08:50:09 -0400
Content-Disposition: inline
In-Reply-To: <5800D214.70808@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> It's the at803x driver.

The at803x_resume() just does normal MDIO transactions. Which suggests
the MDIO bus side of the device is still away. Or at least, the
MII_BMCR register is.

So are you seeing that the reads to MII_PHYSID1 and MII_PHYSID2 return
0xffff, when called from get_phy_id()?

	Andrew
