From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 10/15] be2net: Fix broken priority setting when
 vlan tagging is enabled.
Date: Fri, 11 Feb 2011 17:37:25 -0600
Message-ID: <20110211233725.GA18440@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:51236 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756892Ab1BKXho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 18:37:44 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be_cmds.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 277982b..8fa9a70 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -102,6 +102,7 @@ static void be_async_grp5_cos_priority_process(struct be_adapter *adapter,
 {
 	if (evt->valid) {
 		adapter->vlan_prio_bmap = evt->available_priority_bmap;
+		adapter->recommended_prio &= ~VLAN_PRIO_MASK;
 		adapter->recommended_prio =
 			evt->reco_default_priority << VLAN_PRIO_SHIFT;
 	}
-- 
1.7.1

