From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v1 0/2]  drivers: net: xgene: Fix crash for backward compatibility
Date: Wed, 29 Oct 2014 17:56:18 -0700
Message-ID: <1414630580-24640-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	kchudgar@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og120.obsmtp.com ([64.18.0.137]:59139 "HELO
	exprod5og120.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1757300AbaJ3Azc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 20:55:32 -0400
Received: by mail-pa0-f45.google.com with SMTP id lf10so4277919pab.18
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2014 17:55:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set fixes the following issues that were reported during regression.

Patch 1/2: Disables 10GbE and SGMII based 1GbE by default for backward
	   compatiblity with older firmware (<= 1.13.28).  Newer firmware
	   will enable these interfaces based on its configuration.
Patch 2/2: Use separate hardware resources (descriptor ring, prefetch buffer)
	   that are not shared with the firmware
---

Iyappan Subramanian (2):
  dtb: xgene: fix: Disable 10GbE and SGMII based 1GbE by default
  drivers: net: xgene: fix: Use separate resources

 arch/arm64/boot/dts/apm-mustang.dts              | 8 --------
 arch/arm64/boot/dts/apm-storm.dtsi               | 4 ++--
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 6 +++---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h | 3 +++
 4 files changed, 8 insertions(+), 13 deletions(-)

-- 
1.9.1
