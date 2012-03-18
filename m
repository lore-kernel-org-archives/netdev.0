From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [net-next PATCH 3/4] be2net: Fix number of vlan slots in flex mode
Date: Sun, 18 Mar 2012 11:23:31 -0500
Message-ID: <20120318162331.GA7681@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:59901 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755750Ab2CRQYL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Mar 2012 12:24:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In flex10 mode the number of vlan slots supported is halved.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index b4348b8..1c84bc8 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3292,7 +3292,7 @@ static int be_get_config(struct be_adapter *adapter)
 		return status;
 
 	if (adapter->function_mode & FLEX10_MODE)
-		adapter->max_vlans = BE_NUM_VLANS_SUPPORTED/4;
+		adapter->max_vlans = BE_NUM_VLANS_SUPPORTED/8;
 	else
 		adapter->max_vlans = BE_NUM_VLANS_SUPPORTED;
 
-- 
1.7.5.4
