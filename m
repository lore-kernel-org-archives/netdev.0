From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 14/14] etherdevice: remove unused eth_addr_greater
Date: Thu,  9 Mar 2017 18:33:24 -0500
Message-ID: <20170309233324.18539-15-vivien.didelot@savoirfairelinux.com>
References: <20170309233324.18539-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170309233324.18539-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

eth_addr_greater() was introduced for the mv88e6xxx driver, but is not
used anymore. There is no other user, thus remove this function.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/linux/etherdevice.h | 15 ---------------
 1 file changed, 15 deletions(-)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index c62b709b1ce0..2d9f80848d4b 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -447,21 +447,6 @@ static inline void eth_addr_dec(u8 *addr)
 }
 
 /**
- * ether_addr_greater - Compare two Ethernet addresses
- * @addr1: Pointer to a six-byte array containing the Ethernet address
- * @addr2: Pointer other six-byte array containing the Ethernet address
- *
- * Compare two Ethernet addresses, returns true addr1 is greater than addr2
- */
-static inline bool ether_addr_greater(const u8 *addr1, const u8 *addr2)
-{
-	u64 u1 = ether_addr_to_u64(addr1);
-	u64 u2 = ether_addr_to_u64(addr2);
-
-	return u1 > u2;
-}
-
-/**
  * is_etherdev_addr - Tell if given Ethernet address belongs to the device.
  * @dev: Pointer to a device structure
  * @addr: Pointer to a six-byte array containing the Ethernet address
-- 
2.12.0
