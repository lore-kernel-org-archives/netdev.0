From: Suman Tripathi <stripathi@apm.com>
Subject: [PATCH net-next v0 3/4] drivers: net: xgene: Add ACPI support for SGMII0 and XFI1 interface of 2nd H/W version of APM X-Gene SoC ethernet controller.
Date: Tue, 23 Jun 2015 14:47:16 +0530
Message-ID: <1435051037-21753-4-git-send-email-stripathi@apm.com>
References: <1435051037-21753-1-git-send-email-stripathi@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, kchudgar@apm.com,
	patches@apm.com, isubramanian@apm.com,
	Suman Tripathi <stripathi@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from denmail01-v4020.amcc.com ([192.195.68.30]:45522 "EHLO
	denmail01.amcc.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S932256AbbFWJSe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 05:18:34 -0400
In-Reply-To: <1435051037-21753-1-git-send-email-stripathi@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the ACPI support for SGMII0 and XFI1 interface of
2nd H/W version of APM X-Gene SoC ethernet controller.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Suman Tripathi <stripathi@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 946ebde..ed52d65 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -1289,6 +1289,8 @@ static const struct acpi_device_id xgene_enet_acpi_match[] = {
 	{ "APMC0D05", XGENE_ENET1},
 	{ "APMC0D30", XGENE_ENET1},
 	{ "APMC0D31", XGENE_ENET1},
+	{ "APMC0D26", XGENE_ENET2},
+	{ "APMC0D25", XGENE_ENET2},
 	{ }
 };
 MODULE_DEVICE_TABLE(acpi, xgene_enet_acpi_match);
--
1.8.2.1
