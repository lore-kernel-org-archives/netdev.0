From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 3/7] e1000e: convert to CYCLECOUNTER_MASK macro.
Date: Thu,  1 Jan 2015 11:39:57 +0100
Message-ID: <85522c713fd39cce2e6ac0874780b3f1d3465aad.1420108214.git.richardcochran@gmail.com>
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
 drivers/net/ethernet/intel/e1000e/netdev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index e14fd85..332a298 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4189,7 +4189,7 @@ static int e1000_sw_init(struct e1000_adapter *adapter)
 	/* Setup hardware time stamping cyclecounter */
 	if (adapter->flags & FLAG_HAS_HW_TIMESTAMP) {
 		adapter->cc.read = e1000e_cyclecounter_read;
-		adapter->cc.mask = CLOCKSOURCE_MASK(64);
+		adapter->cc.mask = CYCLECOUNTER_MASK(64);
 		adapter->cc.mult = 1;
 		/* cc.shift set in e1000e_get_base_tininca() */
 
-- 
1.7.10.4
