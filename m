From: "H Hartley Sweeten" <hartleys@visionengravers.com>
Subject: [PATCH] drivers/net/qlge/qlge_main.c: use %pM to show MAC address
Date: Wed, 30 Dec 2009 15:13:07 -0500
Message-ID: <BD79186B4FD85F4B8E60E381CAEE19090200F671@mi8nycmail19.Mi8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "David Miller" <davem@davemloft.net>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753482AbZL3UNK@vger.kernel.org>
Content-class: urn:content-classes:message
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the %pM kernel extension to display the MAC address.

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: David S. Miller <davem@davemloft.net>

---

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 707b391..628642a 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -452,9 +452,7 @@ static int ql_set_mac_addr(struct ql_adapter *qdev, int set)
 	if (set) {
 		addr = &qdev->ndev->dev_addr[0];
 		QPRINTK(qdev, IFUP, DEBUG,
-			"Set Mac addr %02x:%02x:%02x:%02x:%02x:%02x\n",
-			addr[0], addr[1], addr[2], addr[3],
-			addr[4], addr[5]);
+			"Set Mac addr %pM\n", addr);
 	} else {
 		memset(zero_mac_addr, 0, ETH_ALEN);
 		addr = &zero_mac_addr[0]; 
