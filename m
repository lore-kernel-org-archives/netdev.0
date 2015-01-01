From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 5/7] ixgbe: convert to CYCLECOUNTER_MASK macro.
Date: Thu,  1 Jan 2015 11:39:59 +0100
Message-ID: <22de72fbea439dfa93bcfd835b56e3e5f756a055.1420108214.git.richardcochran@gmail.com>
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
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index 47c29ea..79c00f5 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -793,7 +793,7 @@ void ixgbe_ptp_start_cyclecounter(struct ixgbe_adapter *adapter)
 
 	memset(&adapter->cc, 0, sizeof(adapter->cc));
 	adapter->cc.read = ixgbe_ptp_read;
-	adapter->cc.mask = CLOCKSOURCE_MASK(64);
+	adapter->cc.mask = CYCLECOUNTER_MASK(64);
 	adapter->cc.shift = shift;
 	adapter->cc.mult = 1;
 
-- 
1.7.10.4
