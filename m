From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/17] i40e: Removed unused defines
Date: Thu, 15 Oct 2015 14:43:15 -0700
Message-ID: <1444945404-30654-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444945404-30654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:32107 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753251AbbJOVnb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2015 17:43:31 -0400
In-Reply-To: <1444945404-30654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Two defines that are not used are causing customer confusion - remove
them.

Change-ID: Icef0325aca8e0f4fcdfc519e026bdd375e791200
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
index 736f6f0..7fe94e8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
@@ -29,8 +29,6 @@
 
 #include "i40e.h"
 
-#define I40E_MAX_MACVLAN_FILTERS 256
-#define I40E_MAX_VLAN_FILTERS 256
 #define I40E_MAX_VLANID 4095
 
 #define I40E_VIRTCHNL_SUPPORTED_QTYPES 2
-- 
2.4.3
