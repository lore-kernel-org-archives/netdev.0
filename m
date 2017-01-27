From: Colin King <colin.king@canonical.com>
Subject: [PATCH][net-next] net: ethernet: aquantia: remove redundant err check
Date: Fri, 27 Jan 2017 14:43:46 +0000
Message-ID: <20170127144346.18565-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
        Pavel Belous <Pavel.Belous@aquantia.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>,
        David VomLehn <vomlehn@texas.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The check on err < 0 is redundant and can be removed. Detected
by CoverityScan, CID#1398321 ("Logically Dead Code")

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/aquantia/atlantic/aq_pci_func.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_pci_func.c b/drivers/net/ethernet/aquantia/atlantic/aq_pci_func.c
index afcecdb..da4bc09 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_pci_func.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_pci_func.c
@@ -145,8 +145,6 @@ int aq_pci_func_init(struct aq_pci_func_s *self)
 		}
 	}
 
-	if (err < 0)
-		goto err_exit;
 	for (i = 0; i < self->aq_hw_caps.msix_irqs; i++)
 		self->msix_entry[i].entry = i;
 
-- 
2.10.2
