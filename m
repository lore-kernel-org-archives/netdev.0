From: Bruce Allan <bruce.w.allan@intel.com>
Subject: [net-next-2.6 RFC PATCH v2 09/13] s2io: set ethtool set_phys_id
	on/off cycle frequency to 1/sec
Date: Wed, 13 Apr 2011 12:59:32 -0700
Message-ID: <20110413195932.25901.69381.stgit@gitlad.jf.intel.com>
References: <20110413195146.25901.72193.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Bruce Allan <bruce.w.allan@intel.com>, Jon Mason <jdmason@kudzu.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:24295 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757725Ab1DMT7e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 15:59:34 -0400
In-Reply-To: <20110413195146.25901.72193.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Physical identification frequency based on how it was done prior to the
introduction of set_phys_id.  Compile tested only.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Cc: Jon Mason <jdmason@kudzu.us>
---

 drivers/net/s2io.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 2d5cc61..2302d97 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -5541,7 +5541,7 @@ static int s2io_ethtool_set_led(struct net_device *dev,
 	switch (state) {
 	case ETHTOOL_ID_ACTIVE:
 		sp->adapt_ctrl_org = readq(&bar0->gpio_control);
-		return -EINVAL;
+		return 1;	/* cycle on/off once per second */
 
 	case ETHTOOL_ID_ON:
 		s2io_set_led(sp, true);

