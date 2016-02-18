From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/15] i40evf: Change vf driver string to reflect all products i40evf supports
Date: Wed, 17 Feb 2016 19:38:49 -0800
Message-ID: <1455766737-11911-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455766737-11911-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:1599 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1424859AbcBRDjF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 22:39:05 -0500
In-Reply-To: <1455766737-11911-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

Change the driver string to 40-10 Gigabit instead of XL710/X710 for X722
and all future products.

Also update copyright year in file header.

Change-ID: I57fae656b36dc4eb682b2b7a054f8f48f3589149
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 045cc7f..faa1bca 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
  *
  * Intel Ethernet Controller XL710 Family Linux Virtual Function Driver
- * Copyright(c) 2013 - 2015 Intel Corporation.
+ * Copyright(c) 2013 - 2016 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -32,7 +32,7 @@ static int i40evf_close(struct net_device *netdev);
 
 char i40evf_driver_name[] = "i40evf";
 static const char i40evf_driver_string[] =
-	"Intel(R) XL710/X710 Virtual Function Network Driver";
+	"Intel(R) 40-10 Gigabit Virtual Function Network Driver";
 
 #define DRV_KERN "-k"
 
-- 
2.5.0
