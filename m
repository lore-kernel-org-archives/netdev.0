From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 0/4] net: phy: Support "internal" PHY interface
Date: Fri, 23 Jun 2017 10:31:31 -0700
Message-ID: <20170623173135.22912-1-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Vivien Didelot <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>,
        Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
        Russell King <rmk+kernel-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list:NETWORKING DRIVERS),
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list:OPEN FIRMWARE AND FLATTENED
        DEVICE TREE BINDINGS), linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list),
        david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org, opendmb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: netdev-gepDB1WL6pn9qxiX1TGQuw@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi all,

This makes the "internal" phy-mode property generally available and
documented and this allows us to remove some custom parsing code
we had for bcmgenet and bcm_sf2 which both used that specific value.

Florian Fainelli (4):
  dt-bindings: Add "internal" as a valid 'phy-mode' property
  net: phy: Support "internal" PHY interface
  net: bcmgenet: Remove special handling of "internal" phy-mode
  net: dsa: bcm_sf2: Remove special handling of "internal" phy-mode

 Documentation/devicetree/bindings/net/ethernet.txt |  1 +
 drivers/net/dsa/bcm_sf2.c                          | 16 +++++----------
 drivers/net/ethernet/broadcom/genet/bcmmii.c       | 24 ++++++++--------------
 include/linux/phy.h                                |  3 +++
 4 files changed, 17 insertions(+), 27 deletions(-)

-- 
2.9.3

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
