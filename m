From: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Subject: [PATCH v4 0/6] Add 10GbE support to APM X-Gene SoC ethernet driver
Date: Thu,  9 Oct 2014 18:32:01 -0700
Message-ID: <1412904727-23485-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, patches-qTEPVZfXA3Y@public.gmane.org,
	kchudgar-qTEPVZfXA3Y@public.gmane.org, Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Adding 10GbE support to APM X-Gene SoC ethernet driver.

v4: Address comments from v3
* dtb: resolved merge conflict for the net tree

v3: Address comments from v2
* dtb: changed to use all-zeros for the mac address

v2: Address comments from v1
* created preparatory patch to review before adding new functionality
* dtb: updated to use tabs consistently

v1:
* Initial version
---

Iyappan Subramanian (6):
  MAINTAINERS: Update APM X-Gene section
  Documentation: dts: Update section header for APM X-Gene
  dtb: Add 10GbE node to APM X-Gene SoC device tree
  drivers: net: xgene: Preparing for adding 10GbE support
  drivers: net: xgene: Add 10GbE support
  drivers: net: xgene: Add 10GbE ethtool support

 .../devicetree/bindings/net/apm-xgene-enet.txt     |   4 +-
 MAINTAINERS                                        |   1 -
 arch/arm64/boot/dts/apm-mustang.dts                |   4 +
 arch/arm64/boot/dts/apm-storm.dtsi                 |  29 +-
 drivers/net/ethernet/apm/xgene/Makefile            |   3 +-
 .../net/ethernet/apm/xgene/xgene_enet_ethtool.c    |  28 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c     |  44 ++-
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h     |  30 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c   |  86 ++++--
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h   |  24 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c  | 331 +++++++++++++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h  |  57 ++++
 12 files changed, 566 insertions(+), 75 deletions(-)
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h

-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
