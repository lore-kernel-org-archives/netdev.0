From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 0/2] driver: net: xgene: Enable 2nd 10GbE port on APM X-Gene SoC
Date: Tue,  8 Sep 2015 15:50:25 -0700
Message-ID: <1441752627-9326-1-git-send-email-isubramanian@apm.com>
Cc: devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	patches@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:36428 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753406AbbIHWuf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2015 18:50:35 -0400
Received: by padhk3 with SMTP id hk3so51399413pad.3
        for <netdev@vger.kernel.org>; Tue, 08 Sep 2015 15:50:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for 2nd 10GbE on APM X-Gene SoC

---
Iyappan Subramanian (2):
  driver: net: xgene: Add support for 2nd 10GbE port
  dtb: xgene: Add 2nd 10GbE node

 arch/arm64/boot/dts/apm/apm-storm.dtsi           | 28 ++++++++++++++++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c   |  3 ++-
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 16 ++++++++++----
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h |  5 +++++
 4 files changed, 47 insertions(+), 5 deletions(-)

-- 
1.9.1
