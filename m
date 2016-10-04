From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: ps3_gelic: Add missing \n to end of deb_dbg message
Date: Tue,  4 Oct 2016 12:15:54 +0100
Message-ID: <20161004111554.11881-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Geoff Levand <geoff@infradead.org>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Paul Mackerras <paulus@samba.org>,
        Michael Ellerman <mpe@ellerman.id.au>, netdev@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Trival fix, dev_dbg message is missing a \n, so add it.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/toshiba/ps3_gelic_net.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/toshiba/ps3_gelic_net.c b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
index bc258d7..272f2b1 100644
--- a/drivers/net/ethernet/toshiba/ps3_gelic_net.c
+++ b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
@@ -1769,7 +1769,7 @@ static int ps3_gelic_driver_probe(struct ps3_system_bus_device *dev)
 	gelic_ether_setup_netdev_ops(netdev, &card->napi);
 	result = gelic_net_setup_netdev(netdev, card);
 	if (result) {
-		dev_dbg(&dev->core, "%s: setup_netdev failed %d",
+		dev_dbg(&dev->core, "%s: setup_netdev failed %d\n",
 			__func__, result);
 		goto fail_setup_netdev;
 	}
-- 
2.9.3
