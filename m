From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH 01/11] net: phy: Add rockchip phy driver support
Date: Sat, 24 Jun 2017 16:04:06 +0200
Message-ID: <20170624140406.GL4875@lunn.ch>
References: <1498192929-7519-1-git-send-email-david.wu@rock-chips.com>
 <1498192929-7519-2-git-send-email-david.wu@rock-chips.com>
 <20170624021910.GB4875@lunn.ch>
 <2277908.rG2NXdikOp@phil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Wu <david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org,
        will.deacon-5wv7dgnIgG8@public.gmane.org, olof-nZhT3qVonbNeoWH0uzbU5w@public.gmane.org, linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org,
        arnd-r2nGTMty4D4@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org, huangtao-TNX95d0MmH7DzftRWevZcw@public.gmane.org,
        hwg-TNX95d0MmH7DzftRWevZcw@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Heiko Stuebner <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <2277908.rG2NXdikOp@phil>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> hmm, we do have quite a number of non-net phys in the phy subsystem
> (DP, PCIe, ...) and given that the above would be CONFIG_ROCKCHIP_PHY
> in a global sense, sounds like it could make things confusing.
> 
> So some addition sounds reasonable ... ROCKCHIP_ETH_PHY or so?

I follow you reasoning, but generic phy is the new kid on the
block. It is well established that Ethernet PHYs are called
<MANUFACTURER>_PHY.

If you do want to consider generic phy, the logical name would be
ROCKCHIP_PHY_PHY, since generic phy postfixes with _SATA, _USB, _PCIE,
etc. But that does leave an issues when we have an Ethernet PHY which
needs a generic PHY. In some sense, SERDES could be considered as
something supported by a generic PHY...

	Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
