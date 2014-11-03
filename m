From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v2 0/3] drivers: net: xgene: Fix crash for backward compatibility
Date: Mon,  3 Nov 2014 11:59:53 -0800
Message-ID: <1415044796-5081-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	kchudgar@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og124.obsmtp.com ([64.18.0.212]:60321 "HELO
	exprod5og124.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752348AbaKCT7M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 14:59:12 -0500
Received: by mail-pd0-f173.google.com with SMTP id v10so12096940pde.4
        for <netdev@vger.kernel.org>; Mon, 03 Nov 2014 11:59:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set fixes the following issues that were reported during regression.

Patch 1,2 : Adds backward compatibility with the older firmware (<= 1.13.28).
Patch 3   : Use separate hardware resources (descriptor ring, prefetch buffer)
	   that are not shared with the firmware
---

Iyappan Subramanian (3):
  dtb: xgene: fix: Backward compatibility with older firmware
  drivers: net: xgene: Backward compatibility with older firmware
  drivers: net: xgene: fix: Use separate resources

 arch/arm64/boot/dts/apm-storm.dtsi                | 10 +++++-----
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c    | 18 +++++++++++++++++-
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h    |  4 ++++
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c  | 11 +++++++----
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h  |  5 ++++-
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c |  7 ++++++-
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c |  7 ++++++-
 7 files changed, 49 insertions(+), 13 deletions(-)

-- 
1.9.1
