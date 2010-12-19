From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: [PATCH 4/4] net: phy: EXPORT_SYMBOL not following the function
Date: Sun, 19 Dec 2010 11:58:51 +0100
Message-ID: <1292756331-3735-4-git-send-email-jhautbois@gmail.com>
References: <1292756331-3735-1-git-send-email-jhautbois@gmail.com>
Cc: richard.cochran@omicron.at, shemminger@vyatta.com, tj@kernel.org,
	randy.dunlap@oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Jean-Michel Hautbois <jhautbois@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1292756331-3735-1-git-send-email-jhautbois@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The symbol phy_stop was not following the related function.

Signed-off-by: Jean-Michel Hautbois <jhautbois@gmail.com>
---
 drivers/net/phy/phy.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 87a64c0..ed503cd 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -732,6 +732,7 @@ out_unlock:
 	 * will not reenable interrupts.
 	 */
 }
+EXPORT_SYMBOL(phy_stop);
 
 
 /**
@@ -762,7 +763,6 @@ void phy_start(struct phy_device *phydev)
 	}
 	mutex_unlock(&phydev->lock);
 }
-EXPORT_SYMBOL(phy_stop);
 EXPORT_SYMBOL(phy_start);
 
 /**
-- 
1.7.0.4
