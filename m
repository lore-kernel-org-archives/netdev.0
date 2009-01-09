From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 3/5] qlge: Remove support for device ID 8000.
Date: Fri,  9 Jan 2009 13:31:51 -0800
Message-ID: <1231536713-24538-3-git-send-email-ron.mercer@qlogic.com>
References: <20090109213045.GD10803@susedev.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:58231 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758026AbZAIVcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 16:32:03 -0500
In-Reply-To: <20090109213045.GD10803@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support for dev id 8000 is pushed out until 2.6.30.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |    3 +--
 drivers/net/qlge/qlge_main.c |    1 -
 2 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 9697002..a509534 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -28,8 +28,7 @@
        } while (0)
 
 #define QLGE_VENDOR_ID    0x1077
-#define QLGE_DEVICE_ID1    0x8012
-#define QLGE_DEVICE_ID   0x8000
+#define QLGE_DEVICE_ID    0x8012
 
 #define MAX_RX_RINGS 128
 #define MAX_TX_RINGS 128
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index f9db7a8..e5a6238 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -76,7 +76,6 @@ MODULE_PARM_DESC(irq_type, "0 = MSI-X, 1 = MSI, 2 = Legacy.");
 
 static struct pci_device_id qlge_pci_tbl[] __devinitdata = {
 	{PCI_DEVICE(PCI_VENDOR_ID_QLOGIC, QLGE_DEVICE_ID)},
-	{PCI_DEVICE(PCI_VENDOR_ID_QLOGIC, QLGE_DEVICE_ID1)},
 	/* required last entry */
 	{0,}
 };
-- 
1.6.0

