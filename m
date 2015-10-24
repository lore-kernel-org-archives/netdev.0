From: David Daney <ddaney.cavm@gmail.com>
Subject: [PATCH 1/4] net: thunderx: Remove PF soft reset.
Date: Fri, 23 Oct 2015 17:14:07 -0700
Message-ID: <1445645650-17328-2-git-send-email-ddaney.cavm@gmail.com>
References: <1445645650-17328-1-git-send-email-ddaney.cavm@gmail.com>
Cc: David Daney <david.daney@cavium.com>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, Sunil Goutham <sgoutham@cavium.com>,
	Robert Richter <rric@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445645650-17328-1-git-send-email-ddaney.cavm@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

In some silicon revisions, the soft reset clobbers PCI config space,
so quit doing the reset.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
Signed-off-by: David Daney <david.daney@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nic_main.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic_main.c b/drivers/net/ethernet/cavium/thunder/nic_main.c
index b3a5947..d6e3219 100644
--- a/drivers/net/ethernet/cavium/thunder/nic_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nic_main.c
@@ -305,9 +305,6 @@ static void nic_init_hw(struct nicpf *nic)
 {
 	int i;
 
-	/* Reset NIC, in case the driver is repeatedly inserted and removed */
-	nic_reg_write(nic, NIC_PF_SOFT_RESET, 1);
-
 	/* Enable NIC HW block */
 	nic_reg_write(nic, NIC_PF_CFG, 0x3);
 
-- 
1.8.3.1
