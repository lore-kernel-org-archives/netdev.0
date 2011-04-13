From: Bruce Allan <bruce.w.allan@intel.com>
Subject: [net-next-2.6 RFC PATCH v2 08/13] pcnet32: set ethtool set_phys_id
	on/off cycle frequency to 2/sec
Date: Wed, 13 Apr 2011 12:59:27 -0700
Message-ID: <20110413195927.25901.35278.stgit@gitlad.jf.intel.com>
References: <20110413195146.25901.72193.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Bruce Allan <bruce.w.allan@intel.com>,
	Don Fry <pcnet32@frontier.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:24295 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757725Ab1DMT7c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 15:59:32 -0400
In-Reply-To: <20110413195146.25901.72193.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Physical identification frequency based on how it was done prior to the
introduction of set_phys_id.  Compile tested only.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Cc: Don Fry <pcnet32@frontier.com>
---

 drivers/net/pcnet32.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index e89afb9..0a1efba 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -1038,7 +1038,7 @@ static int pcnet32_set_phys_id(struct net_device *dev,
 		for (i = 4; i < 8; i++)
 			lp->save_regs[i - 4] = a->read_bcr(ioaddr, i);
 		spin_unlock_irqrestore(&lp->lock, flags);
-		return -EINVAL;
+		return 2;	/* cycle on/off twice per second */
 
 	case ETHTOOL_ID_ON:
 	case ETHTOOL_ID_OFF:

