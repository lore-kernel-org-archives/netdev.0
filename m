From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 05/16 linux-next] drivers: net: xgene: constify of_device_id array
Date: Tue, 17 Mar 2015 19:37:36 +0100
Message-ID: <1426617469-781-6-git-send-email-fabf@skynet.be>
References: <1426617469-781-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, Fabian Frederick <fabf@skynet.be>,
	Iyappan Subramanian <isubramanian@apm.com>,
	Keyur Chudgar <kchudgar@apm.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay119.isp.belgacom.be ([195.238.20.146]:46748 "EHLO
	mailrelay119.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932141AbbCQSiK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 14:38:10 -0400
In-Reply-To: <1426617469-781-1-git-send-email-fabf@skynet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

of_device_id is always used as const.
(See driver.of_match_table and open firmware functions)

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 635a83b..edb8436 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -1033,7 +1033,7 @@ MODULE_DEVICE_TABLE(acpi, xgene_enet_acpi_match);
 #endif
 
 #ifdef CONFIG_OF
-static struct of_device_id xgene_enet_of_match[] = {
+static const struct of_device_id xgene_enet_of_match[] = {
 	{.compatible = "apm,xgene-enet",},
 	{.compatible = "apm,xgene1-sgenet",},
 	{.compatible = "apm,xgene1-xgenet",},
-- 
2.1.0
