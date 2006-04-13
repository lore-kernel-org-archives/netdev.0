From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 07/18] ipw2200: turn off signal debug log
Date: Thu, 13 Apr 2006 17:19:55 +0800
Message-ID: <20060413091955.GA28748@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr17.intel.com ([134.134.136.16]:25002 "EHLO
	orsfmr002.jf.intel.com") by vger.kernel.org with ESMTP
	id S964845AbWDMJ1C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 05:27:02 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 drivers/net/wireless/ipw2200.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

c4613fd635d134e567b64de4d89fe54a7b0f88b2
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index febee43..057faa0 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -4033,7 +4033,7 @@ static void ipw_gather_stats(struct ipw_
 	else if (signal_quality < 1)
 		signal_quality = 0;
 
-	IPW_ERROR("Signal level : %3d%% (%d dBm)\n",
+	IPW_DEBUG_STATS("Signal level : %3d%% (%d dBm)\n",
 			signal_quality, rssi);
 
 	quality = min(beacon_quality,
-- 
1.2.6

