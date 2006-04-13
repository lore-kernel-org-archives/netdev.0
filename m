From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 17/18] ipw2200: remove priv->last_noise reference
Date: Thu, 13 Apr 2006 17:21:06 +0800
Message-ID: <20060413092106.GA28822@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr19.intel.com ([134.134.136.18]:39373 "EHLO
	orsfmr004.jf.intel.com") by vger.kernel.org with ESMTP
	id S964856AbWDMJ2K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 05:28:10 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

priv->last_noise is not used with the exponential averaging algorithm

Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 drivers/net/wireless/ipw2200.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

56992321cbe73f5dbdf93464d6cbe75b83a1e37d
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 62ebec8..7825655 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -7793,9 +7793,6 @@ static void ipw_handle_promiscuous_rx(st
 	if (filter & IPW_PROM_NO_RX)
 		return;
 
-	if (!noise)
-		noise = priv->last_noise;
-
 	/* We received data from the HW, so stop the watchdog */
 	priv->prom_net_dev->trans_start = jiffies;
 
-- 
1.2.6

