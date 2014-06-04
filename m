From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 3/7] igb: rename igb_ptp_enable to igb_ptp_feature_enable
Date: Wed,  4 Jun 2014 00:04:56 -0700
Message-ID: <1401865500-18081-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401865500-18081-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:21696 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755308AbaFDHFF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2014 03:05:05 -0400
In-Reply-To: <1401865500-18081-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The name igb_ptp_enable is not synonymous with the purpose of this
function, so rename it to better explain its purpose.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

---
v2: Fix indentation on wrapped line based on feedback from David Miller

 drivers/net/ethernet/intel/igb/igb_ptp.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index ab25e49..e291be2 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -360,8 +360,8 @@ static int igb_ptp_settime_i210(struct ptp_clock_info *ptp,
 	return 0;
 }
 
-static int igb_ptp_enable(struct ptp_clock_info *ptp,
-			  struct ptp_clock_request *rq, int on)
+static int igb_ptp_feature_enable(struct ptp_clock_info *ptp,
+				  struct ptp_clock_request *rq, int on)
 {
 	return -EOPNOTSUPP;
 }
@@ -745,7 +745,7 @@ void igb_ptp_init(struct igb_adapter *adapter)
 		adapter->ptp_caps.adjtime = igb_ptp_adjtime_82576;
 		adapter->ptp_caps.gettime = igb_ptp_gettime_82576;
 		adapter->ptp_caps.settime = igb_ptp_settime_82576;
-		adapter->ptp_caps.enable = igb_ptp_enable;
+		adapter->ptp_caps.enable = igb_ptp_feature_enable;
 		adapter->cc.read = igb_ptp_read_82576;
 		adapter->cc.mask = CLOCKSOURCE_MASK(64);
 		adapter->cc.mult = 1;
@@ -765,7 +765,7 @@ void igb_ptp_init(struct igb_adapter *adapter)
 		adapter->ptp_caps.adjtime = igb_ptp_adjtime_82576;
 		adapter->ptp_caps.gettime = igb_ptp_gettime_82576;
 		adapter->ptp_caps.settime = igb_ptp_settime_82576;
-		adapter->ptp_caps.enable = igb_ptp_enable;
+		adapter->ptp_caps.enable = igb_ptp_feature_enable;
 		adapter->cc.read = igb_ptp_read_82580;
 		adapter->cc.mask = CLOCKSOURCE_MASK(IGB_NBITS_82580);
 		adapter->cc.mult = 1;
@@ -784,7 +784,7 @@ void igb_ptp_init(struct igb_adapter *adapter)
 		adapter->ptp_caps.adjtime = igb_ptp_adjtime_i210;
 		adapter->ptp_caps.gettime = igb_ptp_gettime_i210;
 		adapter->ptp_caps.settime = igb_ptp_settime_i210;
-		adapter->ptp_caps.enable = igb_ptp_enable;
+		adapter->ptp_caps.enable = igb_ptp_feature_enable;
 		/* Enable the timer functions by clearing bit 31. */
 		wr32(E1000_TSAUXC, 0x0);
 		break;
-- 
1.9.3
