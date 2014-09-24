From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v1 0/5] Add 10GbE support to APM X-Gene SoC ethernet driver
Date: Tue, 23 Sep 2014 20:51:23 -0700
Message-ID: <1411530688-2939-1-git-send-email-isubramanian@apm.com>
Cc: kchudgar@apm.com, patches@apm.com,
	Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og108.obsmtp.com ([64.18.0.186]:45840 "HELO
	exprod5og108.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750891AbaIXDvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 23:51:41 -0400
Received: by mail-pa0-f53.google.com with SMTP id hz1so7831829pad.12
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2014 20:51:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding 10GbE support to APM X-Gene SoC ethernet driver.

v1:
* Initial version
---

Iyappan Subramanian (5):
  MAINTAINERS: Update APM X-Gene section
  Documentation: dts: Update section header for APM X-Gene
  dtb: Add 10GbE node to APM X-Gene SoC device tree
  drivers: net: xgene: Add 10GbE support
  drivers: net: xgene: Add 10GbE ethtool support

 .../devicetree/bindings/net/apm-xgene-enet.txt     |   4 +-
 MAINTAINERS                                        |   1 -
 arch/arm64/boot/dts/apm-mustang.dts                |   4 +
 arch/arm64/boot/dts/apm-storm.dtsi                 |  24 +++
 drivers/net/ethernet/apm/xgene/Makefile            |   3 +-
 .../net/ethernet/apm/xgene/xgene_enet_ethtool.c    |  24 ++-
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c     | 123 ++++++++------
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h     |  31 ++--
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c   |  87 +++++++---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h   |  24 ++-
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c  | 187 +++++++++++++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h  |  64 +++++++
 12 files changed, 473 insertions(+), 103 deletions(-)
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h

-- 
1.9.1
