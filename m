From: Suman Tripathi <stripathi@apm.com>
Subject: [PATCH net-next v0 0/4] drivers: net: xgene: Fix the ACPI support for RGMII/SGMII0/XFI ethernet interfaces of APM X-Gene SoC.
Date: Tue, 23 Jun 2015 14:47:13 +0530
Message-ID: <1435051037-21753-1-git-send-email-stripathi@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, kchudgar@apm.com,
	patches@apm.com, isubramanian@apm.com,
	Suman Tripathi <stripathi@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from denmail01-v4020.amcc.com ([192.195.68.30]:45507 "EHLO
	denmail01.amcc.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753911AbbFWJSU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 05:18:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Suman Tripathi <stripathi@apm.com>
---

Suman Tripathi (4):
  drivers: net: xgene: Fix the ACPI support for RGMII/SGMII0/XFI
    interface of APM X-Gene SoC ethernet controller.
  drivers: net: xgene: Implement the backward compatibility with the old
    and new firmware w.r.t Tx completion IRQ interrupt.
  drivers: net: xgene: Add ACPI support for SGMII0 and XFI1 interface of
    2nd H/W version of APM X-Gene SoC ethernet controller.
  drivers: net: xgene: Check for IS_ERR rather than NULL for clock.

 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c    |  7 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c  | 84 ++++++++++++++---------
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c | 13 ++--
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c | 13 ++--
 4 files changed, 73 insertions(+), 44 deletions(-)

--
1.8.2.1
