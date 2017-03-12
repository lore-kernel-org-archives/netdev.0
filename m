From: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Subject: [PATCH v2 06/23] MAINTAINERS: Add file patterns for dsa device tree bindings
Date: Sun, 12 Mar 2017 14:16:50 +0100
Message-ID: <1489324627-19126-7-git-send-email-geert@linux-m68k.org>
References: <1489324627-19126-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Vivien Didelot <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1489324627-19126-1-git-send-email-geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Submitters of device tree binding documentation may forget to CC
the subsystem maintainer if this is missing.

Signed-off-by: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Cc: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Cc: Vivien Didelot <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
Please apply this patch directly if you want to be involved in device
tree binding documentation for your subsystem.

v2:
  - Rebased on top of commit 0d3cd4b6b49865e8 ("net: dsa: mv88e6xxx:
    move driver in its own folder").

Impact on next-20170310:

+Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org> (maintainer:MARVELL 88E6XXX ETHERNET SWITCH FABRIC DRIVER)
+Vivien Didelot <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org> (maintainer:MARVELL 88E6XXX ETHERNET SWITCH FABRIC DRIVER)
 Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> (maintainer:OPEN FIRMWARE AND FLATTENED DEVICE TREE BINDINGS)
 Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org> (maintainer:OPEN FIRMWARE AND FLATTENED DEVICE TREE BINDINGS)
-"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> (commit_signer:11/12=92%)
-Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org> (commit_signer:8/12=67%,authored:7/12=58%)
-Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (commit_signer:4/12=33%,authored:2/12=17%)
-Vivien Didelot <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org> (commit_signer:2/12=17%,authored:1/12=8%)
-John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org> (commit_signer:1/12=8%,authored:1/12=8%)
-"Otto Kekäläinen" <otto-Gh1NM5ZPXYb1KXRcyAk9cg@public.gmane.org> (authored:1/12=8%)
-netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list:NETWORKING DRIVERS)
+netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list:MARVELL 88E6XXX ETHERNET SWITCH FABRIC DRIVER)
 devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list:OPEN FIRMWARE AND FLATTENED DEVICE TREE BINDINGS)
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list)
---
 MAINTAINERS | 1 +
 1 file changed, 1 insertion(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index ce461fefec6c9463..c0822d4fa5c3ade5 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -7812,6 +7812,7 @@ M:	Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
 M:	Vivien Didelot <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>
 L:	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
 S:	Maintained
+F:	Documentation/devicetree/bindings/net/dsa/
 F:	drivers/net/dsa/mv88e6xxx/
 F:	Documentation/devicetree/bindings/net/dsa/marvell.txt
 
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
