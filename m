From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: netcp: fix spelling mistake: "memomry" -> "memory"
Date: Sat, 22 Apr 2017 13:22:01 +0100
Message-ID: <20170422122201.7979-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Wingman Kwok <w-kwok2@ti.com>,
        Murali Karicheri <m-karicheri2@ti.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Trivial fix to spelling mistake in dev_err message and rejoin
line.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/ti/netcp_ethss.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
index eece3e2eec14..897176fc5043 100644
--- a/drivers/net/ethernet/ti/netcp_ethss.c
+++ b/drivers/net/ethernet/ti/netcp_ethss.c
@@ -3048,8 +3048,7 @@ static void init_secondary_ports(struct gbe_priv *gbe_dev,
 	for_each_child_of_node(node, port) {
 		slave = devm_kzalloc(dev, sizeof(*slave), GFP_KERNEL);
 		if (!slave) {
-			dev_err(dev,
-				"memomry alloc failed for secondary port(%s), skipping...\n",
+			dev_err(dev, "memory alloc failed for secondary port(%s), skipping...\n",
 				port->name);
 			continue;
 		}
-- 
2.11.0
