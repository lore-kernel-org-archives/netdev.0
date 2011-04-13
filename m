From: Bruce Allan <bruce.w.allan@intel.com>
Subject: [net-next-2.6 RFC PATCH v2 06/13] ewrk3: set ethtool set_phys_id
	on/off cycle frequency to 2/sec
Date: Wed, 13 Apr 2011 12:59:17 -0700
Message-ID: <20110413195917.25901.70133.stgit@gitlad.jf.intel.com>
References: <20110413195146.25901.72193.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Bruce Allan <bruce.w.allan@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:42247 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758520Ab1DMT7T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 15:59:19 -0400
In-Reply-To: <20110413195146.25901.72193.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Physical identification frequency based on how it was done prior to the
introduction of set_phys_id.  Not tested.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
---

 drivers/net/ewrk3.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ewrk3.c b/drivers/net/ewrk3.c
index c7ce443..17b6027 100644
--- a/drivers/net/ewrk3.c
+++ b/drivers/net/ewrk3.c
@@ -1618,7 +1618,7 @@ static int ewrk3_set_phys_id(struct net_device *dev,
 		/* Prevent ISR from twiddling the LED */
 		lp->led_mask = 0;
 		spin_unlock_irq(&lp->hw_lock);
-		return -EINVAL;
+		return 2;	/* cycle on/off twice per second */
 
 	case ETHTOOL_ID_ON:
 		cr = inb(EWRK3_CR);

