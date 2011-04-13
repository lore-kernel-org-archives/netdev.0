From: Bruce Allan <bruce.w.allan@intel.com>
Subject: [net-next-2.6 RFC PATCH v2 03/13] bnx2: set ethtool set_phys_id
	on/off cycle frequency to 1/sec
Date: Wed, 13 Apr 2011 12:59:01 -0700
Message-ID: <20110413195901.25901.99193.stgit@gitlad.jf.intel.com>
References: <20110413195146.25901.72193.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Bruce Allan <bruce.w.allan@intel.com>,
	Michael Chan <mchan@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:13117 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758509Ab1DMT7D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 15:59:03 -0400
In-Reply-To: <20110413195146.25901.72193.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Physical identification frequency based on how it was done prior to the
introduction of set_phys_id.  Compile tested only.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Cc: Michael Chan <mchan@broadcom.com>
---

 drivers/net/bnx2.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 0a52079..bf729ee 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -7473,7 +7473,7 @@ bnx2_set_phys_id(struct net_device *dev, enum ethtool_phys_id_state state)
 
 		bp->leds_save = REG_RD(bp, BNX2_MISC_CFG);
 		REG_WR(bp, BNX2_MISC_CFG, BNX2_MISC_CFG_LEDMODE_MAC);
-		return -EINVAL;
+		return 1;	/* cycle on/off once per second */
 
 	case ETHTOOL_ID_ON:
 		REG_WR(bp, BNX2_EMAC_LED, BNX2_EMAC_LED_OVERRIDE |

