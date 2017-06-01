From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/14] i40e/i40evf: create and use new unified header file
Date: Thu,  1 Jun 2017 14:38:28 -0700
Message-ID: <20170601213840.36286-3-jeffrey.t.kirsher@intel.com>
References: <20170601213840.36286-1-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:40283 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751050AbdFAVi6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Jun 2017 17:38:58 -0400
In-Reply-To: <20170601213840.36286-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

This moves a header for i40evf to include/linux/avf/virtchnl.h.
The directory name AVF is an acronym for the Intel(R) Adaptive
Virtual Function.

This first step creates the new file, which is a rename of
drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h to
include/linux/avf/virtchnl.h, and should show up in git
as a rename when using git log --follow.

To keep things building after the move, the changes to the i40evf
driver are made to point to the new include file location.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                                             | 1 +
 drivers/net/ethernet/intel/i40evf/i40e_common.c                         | 2 +-
 drivers/net/ethernet/intel/i40evf/i40e_prototype.h                      | 2 +-
 drivers/net/ethernet/intel/i40evf/i40evf.h                              | 2 +-
 .../intel/i40evf/i40e_virtchnl.h => include/linux/avf/virtchnl.h        | 0
 5 files changed, 4 insertions(+), 3 deletions(-)
 rename drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h => include/linux/avf/virtchnl.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 0fcb5e751ca7..6b7625ff9875 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6738,6 +6738,7 @@ F:	Documentation/networking/i40e.txt
 F:	Documentation/networking/i40evf.txt
 F:	drivers/net/ethernet/intel/
 F:	drivers/net/ethernet/intel/*/
+F:	include/linux/avf/virtchnl.h
 
 INTEL RDMA RNIC DRIVER
 M:     Faisal Latif <faisal.latif@intel.com>
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_common.c b/drivers/net/ethernet/intel/i40evf/i40e_common.c
index 6729624fda5b..1db028ac96f4 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_common.c
@@ -27,7 +27,7 @@
 #include "i40e_type.h"
 #include "i40e_adminq.h"
 #include "i40e_prototype.h"
-#include "i40e_virtchnl.h"
+#include <linux/avf/virtchnl.h>
 
 /**
  * i40e_set_mac_type - Sets MAC type
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_prototype.h b/drivers/net/ethernet/intel/i40evf/i40e_prototype.h
index 741223d5d809..227905b23690 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_prototype.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_prototype.h
@@ -29,7 +29,7 @@
 
 #include "i40e_type.h"
 #include "i40e_alloc.h"
-#include "i40e_virtchnl.h"
+#include <linux/avf/virtchnl.h>
 
 /* Prototypes for shared code functions that are not in
  * the standard function pointer structures.  These are
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf.h b/drivers/net/ethernet/intel/i40evf/i40evf.h
index b8ada6d8d890..75d314b1a9bb 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf.h
+++ b/drivers/net/ethernet/intel/i40evf/i40evf.h
@@ -43,7 +43,7 @@
 #include <net/udp.h>
 
 #include "i40e_type.h"
-#include "i40e_virtchnl.h"
+#include <linux/avf/virtchnl.h>
 #include "i40e_txrx.h"
 
 #define DEFAULT_DEBUG_LEVEL_SHIFT 3
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h b/include/linux/avf/virtchnl.h
similarity index 100%
rename from drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
rename to include/linux/avf/virtchnl.h
-- 
2.12.2
