From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/18] i40e/i40evf: Remove I40E_MAX_USER_PRIORITY define
Date: Tue,  5 Apr 2016 13:17:24 -0700
Message-ID: <1459887455-146634-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459887455-146634-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10824 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759969AbcDEURk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 16:17:40 -0400
In-Reply-To: <1459887455-146634-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

This patch removes the duplicate definition of I40E_MAX_USER_PRIORITY
in i40e.h that is not needed.

Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index f208570..d25b3be 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -244,7 +244,6 @@ struct i40e_fdir_filter {
 #define I40E_DCB_PRIO_TYPE_STRICT	0
 #define I40E_DCB_PRIO_TYPE_ETS		1
 #define I40E_DCB_STRICT_PRIO_CREDITS	127
-#define I40E_MAX_USER_PRIORITY	8
 /* DCB per TC information data structure */
 struct i40e_tc_info {
 	u16	qoffset;	/* Queue offset from base queue */
-- 
2.5.5
