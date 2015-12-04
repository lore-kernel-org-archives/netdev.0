From: Anjali Singhai Jain <anjali.singhai@intel.com>
Subject: [RFC PATCH v2 3/4] i40e: Kernel dependency update for i40e to support geneve offload
Date: Fri,  4 Dec 2015 00:19:03 -0800
Message-ID: <1449217144-18756-4-git-send-email-anjali.singhai@intel.com>
References: <1449217144-18756-1-git-send-email-anjali.singhai@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	Kiran Patil <kiran.patil@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:14140 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752542AbbLDIBw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Dec 2015 03:01:52 -0500
In-Reply-To: <1449217144-18756-1-git-send-email-anjali.singhai@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update the Kconfig file with dependency for supporting GENEVE tunnel
offloads.

Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Kiran Patil <kiran.patil@intel.com>
---
 drivers/net/ethernet/intel/Kconfig | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
index 4163b16..fa593dd 100644
--- a/drivers/net/ethernet/intel/Kconfig
+++ b/drivers/net/ethernet/intel/Kconfig
@@ -280,6 +280,16 @@ config I40E_VXLAN
 	  Say Y here if you want to use Virtual eXtensible Local Area Network
 	  (VXLAN) in the driver.
 
+config I40E_GENEVE
+	bool "Generic Network Virtualization Encapsulation (GENEVE) Support"
+	depends on I40E && GENEVE && !(I40E=y && GENEVE=m)
+	default n
+	---help---
+	  This allows one to create GENEVE virtual interfaces that provide
+	  Layer 2 Networks over Layer 3 Networks. GENEVE is often used
+	  to tunnel virtual network infrastructure in virtualized environments.
+	  Say Y here if you want to use GENEVE in the driver.
+
 config I40E_DCB
 	bool "Data Center Bridging (DCB) Support"
 	default n
-- 
1.8.1.4
