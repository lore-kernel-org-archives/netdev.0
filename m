From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.13 2/5] e1000: correct rx_dropped counting
Date: Mon, 12 Sep 2005 10:48:59 -0400
Message-ID: <09122005104859.453@bilbo.tuxdriver.com>
References: <09122005104859.389@bilbo.tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.ronciak@intel.com, ganesh.venkatesan@intel.com,
	cramerj@intel.com, jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751374AbVILPAH@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
In-Reply-To: <09122005104859.389@bilbo.tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Do not count frames dropped by the hardware as part of rx_dropped.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/e1000/e1000_main.c |    1 -
 1 files changed, 1 deletion(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2544,7 +2544,6 @@ e1000_update_stats(struct e1000_adapter 
 		adapter->stats.crcerrs + adapter->stats.algnerrc +
 		adapter->stats.rlec + adapter->stats.mpc + 
 		adapter->stats.cexterr;
-	adapter->net_stats.rx_dropped = adapter->stats.mpc;
 	adapter->net_stats.rx_length_errors = adapter->stats.rlec;
 	adapter->net_stats.rx_crc_errors = adapter->stats.crcerrs;
 	adapter->net_stats.rx_frame_errors = adapter->stats.algnerrc;
