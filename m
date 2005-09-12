From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.13 4/5] ixgb: correct rx_dropped counting
Date: Mon, 12 Sep 2005 10:49:00 -0400
Message-ID: <09122005104900.585@bilbo.tuxdriver.com>
References: <09122005104859.522@bilbo.tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.ronciak@intel.com, ganesh.venkatesan@intel.com,
	ayyappan.veeraiyan@intel.com, jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751325AbVILO6P@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
In-Reply-To: <09122005104859.522@bilbo.tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Do not count frames dropped by the hardware as part of rx_dropped.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/ixgb/ixgb_main.c |    2 --
 1 files changed, 2 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1616,8 +1616,6 @@ ixgb_update_stats(struct ixgb_adapter *a
 	    adapter->stats.icbc +
 	    adapter->stats.ecbc + adapter->stats.mpc;
 
-	adapter->net_stats.rx_dropped = adapter->stats.mpc;
-
 	/* see above
 	 * adapter->net_stats.rx_length_errors = adapter->stats.rlec;
 	 */
