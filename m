From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH] can: peak_pci: Make i2c_algo_bit_data const
Date: Mon, 21 Aug 2017 18:56:14 +0530
Message-ID: <1503321974-25802-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, wg@grandegger.com, mkl@pengutronix.de,
        linux-can@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make this const as it is only used in a copy operation.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 drivers/net/can/sja1000/peak_pci.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/sja1000/peak_pci.c b/drivers/net/can/sja1000/peak_pci.c
index 131026f..44f1e37 100644
--- a/drivers/net/can/sja1000/peak_pci.c
+++ b/drivers/net/can/sja1000/peak_pci.c
@@ -425,7 +425,7 @@ static void peak_pciec_write_reg(const struct sja1000_priv *priv,
 	peak_pci_write_reg(priv, port, val);
 }
 
-static struct i2c_algo_bit_data peak_pciec_i2c_bit_ops = {
+static const struct i2c_algo_bit_data peak_pciec_i2c_bit_ops = {
 	.setsda	= pita_setsda,
 	.setscl	= pita_setscl,
 	.getsda	= pita_getsda,
-- 
1.9.1
