From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: [PATCH] phy: remove documentation of removed member addr of phy_device structure
Date: Thu,  3 Mar 2016 14:12:28 +0100
Message-ID: <1457010748-2584-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	LABBE Corentin <clabbe.montjoie@gmail.com>
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit e5a03bfd873c ("phy: Add an mdio_device structure") removed
the addr member of the phy_device structure.
This patch remove the documentation about that member.

Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>
---
 include/linux/phy.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index d6f3641..e14569e 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -338,7 +338,6 @@ struct phy_c45_device_ids {
  * suspended: Set to true if this phy has been suspended successfully.
  * state: state of the PHY for management purposes
  * dev_flags: Device-specific flags used by the PHY driver.
- * addr: Bus address of PHY
  * link_timeout: The number of timer firings to wait before the
  * giving up on the current attempt at acquiring a link
  * irq: IRQ number of the PHY's interrupt (-1 if none)
-- 
2.4.10
