From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH] can: c_can_pci: make c_can_pci_data const
Date: Sun,  6 Aug 2017 12:18:31 +0530
Message-ID: <1502002111-7144-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, wg@grandegger.com, mkl@pengutronix.de,
        linux-can@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make c_can_pci_data structures const as they are only used during
a copy operation.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 drivers/net/can/c_can/c_can_pci.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/c_can/c_can_pci.c b/drivers/net/can/c_can/c_can_pci.c
index cf7c189..70f5659 100644
--- a/drivers/net/can/c_can/c_can_pci.c
+++ b/drivers/net/can/c_can/c_can_pci.c
@@ -252,14 +252,14 @@ static void c_can_pci_remove(struct pci_dev *pdev)
 	pci_disable_device(pdev);
 }
 
-static struct c_can_pci_data c_can_sta2x11= {
+static const struct c_can_pci_data c_can_sta2x11= {
 	.type = BOSCH_C_CAN,
 	.reg_align = C_CAN_REG_ALIGN_32,
 	.freq = 52000000, /* 52 Mhz */
 	.bar = 0,
 };
 
-static struct c_can_pci_data c_can_pch = {
+static const struct c_can_pci_data c_can_pch = {
 	.type = BOSCH_C_CAN,
 	.reg_align = C_CAN_REG_32,
 	.freq = 50000000, /* 50 MHz */
-- 
1.9.1
