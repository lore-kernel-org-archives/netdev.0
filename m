From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/14] i40evf: drop i40e_type.h include
Date: Thu,  1 Jun 2017 14:38:27 -0700
Message-ID: <20170601213840.36286-2-jeffrey.t.kirsher@intel.com>
References: <20170601213840.36286-1-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:40283 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751140AbdFAVi6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Jun 2017 17:38:58 -0400
In-Reply-To: <20170601213840.36286-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

This drops the i40e_type.h include in anticipation of the next
patch which moves this file to a location where type.h doesn't
exist, and all the places this file is included already include
i40e_type.h before this file.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h b/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
index b0b8de5d6f57..7d6da3ac24f4 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
@@ -27,8 +27,6 @@
 #ifndef _I40E_VIRTCHNL_H_
 #define _I40E_VIRTCHNL_H_
 
-#include "i40e_type.h"
-
 /* Description:
  * This header file describes the VF-PF communication protocol used
  * by the various i40e drivers.
-- 
2.12.2
