From: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>
Subject: [PATCH 0/2] net: phy: dp83867: workaround incorrect RX_CTRL pin strap
Date: Tue, 4 Jul 2017 16:23:22 +0530
Message-ID: <cover.1499162046.git.nsekhar@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Device Tree Mailing List <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>,
        Linux OMAP Mailing List <linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>,
        Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>
To: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

This patch series adds workaround for incorrect RX_CTRL pin strap
setting that can be found on some TI boards.

This is required to be complaint to PHY datamanual specification.

Murali Karicheri (2):
  dt-bindings: phy: dp83867: provide a workaround for incorrect RX_CTRL
    pin strap
  net: phy: dp83867: add workaround for incorrect RX_CTRL pin strap

 Documentation/devicetree/bindings/net/ti,dp83867.txt |  7 +++++++
 drivers/net/phy/dp83867.c                            | 11 +++++++++++
 2 files changed, 18 insertions(+)

-- 
2.9.0

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
