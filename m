From: Bruce Allan <bruce.w.allan@intel.com>
Subject: [net-next-2.6 RFC PATCH v2 02/13] benet: set ethtool set_phys_id
	on/off cycle frequency to 1/sec
Date: Wed, 13 Apr 2011 12:58:56 -0700
Message-ID: <20110413195856.25901.87799.stgit@gitlad.jf.intel.com>
References: <20110413195146.25901.72193.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Bruce Allan <bruce.w.allan@intel.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:13117 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758503Ab1DMT66 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 15:58:58 -0400
In-Reply-To: <20110413195146.25901.72193.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Physical identification frequency based on how it was done prior to the
introduction of set_phys_id.  Compile tested only.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Cc: Sathya Perla <sathya.perla@emulex.com>
Cc: Subbu Seetharaman <subbu.seetharaman@emulex.com>
Cc: Ajit Khaparde <ajit.khaparde@emulex.com>
---

 drivers/net/benet/be_ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index 96f5502..80226e4 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -516,7 +516,7 @@ be_set_phys_id(struct net_device *netdev,
 	case ETHTOOL_ID_ACTIVE:
 		be_cmd_get_beacon_state(adapter, adapter->hba_port_num,
 					&adapter->beacon_state);
-		return -EINVAL;
+		return 1;	/* cycle on/off once per second */
 
 	case ETHTOOL_ID_ON:
 		be_cmd_set_beacon_state(adapter, adapter->hba_port_num, 0, 0,

