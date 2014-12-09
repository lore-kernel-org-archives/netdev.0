From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 13/13] i40e/i40evf: Convert macro to static inline
Date: Tue,  9 Dec 2014 13:26:20 -0800
Message-ID: <1418160380-29847-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1418160380-29847-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:56965 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753158AbaLIV07 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 16:26:59 -0500
In-Reply-To: <1418160380-29847-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Inline functions are preferred over macros when they can be used
interchangeably.

CC: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Reported-by: Joe Perches <joe@perches.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
v2:
 - remove unnecessary parens in the return statement as suggested
   by Sergei Shtylyov

 drivers/net/ethernet/intel/i40e/i40e_type.h   | 5 ++++-
 drivers/net/ethernet/intel/i40evf/i40e_type.h | 5 ++++-
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 844421f..c1f2eb9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -481,7 +481,10 @@ struct i40e_hw {
 	u32 debug_mask;
 };
 
-#define i40e_is_vf(_hw)	((_hw)->mac.type == I40E_MAC_VF)
+static inline bool i40e_is_vf(struct i40e_hw *hw)
+{
+	return hw->mac.type == I40E_MAC_VF;
+}
 
 struct i40e_driver_version {
 	u8 major_version;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index d8175cd..68aec11 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -475,7 +475,10 @@ struct i40e_hw {
 	u32 debug_mask;
 };
 
-#define i40e_is_vf(_hw)	((_hw)->mac.type == I40E_MAC_VF)
+static inline bool i40e_is_vf(struct i40e_hw *hw)
+{
+	return hw->mac.type == I40E_MAC_VF;
+}
 
 struct i40e_driver_version {
 	u8 major_version;
-- 
1.9.3
