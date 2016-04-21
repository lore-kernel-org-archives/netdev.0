From: "David Rivshin (Allworx)" <drivshin.allworx-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net v2 0/3] drivers: net: cpsw: phy-handle fixes
Date: Thu, 21 Apr 2016 13:50:32 -0400
Message-ID: <1461261035-5578-1-git-send-email-drivshin.allworx@gmail.com>
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>,
	Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>,
	Andrew Goodbody <andrew.goodbody-nYQdZkeIoGZN8Ch2cx6nig@public.gmane.org>,
	Markus Brunner <systemprogrammierung.brunner-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Nicolas Chauvet <kwizart-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: David Rivshin <drivshin-5fOYsn7Fw8lBDgjK7y7TUQ@public.gmane.org>

The first patch fixes a bug that makes dual_emac mode break if
either slave uses the phy-handle property in the devicetree.

The second patch fixes some cosmetic problems with error messages,
and also makes the binding documentation more explicit.

The third patch cleans up the fixed-link case to work like
the now-fixed phy-handle case.

I have tested on the following hardware configurations:
 - (EVMSK) dual emac, phy_id property in both slaves
 - (EVMSK) dual emac, phy-handle property in both slaves
 - (BeagleBoneBlack) single emac, phy_id property
 - (custom) single emac, fixed-link subnode

Nicolas Chauvet reported testing on an HP t410 (dm8148).

Markus Brunner reported testing v1 on the following [1]:
 - emac0 with phy_id and emac1 with fixed phy
 - emac0 with phy-handle and emac1 with fixed phy
 - emac0 with fixed phy and emac1 with fixed phy


Changes since v1 [2]:
- Rebased
- Added Tested-by from Nicolas Chauvet on all patches
- Added Acked-by from Rob Herring for the binding change in patch 2 [3]

[1] http://www.spinics.net/lists/netdev/msg357890.html
[2] http://www.spinics.net/lists/netdev/msg357772.html
[3] http://www.spinics.net/lists/netdev/msg358254.html

David Rivshin (3):
  drivers: net: cpsw: fix parsing of phy-handle DT property in dual_emac
    config
  drivers: net: cpsw: fix error messages when using phy-handle DT
    property
  drivers: net: cpsw: use of_phy_connect() in fixed-link case

 Documentation/devicetree/bindings/net/cpsw.txt |  4 +--
 drivers/net/ethernet/ti/cpsw.c                 | 41 +++++++++++++-------------
 drivers/net/ethernet/ti/cpsw.h                 |  1 +
 3 files changed, 23 insertions(+), 23 deletions(-)

-- 
2.5.5

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
