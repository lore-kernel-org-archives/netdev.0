From: Russell King - ARM Linux <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>
Subject: Re: [PATCH 4/5] net: phy: add XAUI and 10GBASE-KR PHY connection
 types
Date: Thu, 1 Jun 2017 18:32:49 +0100
Message-ID: <20170601173249.GF22219@n2100.armlinux.org.uk>
References: <20170601102327.GF27796@n2100.armlinux.org.uk>
 <E1dGNJX-00043v-3M@rmk-PC.armlinux.org.uk>
 <fb1a81e0-b5b9-80e4-7852-cc65a574b9e9@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <fb1a81e0-b5b9-80e4-7852-cc65a574b9e9-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 01, 2017 at 09:56:48AM -0700, Florian Fainelli wrote:
> On 06/01/2017 03:26 AM, Russell King wrote:
> > XAUI allows XGMII to reach an extended distance by using a XGXS layer at
> > each end of the MAC to PHY link, operating over four Serdes lanes.
> > 
> > 10GBASE-KR is a single lane Serdes backplane ethernet connection method
> > with autonegotiation on the link.  Some PHYs use this to connect to the
> > ethernet interface at 10G speeds, switching to other connection types
> > when utilising slower speeds.
> > 
> > 10GBASE-KR is also used for XFI and SFI to connect to XFP and SFP fiber
> > modules.
> > 
> > Signed-off-by: Russell King <rmk+kernel-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>
> 
> This looks good, but you also need to update
> Documentation/ABI/testing/sysfs-class-net-phydev since we report
> phy_interface from sysfs.

Hmm, seems to be a new file recently merged into net-next.  Ok, I'll
provide an update for that.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
