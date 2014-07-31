From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 03/15] i40e: adds FCoE to build and updates its documentation
Date: Wed, 30 Jul 2014 17:31:59 -0700
Message-ID: <1406766731-4209-4-git-send-email-aaron.f.brown@intel.com>
References: <1406766731-4209-1-git-send-email-aaron.f.brown@intel.com>
Cc: Vasu Dev <vasu.dev@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:64996 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752965AbaGaA2R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2014 20:28:17 -0400
In-Reply-To: <1406766731-4209-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasu Dev <vasu.dev@intel.com>

Adds newly added FCoE files to the build but only if FCoE module is configured.

Also, updates i40e document for added FCoE support.

Signed-off-by: Vasu Dev <vasu.dev@intel.com>
Tested-by: Jack Morgan<jack.morgan@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 Documentation/networking/i40e.txt        | 7 +++++--
 drivers/net/ethernet/intel/i40e/Makefile | 1 +
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/i40e.txt b/Documentation/networking/i40e.txt
index f737273..a251bf4 100644
--- a/Documentation/networking/i40e.txt
+++ b/Documentation/networking/i40e.txt
@@ -69,8 +69,11 @@ Additional Configurations
 
   FCoE
   ----
-  Fiber Channel over Ethernet (FCoE) hardware offload is not currently
-  supported.
+  The driver supports Fiber Channel over Ethernet (FCoE) and Data Center
+  Bridging (DCB) functionality. Configuring DCB and FCoE is outside the scope
+  of this driver doc. Refer to http://www.open-fcoe.org/ for FCoE project
+  information and http://www.open-lldp.org/ or email list
+  e1000-eedc@lists.sourceforge.net for DCB information.
 
   MAC and VLAN anti-spoofing feature
   ----------------------------------
diff --git a/drivers/net/ethernet/intel/i40e/Makefile b/drivers/net/ethernet/intel/i40e/Makefile
index d9eb80a..4b94ddb 100644
--- a/drivers/net/ethernet/intel/i40e/Makefile
+++ b/drivers/net/ethernet/intel/i40e/Makefile
@@ -44,3 +44,4 @@ i40e-objs := i40e_main.o \
 	i40e_virtchnl_pf.o
 
 i40e-$(CONFIG_I40E_DCB) += i40e_dcb.o i40e_dcb_nl.o
+i40e-$(CONFIG_FCOE:m=y) += i40e_fcoe.o
-- 
1.9.3
