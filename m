From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 7/9] ixgb: replace netdev->priv with netdev_priv()
Date: Fri, 26 May 2006 09:52:09 -0700
Message-ID: <20060526165209.30514.64793.stgit@gitlost.site>
References: <20060526165124.30514.78477.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
        "Kok, Auke" <auke-jan.h.kok@intel.com>,
        "Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:34822 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1751135AbWEZQrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 May 2006 12:47:05 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060526165124.30514.78477.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


fix netdev->priv ==> netdev_priv(netdev)

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
---

 drivers/net/ixgb/ixgb_ethtool.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
index 6d8192f..949f69d 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -254,14 +254,14 @@ ixgb_set_tso(struct net_device *netdev, 
 static uint32_t
 ixgb_get_msglevel(struct net_device *netdev)
 {
-	struct ixgb_adapter *adapter = netdev->priv;
+	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	return adapter->msg_enable;
 }
 
 static void
 ixgb_set_msglevel(struct net_device *netdev, uint32_t data)
 {
-	struct ixgb_adapter *adapter = netdev->priv;
+	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	adapter->msg_enable = data;
 }
 #define IXGB_GET_STAT(_A_, _R_) _A_->stats._R_



--
Auke Kok <auke-jan.h.kok@intel.com>
