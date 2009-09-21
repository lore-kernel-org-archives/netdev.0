From: <jie.yang@atheros.com>
Subject: [Patch net-next]atl1c:remove compiling warning
Date: Mon, 21 Sep 2009 13:01:58 +0800
Message-ID: <12535093181069-git-send-email-jie.yang@atheros.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <akpm@linux-foundation.org>, <jirislaby@gmail.com>,
	<jcliburn@gmail.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, Jie Yang <jie.yang@atheros.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753922AbZIUFCD@vger.kernel.org>
Received: from mail.atheros.com ([10.10.20.105])
	by sidewinder.atheros.com
	for <netdev@vger.kernel.org>; Sun, 20 Sep 2009 22:02:04 -0700
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Set wol_ctrl_data to value 0, to remove compiling warning.

Signed-off-by: Jie Yang <jie.yang@atheros.com>
---
diff --git a/drivers/net/atl1c/atl1c_main.c b/drivers/net/atl1c/atl1c_main.c
index be2c6cf..1372e9a 100644
--- a/drivers/net/atl1c/atl1c_main.c
+++ b/drivers/net/atl1c/atl1c_main.c
@@ -2296,7 +2296,7 @@ static int atl1c_suspend(struct pci_dev *pdev, pm_message_t state)
 	u32 ctrl;
 	u32 mac_ctrl_data;
 	u32 master_ctrl_data;
-	u32 wol_ctrl_data;
+	u32 wol_ctrl_data = 0;
 	u16 mii_bmsr_data;
 	u16 save_autoneg_advertised;
 	u16 mii_intr_status_data;
