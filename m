From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/13] fm10k: fix typos on fall through comments
Date: Mon,  2 Oct 2017 08:42:28 -0700
Message-ID: <20171002154236.84043-6-jeffrey.t.kirsher@intel.com>
References: <20171002154236.84043-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:24370 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751689AbdJBPm7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 11:42:59 -0400
In-Reply-To: <20171002154236.84043-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Newer versions of GCC since version 7 now warn when a case statement may
fall through without an explicit comment. "Fallthough" does not count as
it is misspelled. Fix the typos for these comments to appease the new
warnings.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_mbx.c |  4 ++--
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c  | 10 +++++-----
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c b/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
index 334088a101c3..244d3ad58ca7 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
@@ -1,5 +1,5 @@
 /* Intel(R) Ethernet Switch Host Interface Driver
- * Copyright(c) 2013 - 2016 Intel Corporation.
+ * Copyright(c) 2013 - 2017 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -1586,7 +1586,7 @@ s32 fm10k_pfvf_mbx_init(struct fm10k_hw *hw, struct fm10k_mbx_info *mbx,
 			mbx->mbmem_reg = FM10K_MBMEM_VF(id, 0);
 			break;
 		}
-		/* fallthough */
+		/* fall through */
 	default:
 		return FM10K_MBX_ERR_NO_MBX;
 	}
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index 40ee0242a80a..9e4fb3a44376 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -1,5 +1,5 @@
 /* Intel(R) Ethernet Switch Host Interface Driver
- * Copyright(c) 2013 - 2016 Intel Corporation.
+ * Copyright(c) 2013 - 2017 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -1334,19 +1334,19 @@ static u8 fm10k_iov_supported_xcast_mode_pf(struct fm10k_vf_info *vf_info,
 	case FM10K_XCAST_MODE_PROMISC:
 		if (vf_flags & FM10K_VF_FLAG_PROMISC_CAPABLE)
 			return FM10K_XCAST_MODE_PROMISC;
-		/* fallthough */
+		/* fall through */
 	case FM10K_XCAST_MODE_ALLMULTI:
 		if (vf_flags & FM10K_VF_FLAG_ALLMULTI_CAPABLE)
 			return FM10K_XCAST_MODE_ALLMULTI;
-		/* fallthough */
+		/* fall through */
 	case FM10K_XCAST_MODE_MULTI:
 		if (vf_flags & FM10K_VF_FLAG_MULTI_CAPABLE)
 			return FM10K_XCAST_MODE_MULTI;
-		/* fallthough */
+		/* fall through */
 	case FM10K_XCAST_MODE_NONE:
 		if (vf_flags & FM10K_VF_FLAG_NONE_CAPABLE)
 			return FM10K_XCAST_MODE_NONE;
-		/* fallthough */
+		/* fall through */
 	default:
 		break;
 	}
-- 
2.14.2
