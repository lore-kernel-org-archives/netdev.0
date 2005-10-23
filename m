From: Ashutosh Naik <ashutosh_naik@adaptec.com>
Subject: [PATCH] e1000 : Fixes e1000_suspend warning when CONFIG_PM is not
	enabled
Date: Sun, 23 Oct 2005 13:43:22 +0530
Message-ID: <1130055202.16820.11.camel@kir9060>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-WSL2YOewf+ex5xbh7qWz"
Cc: linux.nics@intel.com
Return-path: <linux-net-owner@vger.kernel.org>
To: linux-net@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, akpm@osdl.org
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-WSL2YOewf+ex5xbh7qWz
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

This Patch fixes the warning

drivers/net/e1000/e1000_main.c:3645: warning: `e1000_suspend' defined
but not used

Signed-off-by: Ashutosh Naik <ashutosh_naik@adaptec.com>

--=-WSL2YOewf+ex5xbh7qWz
Content-Disposition: attachment; filename=e1000-patch.txt
Content-Type: text/plain; name=e1000-patch.txt; charset=UTF-8
Content-Transfer-Encoding: 7bit

diff -ruNp linux-2.6.14-rc5/drivers/net/e1000/e1000_main.c linux-2.6.14-e1000-patch/drivers/net/e1000/e1000_main.c
--- linux-2.6.14-rc5/drivers/net/e1000/e1000_main.c	2005-10-23 13:06:51.000000000 +0530
+++ linux-2.6.14-e1000-patch/drivers/net/e1000/e1000_main.c	2005-10-23 13:19:32.000000000 +0530
@@ -162,8 +162,8 @@ static void e1000_vlan_rx_add_vid(struct
 static void e1000_vlan_rx_kill_vid(struct net_device *netdev, uint16_t vid);
 static void e1000_restore_vlan(struct e1000_adapter *adapter);
 
-static int e1000_suspend(struct pci_dev *pdev, pm_message_t state);
 #ifdef CONFIG_PM
+static int e1000_suspend(struct pci_dev *pdev, pm_message_t state);
 static int e1000_resume(struct pci_dev *pdev);
 #endif
 

--=-WSL2YOewf+ex5xbh7qWz--


