From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 0/2] drivers: xgene: Add support RGMII TX/RX delay configuration
Date: Fri, 16 Oct 2015 13:35:50 -0700
Message-ID: <1445027752-16982-1-git-send-email-isubramanian@apm.com>
Cc: devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	patches@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33992 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751904AbbJPUf3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 16:35:29 -0400
Received: by pacez2 with SMTP id ez2so13808753pac.1
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 13:35:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support RGMII TX/RX delay configuration.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---

Iyappan Subramanian (2):
  drivers: net: xgene: Add support RGMII TX/RX delay configuration
  Documentation: dts: xgene: Add TX/RX delay field

 .../devicetree/bindings/net/apm-xgene-enet.txt     | 10 +++++
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c     |  8 +++-
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h     |  1 +
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c   | 49 ++++++++++++++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h   |  2 +
 5 files changed, 69 insertions(+), 1 deletion(-)

-- 
1.9.1
