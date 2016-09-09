From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next 2/2] net: phy: Add MAC-IF driver for
 Microsemi PHYs.
Date: Fri, 9 Sep 2016 14:03:46 +0200
Message-ID: <20160909120346.GA30871@lunn.ch>
References: <20160824125934.GC13406@lunn.ch>
 <1473326242-4198-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <1473326242-4198-3-git-send-email-Raju.Lakkaraju@microsemi.com>
 <20160908132727.GH26445@lunn.ch>
 <20160909055351.GB26767@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
        Allan.Nielsen@microsemi.com
To: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:39887 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752827AbcIIMDu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Sep 2016 08:03:50 -0400
Content-Disposition: inline
In-Reply-To: <20160909055351.GB26767@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 09, 2016 at 11:23:52AM +0530, Raju Lakkaraju wrote:
> Hi Andrew,
> 
> Thank you for review the code and valuable comments.
> 
> On Thu, Sep 08, 2016 at 03:27:27PM +0200, Andrew Lunn wrote:
> > EXTERNAL EMAIL
> > 
> > 
> > On Thu, Sep 08, 2016 at 02:47:22PM +0530, Raju Lakkaraju wrote:
> > > From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> > >
> > > Used Device Tree to configure the MAC Interface as per review comments and
> > > re-sending code for review
> > 
> > I don't see anything about device tree in this patch...
> > 
> Ethernet driver (in my BBB environment, TI cpsw driver) read the device tree 
> phy interface parameter and update in phydev structure.
> 
> In device tree the following code holds the phy interface configuration.
> &cpsw_emac0 {
>         phy_id = <&davinci_mdio>, <0>;
>         phy-mode = "rgmii";
> };

O.K, that is one place it can come from. But it is not the only,
e.g. platform data or ACPI. A better comment might be:

Configure the MAC/PHY interface as indicated in phydev->interface,
eg. GMII, RMII, RGMII.

    Andrew
