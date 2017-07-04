From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 02/12] net: dsa: mv88e6xxx: remove LED control register
Date: Tue,  4 Jul 2017 19:41:45 -0400
Message-ID: <20170704234155.24360-3-vivien.didelot@savoirfairelinux.com>
References: <20170704234155.24360-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170704234155.24360-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We don't support LED control yet, remove its register definition.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/port.h | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index 8f3991bf1851..b16d5f0e6e9c 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -216,9 +216,6 @@
 /* Offset 0x13: OutFiltered Counter */
 #define MV88E6XXX_PORT_OUT_FILTERED	0x13
 
-/* Offset 0x16: LED Control */
-#define MV88E6XXX_PORT_LED_CONTROL	0x16
-
 /* Offset 0x18: IEEE Priority Mapping Table */
 #define MV88E6390_PORT_IEEE_PRIO_MAP_TABLE			0x18
 #define MV88E6390_PORT_IEEE_PRIO_MAP_TABLE_UPDATE		0x8000
-- 
2.13.2
