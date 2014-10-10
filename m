From: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Subject: [PATCH v1 0/3] Add SGMII based 1GbE support to APM X-Gene SoC ethernet driver
Date: Fri, 10 Oct 2014 13:18:33 -0700
Message-ID: <1412972316-16344-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, patches-qTEPVZfXA3Y@public.gmane.org,
	kchudgar-qTEPVZfXA3Y@public.gmane.org, Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Adding SGMII based 1GbE basic support to APM X-Gene SoC ethernet driver.

v1:
* Initial version
---

Iyappan Subramanian (3):
  dtb: Add SGMII based 1GbE node to APM X-Gene SoC device tree
  drivers: net: xgene: Add SGMII based 1GbE support
  drivers: net: xgene: Add SGMII based 1GbE ethtool support

 arch/arm64/boot/dts/apm-mustang.dts                |   4 +
 arch/arm64/boot/dts/apm-storm.dtsi                 |  24 ++
 drivers/net/ethernet/apm/xgene/Makefile            |   2 +-
 .../net/ethernet/apm/xgene/xgene_enet_ethtool.c    |  25 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c     |   1 -
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h     |   2 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c   |  24 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h   |   5 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c  | 407 +++++++++++++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h  |  41 +++
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c  |   3 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h  |   4 -
 12 files changed, 518 insertions(+), 24 deletions(-)
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h

-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
