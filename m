From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 4/7] igb: convert to CYCLECOUNTER_MASK macro.
Date: Thu,  1 Jan 2015 11:39:58 +0100
Message-ID: <09f5c9167282b3b5a14362495550459e0ceb6919.1420108214.git.richardcochran@gmail.com>
References: <20141231.183347.862533634176009078.davem@davemloft.net>
Cc: <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141231.183347.862533634176009078.davem@davemloft.net>
In-Reply-To: <cover.1420108214.git.richardcochran@gmail.com>
References: <cover.1420108214.git.richardcochran@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/intel/igb/igb_ptp.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index 1d27f2d..5e7a4e3 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -765,7 +765,7 @@ void igb_ptp_init(struct igb_adapter *adapter)
 		adapter->ptp_caps.settime = igb_ptp_settime_82576;
 		adapter->ptp_caps.enable = igb_ptp_feature_enable;
 		adapter->cc.read = igb_ptp_read_82576;
-		adapter->cc.mask = CLOCKSOURCE_MASK(64);
+		adapter->cc.mask = CYCLECOUNTER_MASK(64);
 		adapter->cc.mult = 1;
 		adapter->cc.shift = IGB_82576_TSYNC_SHIFT;
 		/* Dial the nominal frequency. */
@@ -785,7 +785,7 @@ void igb_ptp_init(struct igb_adapter *adapter)
 		adapter->ptp_caps.settime = igb_ptp_settime_82576;
 		adapter->ptp_caps.enable = igb_ptp_feature_enable;
 		adapter->cc.read = igb_ptp_read_82580;
-		adapter->cc.mask = CLOCKSOURCE_MASK(IGB_NBITS_82580);
+		adapter->cc.mask = CYCLECOUNTER_MASK(IGB_NBITS_82580);
 		adapter->cc.mult = 1;
 		adapter->cc.shift = 0;
 		/* Enable the timer functions by clearing bit 31. */
-- 
1.7.10.4
