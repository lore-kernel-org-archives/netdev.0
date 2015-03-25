From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next v1 0/3] drivers: net: xgene: Add separate tx completion ring
Date: Wed, 25 Mar 2015 12:19:09 -0700
Message-ID: <1427311152-30333-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, kchudgar@apm.com,
	patches@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og108.obsmtp.com ([64.18.0.186]:46143 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752631AbbCYTOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 15:14:21 -0400
Received: by pdbop1 with SMTP id op1so37548795pdb.2
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 12:14:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SGMII based 1GbE and 10GbE interfaces support multiple interrupts.
Adding separate tx completion descriptor ring and associating a dedicated irq for the TX completion.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
---

Iyappan Subramanian (3):
  Documentation: dts: xgene: Update interrupt field description
  dtb: xgene: Add interrupt for Tx completion
  drivers: net: xgene: Add separate tx completion ring

 .../devicetree/bindings/net/apm-xgene-enet.txt     |   5 +-
 arch/arm64/boot/dts/apm/apm-storm.dtsi             |   9 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c   | 141 ++++++++++++++++++---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h   |   6 +
 4 files changed, 137 insertions(+), 24 deletions(-)

-- 
1.9.1
