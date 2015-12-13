From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 10/11] i40evf: change version string generation
Date: Sat, 12 Dec 2015 21:17:36 -0800
Message-ID: <1449983857-74434-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449983857-74434-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:56992 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751139AbbLMFRn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2015 00:17:43 -0500
In-Reply-To: <1449983857-74434-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Generate version strings like the PF driver does. This gives us more
flexibility to add suffixes to the version string at build time.

Change-ID: I0a5ca0783dd8fb849516bfc1e37ea070127847bd
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 98091b4..cb58bad 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -34,7 +34,15 @@ char i40evf_driver_name[] = "i40evf";
 static const char i40evf_driver_string[] =
 	"Intel(R) XL710/X710 Virtual Function Network Driver";
 
-#define DRV_VERSION "1.4.3"
+#define DRV_KERN "-k"
+
+#define DRV_VERSION_MAJOR 1
+#define DRV_VERSION_MINOR 4
+#define DRV_VERSION_BUILD 3
+#define DRV_VERSION __stringify(DRV_VERSION_MAJOR) "." \
+	     __stringify(DRV_VERSION_MINOR) "." \
+	     __stringify(DRV_VERSION_BUILD) \
+	     DRV_KERN
 const char i40evf_driver_version[] = DRV_VERSION;
 static const char i40evf_copyright[] =
 	"Copyright (c) 2013 - 2015 Intel Corporation.";
-- 
2.5.0
