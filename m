From: Colin King <colin.king@canonical.com>
Subject: [PATCH] liquidio: fix spelling mistake: "interuupt" -> "interrupt"
Date: Thu, 17 Aug 2017 09:19:30 +0100
Message-ID: <20170817081930.12986-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Trivial fix to spelling mistake in dev_info message

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
index 08aa06c90d46..a63ddf07f168 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
@@ -412,7 +412,7 @@ lio_irq_reallocate_irqs(struct octeon_device *oct, uint32_t num_ioqs)
 	kfree(oct->irq_name_storage);
 	oct->irq_name_storage = NULL;
 	if (octeon_setup_interrupt(oct, num_ioqs)) {
-		dev_info(&oct->pci_dev->dev, "Setup interuupt failed\n");
+		dev_info(&oct->pci_dev->dev, "Setup interrupt failed\n");
 		return 1;
 	}
 
-- 
2.11.0
