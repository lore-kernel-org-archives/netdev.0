From: Bruce Allan <bruce.w.allan@intel.com>
Subject: [net-next-2.6 RFC PATCH v2 12/13] sky2: set ethtool set_phys_id
	on/off cycle frequency to 1/sec
Date: Wed, 13 Apr 2011 12:59:49 -0700
Message-ID: <20110413195949.25901.86878.stgit@gitlad.jf.intel.com>
References: <20110413195146.25901.72193.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Bruce Allan <bruce.w.allan@intel.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:59404 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757854Ab1DMT7u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 15:59:50 -0400
In-Reply-To: <20110413195146.25901.72193.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Physical identification frequency based on how it was done prior to the
introduction of set_phys_id.  Compile tested only.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>
---

 drivers/net/sky2.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index a4b8fe5..c8d0451 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -3813,7 +3813,7 @@ static int sky2_set_phys_id(struct net_device *dev,
 
 	switch (state) {
 	case ETHTOOL_ID_ACTIVE:
-		return -EINVAL;
+		return 1;	/* cycle on/off once per second */
 	case ETHTOOL_ID_INACTIVE:
 		sky2_led(sky2, MO_LED_NORM);
 		break;

