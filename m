From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v2 0/4] Add SGMII based 1GbE support to APM X-Gene SoC ethernet driver
Date: Mon, 13 Oct 2014 17:05:31 -0700
Message-ID: <1413245135-2989-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	kchudgar@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, romieu@fr.zoreil.com, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og125.obsmtp.com ([64.18.0.245]:44893 "HELO
	exprod5og125.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752985AbaJNAFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2014 20:05:51 -0400
Received: by mail-pd0-f172.google.com with SMTP id ft15so6464431pdb.3
        for <netdev@vger.kernel.org>; Mon, 13 Oct 2014 17:05:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding SGMII based 1GbE basic support to APM X-Gene SoC ethernet driver.

v2: Address comments from v1
* Split the patchset into two, the first one being preparatory patch
* Added link_state function pointer to the xgene_mac_ops structure
* Added xgene_indirect_ctl structure for indirect read/write arguments

v1:
* Initial version
---

Iyappan Subramanian (4):
  dtb: Add SGMII based 1GbE node to APM X-Gene SoC device tree
  drivers: net: xgene: Preparing for adding SGMII based 1GbE
  drivers: net: xgene: Add SGMII based 1GbE support
  drivers: net: xgene: Add SGMII based 1GbE ethtool support

 arch/arm64/boot/dts/apm-mustang.dts                |   4 +
 arch/arm64/boot/dts/apm-storm.dtsi                 |  24 ++
 drivers/net/ethernet/apm/xgene/Makefile            |   2 +-
 .../net/ethernet/apm/xgene/xgene_enet_ethtool.c    |  25 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c     |   1 -
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h     |   4 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c   |  18 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h   |  12 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c  | 389 +++++++++++++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h  |  41 +++
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c  |   3 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h  |   4 -
 12 files changed, 506 insertions(+), 21 deletions(-)
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h

-- 
1.9.1
