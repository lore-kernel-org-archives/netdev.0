From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: Re: [PATCH v2 net-next 2/2] net: phy: Add MAC-IF driver for
 Microsemi PHYs.
Date: Thu, 15 Sep 2016 15:58:33 +0530
Message-ID: <20160915102831.GB24647@microsemi.com>
References: <20160824125934.GC13406@lunn.ch>
 <1473326242-4198-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <1473326242-4198-3-git-send-email-Raju.Lakkaraju@microsemi.com>
 <20160908132727.GH26445@lunn.ch>
 <20160909055351.GB26767@microsemi.com>
 <20160909120346.GA30871@lunn.ch>
Reply-To: <Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <f.fainelli@gmail.com>,
        <Allan.Nielsen@microsemi.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0067.outbound.protection.outlook.com ([104.47.32.67]:24384
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933241AbcIOLAm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Sep 2016 07:00:42 -0400
Content-Disposition: inline
In-Reply-To: <20160909120346.GA30871@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Thank you for review the code.
I accepted all your review comments.
I will send the update patch for review again.

Thanks,
Raju.
On Fri, Sep 09, 2016 at 02:03:46PM +0200, Andrew Lunn wrote:
> EXTERNAL EMAIL
> 
> 
> On Fri, Sep 09, 2016 at 11:23:52AM +0530, Raju Lakkaraju wrote:
> > Hi Andrew,
> >
> > Thank you for review the code and valuable comments.
> >
> > On Thu, Sep 08, 2016 at 03:27:27PM +0200, Andrew Lunn wrote:
> > > EXTERNAL EMAIL
> > >
> > >
> > > On Thu, Sep 08, 2016 at 02:47:22PM +0530, Raju Lakkaraju wrote:
> > > > From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> > > >
> > > > Used Device Tree to configure the MAC Interface as per review comments and
> > > > re-sending code for review
> > >
> > > I don't see anything about device tree in this patch...
> > >
> > Ethernet driver (in my BBB environment, TI cpsw driver) read the device tree
> > phy interface parameter and update in phydev structure.
> >
> > In device tree the following code holds the phy interface configuration.
> > &cpsw_emac0 {
> >         phy_id = <&davinci_mdio>, <0>;
> >         phy-mode = "rgmii";
> > };
> 
> O.K, that is one place it can come from. But it is not the only,
> e.g. platform data or ACPI. A better comment might be:
> 
> Configure the MAC/PHY interface as indicated in phydev->interface,
> eg. GMII, RMII, RGMII.
> 
>     Andrew
