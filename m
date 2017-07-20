From: Egil Hjelmeland <egil.hjelmeland@zenitel.com>
Subject: [PATCH 10/13] net: dsa: lan9303: Only allocate 3 ports
Date: Thu, 20 Jul 2017 12:35:59 +0200
Message-ID: <9c01203909bc4a89a719050ca80c4b58@nooslMX1.zenitelcss.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <egil.hjelmeland@zenitel.com>
To: <corbet@lwn.net>, <andrew@lunn.ch>,
        <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <davem@davemloft.net>, <kernel@pengutronix.de>,
        <linux-doc@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Saving 2628 bytes.

Signed-off-by: Egil Hjelmeland <egil.hjelmeland@zenitel.com>
---
 drivers/net/dsa/lan9303-core.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
index dc95973d62ed..ad7a4c72e1fb 100644
--- a/drivers/net/dsa/lan9303-core.c
+++ b/drivers/net/dsa/lan9303-core.c
@@ -23,6 +23,8 @@
 
 #include "lan9303.h"
 
+#define LAN9303_NUM_PORTS 3
+
 /* 13.2 System Control and Status Registers
  * Multiply register number by 4 to get address offset.
  */
@@ -1361,7 +1363,7 @@ static struct dsa_switch_ops lan9303_switch_ops = {
 
 static int lan9303_register_switch(struct lan9303 *chip)
 {
-	chip->ds = dsa_switch_alloc(chip->dev, DSA_MAX_PORTS);
+	chip->ds = dsa_switch_alloc(chip->dev, LAN9303_NUM_PORTS);
 	if (!chip->ds)
 		return -ENOMEM;
 
-- 
2.11.0


DISCLAIMER:
This e-mail may contain confidential and privileged material for the sole use of the intended recipient. Any review, use, distribution or disclosure by others is strictly prohibited. If you are not the intended recipient (or authorized to receive for the recipient), please contact the sender by reply e-mail and delete all copies of this message.
