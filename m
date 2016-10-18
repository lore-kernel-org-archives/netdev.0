From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH net-next 2/2] net: phy: Add Fast Link Failure - 2 set
 driver for Microsemi PHYs.
Date: Tue, 18 Oct 2016 12:58:20 +0200
Message-ID: <20161018105820.GM26778@lunn.ch>
References: <1476445233-26524-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <1476445233-26524-3-git-send-email-Raju.Lakkaraju@microsemi.com>
 <20161014120228.GF5822@lunn.ch>
 <20161017081312.GB2365@microsemi.com>
 <838C6202-9B7D-4AFA-B163-55515044FA4F@gmail.com>
 <20161018103413.GA31087@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Allan.Nielsen-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org
To: Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161018103413.GA31087-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> > In fact, this looks a lot like netdev features (e.g: checksum
> > offload), and there seems to be some commonality here between at
> > least Marvell and Microsemi (for the faster link down reporting),
> > so maybe we should start adding PHY features similar to netdev
> > features?

> Sure. 
> 
> I would like add one flag in phy_device structure:
> u64 phy_features;
> 
> In phy_driver structure, i would like to add 2 function pointer as
> 
> int (*phy_featues_set)(struct phy_device *phydev);
> int (*phy_featues_get)(struct phy_device *phydev);
> 
> All the PHY specific features i.e. Fast link failure -2, Downshift, Loopback etc
> are the case in feature_set/feature_get functions.

Please follow how the ethertool features are implemented. So you need
to extend net/core/ethtool.c to pass these call down, etc.

       Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
