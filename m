From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: Re: [PATCH net-next 2/2] net: phy: Add Fast Link Failure - 2 set
 driver for Microsemi PHYs.
Date: Tue, 18 Oct 2016 17:01:03 +0530
Message-ID: <20161018113043.GA19357@microsemi.com>
References: <1476445233-26524-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <1476445233-26524-3-git-send-email-Raju.Lakkaraju@microsemi.com>
 <20161014120228.GF5822@lunn.ch>
 <20161017081312.GB2365@microsemi.com>
 <838C6202-9B7D-4AFA-B163-55515044FA4F@gmail.com>
 <20161018103413.GA31087@microsemi.com>
 <20161018105820.GM26778@lunn.ch>
Reply-To: <Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Florian Fainelli <f.fainelli@gmail.com>, <netdev@vger.kernel.org>,
        <devicetree@vger.kernel.org>, <Allan.Nielsen@microsemi.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0088.outbound.protection.outlook.com ([104.47.40.88]:19264
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752684AbcJRLbX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Oct 2016 07:31:23 -0400
Content-Disposition: inline
In-Reply-To: <20161018105820.GM26778@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On Tue, Oct 18, 2016 at 12:58:20PM +0200, Andrew Lunn wrote:
> EXTERNAL EMAIL
> 
> 
> > > In fact, this looks a lot like netdev features (e.g: checksum
> > > offload), and there seems to be some commonality here between at
> > > least Marvell and Microsemi (for the faster link down reporting),
> > > so maybe we should start adding PHY features similar to netdev
> > > features?
> 
> > Sure.
> >
> > I would like add one flag in phy_device structure:
> > u64 phy_features;
> >
> > In phy_driver structure, i would like to add 2 function pointer as
> >
> > int (*phy_featues_set)(struct phy_device *phydev);
> > int (*phy_featues_get)(struct phy_device *phydev);
> >
> > All the PHY specific features i.e. Fast link failure -2, Downshift, Loopback etc
> > are the case in feature_set/feature_get functions.
> 
> Please follow how the ethertool features are implemented. So you need
> to extend net/core/ethtool.c to pass these call down, etc.
> 

Sure. I will do.
Do i need to change Ethtool application and submit along with 
downshift driver patch (i.e. ethtool.c, phy.c, cpsw.c and mscc.c changes) ? 
>        Andrew

---
Thanks,
Raju.
