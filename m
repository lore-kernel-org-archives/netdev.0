From: Bruce Allan <bruce.w.allan@intel.com>
Subject: [net-next-2.6 RFC PATCH v2 04/13] bnx2x: set ethtool set_phys_id
	on/off cycle frequency to 1/sec
Date: Wed, 13 Apr 2011 12:59:07 -0700
Message-ID: <20110413195906.25901.58655.stgit@gitlad.jf.intel.com>
References: <20110413195146.25901.72193.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Bruce Allan <bruce.w.allan@intel.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:61628 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758516Ab1DMT7J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 15:59:09 -0400
In-Reply-To: <20110413195146.25901.72193.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Physical identification frequency based on how it was done prior to the
introduction of set_phys_id.  Compile tested only.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Cc: Eilon Greenstein <eilong@broadcom.com>
---

 drivers/net/bnx2x/bnx2x_ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2x_ethtool.c
index ad7d91e..0a5e88d 100644
--- a/drivers/net/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c
@@ -2025,7 +2025,7 @@ static int bnx2x_set_phys_id(struct net_device *dev,
 
 	switch (state) {
 	case ETHTOOL_ID_ACTIVE:
-		return -EINVAL;
+		return 1;	/* cycle on/off once per second */
 
 	case ETHTOOL_ID_ON:
 		bnx2x_set_led(&bp->link_params, &bp->link_vars,

