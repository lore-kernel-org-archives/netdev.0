From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: Re: [PATCH 1/4] net: phy: Add Edge-rate driver for Microsemi PHYs.
Date: Thu, 8 Sep 2016 14:36:57 +0530
Message-ID: <20160908090655.GB4134@microsemi.com>
References: <646450A91FAED74E85C6E9C4D6E936A145336681@avsrvexchmbx1.microsemi.net>
 <20160824125934.GC13406@lunn.ch>
Reply-To: <Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        Allan Nielsen <Allan.Nielsen@microsemi.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0041.outbound.protection.outlook.com ([104.47.33.41]:31804
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752532AbcIHJHX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 05:07:23 -0400
Content-Disposition: inline
In-Reply-To: <20160824125934.GC13406@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Thank you for review the code and valuable comments.
I accepted your review comments.
I too use the Device Tree for Edge-rate and MAC interface 
configuration.

Thanks,
Raju.

On Wed, Aug 24, 2016 at 02:59:34PM +0200, Andrew Lunn wrote:
> EXTERNAL EMAIL
> 
> 
> On Wed, Aug 24, 2016 at 12:20:03PM +0000, Raju Lakkaraju wrote:
> > From: Nagaraju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> >
> > Edge rate control support will be added for VSC 85xx Microsemi PHYs.
> 
> > diff --git a/include/linux/phy.h b/include/linux/phy.h
> > index 2d24b28..8ec4c09 100644
> > --- a/include/linux/phy.h
> > +++ b/include/linux/phy.h
> > @@ -586,6 +586,8 @@ struct phy_driver {
> >         void (*get_strings)(struct phy_device *dev, u8 *data);
> >         void (*get_stats)(struct phy_device *dev,
> >                           struct ethtool_stats *stats, u64 *data);
> > +       int (*phy_features_set)(struct phy_device *dev);
> > +       int (*phy_features_get)(struct phy_device *dev);
> >  };
> 
> Now we need the missing cover note what should be in 0/4.  What is the
> big picture? How are these two functions supposed to be used? Is there
> going to be a user space API via netlink? Should the MAC driver
> somehow call these functions? Are you going to extend the phylib with
> code to call these?
> 
> Those are all general questions for these two functions.
> 
> Now specifically for edge control, why did you decide not to use
> device tree? Both the micrel and renesas phy driver uses device tree
> for skew control. You need to explain why you need to do something
> different to other drivers.
> 
>           Thanks
>                 Andrew
> 
> 
