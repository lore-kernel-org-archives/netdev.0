From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: [PATCH] drivers/net/qlge/qlge_main.c: use %pM to show MAC address
Date: Tue, 5 Jan 2010 09:58:12 -0700
Message-ID: <201001050958.12329.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755198Ab0AEREv@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the %pM kernel extension to display the MAC address.

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: David S. Miller <davem@davemloft.net>

---

Repost due to merge issues.

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
