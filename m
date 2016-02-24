From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 1/6] qede: Change pci DID for 10g device
Date: Wed, 24 Feb 2016 16:52:45 +0200
Message-ID: <1456325570-1514-2-git-send-email-Yuval.Mintz@qlogic.com>
References: <1456325570-1514-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:57175 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751166AbcBXOxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 09:53:04 -0500
In-Reply-To: <1456325570-1514-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The device ID for the 10g module has changed. Populate the pci_ids table
accordingly.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 5f15e23..76fa5d7 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -53,7 +53,7 @@ MODULE_PARM_DESC(debug, " Default debug msglevel");
 static const struct qed_eth_ops *qed_ops;
 
 #define CHIP_NUM_57980S_40		0x1634
-#define CHIP_NUM_57980S_10		0x1635
+#define CHIP_NUM_57980S_10		0x1666
 #define CHIP_NUM_57980S_MF		0x1636
 #define CHIP_NUM_57980S_100		0x1644
 #define CHIP_NUM_57980S_50		0x1654
-- 
1.9.3
