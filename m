From: Lad Prabhakar <prabhakar.csengg@gmail.com>
Subject: [PATCH] enic: enic_ethtool: fix sparse warning
Date: Thu,  5 Feb 2015 15:29:55 +0000
Message-ID: <1423150195-14742-1-git-send-email-prabhakar.csengg@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	"Lad, Prabhakar" <prabhakar.csengg@gmail.com>
To: Christian Benvenuti <benve@cisco.com>,
	Sujith Sankar <ssujith@cisco.com>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	Neel Patel <neepatel@cisco.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>

this patch fixes following sparse warning:

enic_ethtool.c:95:6: warning: symbol 'enic_intr_coal_set_rx' was not declared. Should it be static?

Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
---
 Found this issue on linux-next (gcc  version 4.8.2,
 sparse version  0.4.5-rc1)and applies on top linux-next.

 drivers/net/ethernet/cisco/enic/enic_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_ethtool.c b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
index 0c396c1..28d9ca6 100644
--- a/drivers/net/ethernet/cisco/enic/enic_ethtool.c
+++ b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
@@ -92,7 +92,7 @@ static const unsigned int enic_n_tx_stats = ARRAY_SIZE(enic_tx_stats);
 static const unsigned int enic_n_rx_stats = ARRAY_SIZE(enic_rx_stats);
 static const unsigned int enic_n_gen_stats = ARRAY_SIZE(enic_gen_stats);
 
-void enic_intr_coal_set_rx(struct enic *enic, u32 timer)
+static void enic_intr_coal_set_rx(struct enic *enic, u32 timer)
 {
 	int i;
 	int intr;
-- 
1.9.1
