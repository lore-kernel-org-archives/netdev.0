From: Sathya Perla <sathya.perla@avagotech.com>
Subject: [PATCH net-next v3 07/10] be2net: remove unused error variables
Date: Wed, 30 Dec 2015 01:29:02 -0500
Message-ID: <1451456945-31606-8-git-send-email-sathya.perla@avagotech.com>
References: <1451456945-31606-1-git-send-email-sathya.perla@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:50633 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754341AbbL3G3V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 01:29:21 -0500
In-Reply-To: <1451456945-31606-1-git-send-email-sathya.perla@avagotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Venkat Duvvuru <venkatkumar.duvvuru@avagotech.com>

eeh_error, fw_timeout, hw_error variables in the be_adapter structure are
not used anymore. An earlier patch that introduced adapter->err_flags to
store this information missed removing these variables.

Signed-off-by: Venkat Duvvuru <venkatkumar.duvvuru@avagotech.com>
Signed-off-by: Sathya Perla <sathya.perla@avagotech.com>
---
 drivers/net/ethernet/emulex/benet/be.h | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 93e5eab..0af32f1 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -547,10 +547,6 @@ struct be_adapter {
 
 	u32 beacon_state;	/* for set_phys_id */
 
-	bool eeh_error;
-	bool fw_timeout;
-	bool hw_error;
-
 	u32 port_num;
 	char port_name;
 	u8 mc_type;
-- 
2.4.1
