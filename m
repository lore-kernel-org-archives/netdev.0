From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 7/7] be2net: remove adapter->eq_next_idx
Date: Wed, 7 Nov 2012 09:19:01 +0530
Message-ID: <1f62bc81-2588-4aa2-baad-2d2f314f4409@CMEXHTCAS2.ad.emulex.com>
References: <1352260141-27725-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:25379 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753876Ab2KGDqZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2012 22:46:25 -0500
In-Reply-To: <1352260141-27725-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's not used anywhere

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    2 --
 drivers/net/ethernet/emulex/benet/be_main.c |    2 --
 2 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 472d98e..abf26c7 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -375,9 +375,7 @@ struct be_adapter {
 	struct be_rx_obj rx_obj[MAX_RX_QS];
 	u32 big_page_size;	/* Compounded page size shared by rx wrbs */
 
-	u8 eq_next_idx;
 	struct be_drv_stats drv_stats;
-
 	u16 vlans_added;
 	u8 vlan_tag[VLAN_N_VID];
 	u8 vlan_prio_bmap;	/* Available Priority BitMap */
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index b2c72b8..c365722 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2762,8 +2762,6 @@ static void be_setup_init(struct be_adapter *adapter)
 	adapter->if_handle = -1;
 	adapter->be3_native = false;
 	adapter->promiscuous = false;
-	adapter->eq_next_idx = 0;
-
 	if (be_physfn(adapter))
 		adapter->cmd_privileges = MAX_PRIVILEGES;
 	else
-- 
1.7.1
