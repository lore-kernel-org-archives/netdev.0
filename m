From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH v2 3/6] net: dsa: mv88e6060: use the correct MaxFrameSize bit
Date: Tue, 10 Nov 2015 16:51:24 +0100
Message-ID: <5642127C.4090703@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Guenter Roeck <linux@roeck-us.net>,
	Neil Armstrong <narmstrong@baylibre.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

According to the mv88e6060 datasheet, the MaxFrameSize bit position
is 10 instead of 11 which is reserved.
Use the bit correctly to setup max frame size to 1536.

Acked-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 drivers/net/dsa/mv88e6060.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
index eff5e18..10647ad 100644
--- a/drivers/net/dsa/mv88e6060.c
+++ b/drivers/net/dsa/mv88e6060.c
@@ -119,7 +119,7 @@ static int mv88e6060_setup_global(struct dsa_switch *ds)
 	 * set the maximum frame size to 1536 bytes, and mask all
 	 * interrupt sources.
 	 */
-	REG_WRITE(REG_GLOBAL, 0x04, 0x0800);
+	REG_WRITE(REG_GLOBAL, 0x04, 0x400);

 	/* Enable automatic address learning, set the address
 	 * database size to 1024 entries, and set the default aging
-- 
1.9.1
