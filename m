From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 08/18] ipw2200: Set the 'fixed' flags in wext get_rate
Date: Thu, 13 Apr 2006 17:20:05 +0800
Message-ID: <20060413092005.GA28755@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr20.intel.com ([134.134.136.19]:65456 "EHLO
	orsfmr005.jf.intel.com") by vger.kernel.org with ESMTP
	id S964849AbWDMJ1J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 05:27:09 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jean Tourrilhes <jt@hpl.hp.com>
Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 drivers/net/wireless/ipw2200.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

773cfa85e3c221a9d8284da73ff9e087e98dea12
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 057faa0..4b02920 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -8759,6 +8759,7 @@ static int ipw_wx_get_rate(struct net_de
 	struct ipw_priv *priv = ieee80211_priv(dev);
 	mutex_lock(&priv->mutex);
 	wrqu->bitrate.value = priv->last_rate;
+	wrqu->bitrate.fixed = (priv->config & CFG_FIXED_RATE) ? 1 : 0;
 	mutex_unlock(&priv->mutex);
 	IPW_DEBUG_WX("GET Rate -> %d \n", wrqu->bitrate.value);
 	return 0;
-- 
1.2.6

