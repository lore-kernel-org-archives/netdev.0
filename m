From: Bruce Allan <bruce.w.allan@intel.com>
Subject: [net-next-2.6 RFC PATCH v2 11/13] skge: set ethtool set_phys_id
	on/off cycle frequency to 2/sec
Date: Wed, 13 Apr 2011 12:59:43 -0700
Message-ID: <20110413195943.25901.90813.stgit@gitlad.jf.intel.com>
References: <20110413195146.25901.72193.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Bruce Allan <bruce.w.allan@intel.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:41125 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757484Ab1DMT7r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 15:59:47 -0400
In-Reply-To: <20110413195146.25901.72193.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Physical identification frequency based on how it was done prior to the
introduction of set_phys_id.  Compile tested only.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>
---

 drivers/net/skge.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 310dcbc..176d784 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -753,7 +753,7 @@ static int skge_set_phys_id(struct net_device *dev,
 
 	switch (state) {
 	case ETHTOOL_ID_ACTIVE:
-		return -EINVAL;
+		return 2;	/* cycle on/off twice per second */
 
 	case ETHTOOL_ID_ON:
 		skge_led(skge, LED_MODE_TST);

