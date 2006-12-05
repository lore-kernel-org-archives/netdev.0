From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 5/5] ipw2200: Fix debug output endian issue
Date: Tue, 5 Dec 2006 14:41:40 +0800
Message-ID: <20061205064140.GA18296@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:38998 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759339AbWLEHJc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 02:09:32 -0500
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 drivers/net/wireless/ipw2200.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

7c609b56727b70a61fd28f51a445c0e032d47ef0
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 2b29396..5de7ee7 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -8285,7 +8285,7 @@ static void ipw_rx(struct ipw_priv *priv
 				    ("Notification: subtype=%02X flags=%02X size=%d\n",
 				     pkt->u.notification.subtype,
 				     pkt->u.notification.flags,
-				     pkt->u.notification.size);
+				     le16_to_cpu(pkt->u.notification.size));
 				ipw_rx_notification(priv, &pkt->u.notification);
 				break;
 			}
-- 
1.2.6
