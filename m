From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 09/14] ipw2200: mark "iwconfig retry 255" as invalid
Date: Mon, 21 Aug 2006 11:38:17 +0800
Message-ID: <20060821033817.GA5398@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10576 "EHLO
	orsmga102-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S932587AbWHUDkS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Aug 2006 23:40:18 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ipw2200 firmware/ucode only support values from 0 to 254. So mark 255
as invalid.

Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 drivers/net/wireless/ipw2200.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

3ac6f33083c5f2e8900b06a29b124afd7b6e064f
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 0e5548a..e18fbca 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -9255,7 +9255,7 @@ static int ipw_wx_set_retry(struct net_d
 	if (!(wrqu->retry.flags & IW_RETRY_LIMIT))
 		return 0;
 
-	if (wrqu->retry.value < 0 || wrqu->retry.value > 255)
+	if (wrqu->retry.value < 0 || wrqu->retry.value >= 255)
 		return -EINVAL;
 
 	mutex_lock(&priv->mutex);
-- 
1.2.6
