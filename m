From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: [PATCH] drivers/net/atl1e/atl1e_main.c: use %pM to show MAC address
Date: Tue, 5 Jan 2010 09:55:40 -0700
Message-ID: <201001050955.40411.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932134Ab0AERDf@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the %pM kernel extension to display the MAC address.

The only difference in the output is that the MAC address is
shown in the usual colon-separated hex notation.

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: David S. Miller <davem@davemloft.net>

---

Repost due to merge issues.

diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_main.c
index 08f8c09..2080d44 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -2378,10 +2378,7 @@ static int __devinit atl1e_probe(struct pci_dev *pdev,
 
 	memcpy(netdev->dev_addr, adapter->hw.mac_addr, netdev->addr_len);
 	memcpy(netdev->perm_addr, adapter->hw.mac_addr, netdev->addr_len);
-	dev_dbg(&pdev->dev, "mac address : %02x-%02x-%02x-%02x-%02x-%02x\n",
-			adapter->hw.mac_addr[0], adapter->hw.mac_addr[1],
-			adapter->hw.mac_addr[2], adapter->hw.mac_addr[3],
-			adapter->hw.mac_addr[4], adapter->hw.mac_addr[5]);
+	dev_dbg(&pdev->dev, "mac address : %pM\n", adapter->hw.mac_addr);
 
 	INIT_WORK(&adapter->reset_task, atl1e_reset_task);
 	INIT_WORK(&adapter->link_chg_task, atl1e_link_chg_task);
