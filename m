From: <Tristram.Ha@microchip.com>
Subject: [PATCH v1 RFC 2/7] Clean up code according to patch check suggestions
Date: Fri, 6 Oct 2017 13:33:00 -0700
Message-ID: <1507321985-15097-3-git-send-email-Tristram.Ha@microchip.com>
References: <1507321985-15097-1-git-send-email-Tristram.Ha@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tristram Ha <Tristram.Ha@microchip.com>, <muvarov@gmail.com>,
        <nathan.leigh.conrad@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>,
        <UNGLinuxDriver@microchip.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Pavel Machek <pavel@ucw.cz>,
        Ruediger Schmitt <ruediger.schmitt@philips.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507321985-15097-1-git-send-email-Tristram.Ha@microchip.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tristram Ha <Tristram.Ha@microchip.com>

Clean up code according to patch check suggestions.

Signed-off-by: Tristram Ha <Tristram.Ha@microchip.com>
---
 drivers/net/dsa/microchip/ksz_common.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/dsa/microchip/ksz_common.c b/drivers/net/dsa/microchip/ksz_common.c
index 685dafd..d72aad7 100644
--- a/drivers/net/dsa/microchip/ksz_common.c
+++ b/drivers/net/dsa/microchip/ksz_common.c
@@ -898,9 +898,9 @@ static void ksz_port_mdb_add(struct dsa_switch *ds, int port,
 
 		if (static_table[0] & ALU_V_STATIC_VALID) {
 			/* check this has same vid & mac address */
-			if (((static_table[2] >> ALU_V_FID_S) == (mdb->vid)) &&
+			if (((static_table[2] >> ALU_V_FID_S) == mdb->vid) &&
 			    ((static_table[2] & ALU_V_MAC_ADDR_HI) == mac_hi) &&
-			    (static_table[3] == mac_lo)) {
+			    static_table[3] == mac_lo) {
 				/* found matching one */
 				break;
 			}
@@ -971,9 +971,9 @@ static int ksz_port_mdb_del(struct dsa_switch *ds, int port,
 		if (static_table[0] & ALU_V_STATIC_VALID) {
 			/* check this has same vid & mac address */
 
-			if (((static_table[2] >> ALU_V_FID_S) == (mdb->vid)) &&
+			if (((static_table[2] >> ALU_V_FID_S) == mdb->vid) &&
 			    ((static_table[2] & ALU_V_MAC_ADDR_HI) == mac_hi) &&
-			    (static_table[3] == mac_lo)) {
+			    static_table[3] == mac_lo) {
 				/* found matching one */
 				break;
 			}
-- 
1.9.1
