From: Johan Hovold <johan@kernel.org>
Subject: [PATCH 13/22] net: phy: add static data field to struct phy_driver
Date: Tue, 11 Nov 2014 18:37:31 +0100
Message-ID: <1415727460-20417-14-git-send-email-johan@kernel.org>
References: <1415727460-20417-1-git-send-email-johan@kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Johan Hovold <johan@kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415727460-20417-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add static data field to struct phy_driver that be used to store
structured device-type information.

Signed-off-by: Johan Hovold <johan@kernel.org>
---
 include/linux/phy.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index c50e1f1f46e0..29c260add1f6 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -433,6 +433,7 @@ struct phy_device {
  *   by this PHY
  * flags: A bitfield defining certain other features this PHY
  *   supports (like interrupts)
+ * driver_data: static driver data
  *
  * The drivers must implement config_aneg and read_status.  All
  * other functions are optional. Note that none of these
@@ -448,6 +449,7 @@ struct phy_driver {
 	unsigned int phy_id_mask;
 	u32 features;
 	u32 flags;
+	const void *driver_data;
 
 	/*
 	 * Called to issue a PHY software reset
-- 
2.0.4
