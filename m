From: Bruce Allan <bruce.w.allan@intel.com>
Subject: [net-next-2.6 RFC PATCH v2 07/13] niu: set ethtool set_phys_id on/off
	cycle frequency to 1/sec
Date: Wed, 13 Apr 2011 12:59:22 -0700
Message-ID: <20110413195922.25901.4053.stgit@gitlad.jf.intel.com>
References: <20110413195146.25901.72193.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Bruce Allan <bruce.w.allan@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:7608 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752681Ab1DMT73 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 15:59:29 -0400
In-Reply-To: <20110413195146.25901.72193.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Physical identification frequency based on how it was done prior to the
introduction of set_phys_id.  Compile tested only.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
---

 drivers/net/niu.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 3fa1e9c..ea2272f 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -7896,7 +7896,7 @@ static int niu_set_phys_id(struct net_device *dev,
 	switch (state) {
 	case ETHTOOL_ID_ACTIVE:
 		np->orig_led_state = niu_led_state_save(np);
-		return -EINVAL;
+		return 1;	/* cycle on/off once per second */
 
 	case ETHTOOL_ID_ON:
 		niu_force_led(np, 1);

