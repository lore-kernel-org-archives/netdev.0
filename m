From: Anjali Singhai Jain <anjali.singhai@intel.com>
Subject: [PATCH v5 3/5] i40e: Kernel dependency update for i40e to support geneve offload
Date: Mon, 14 Dec 2015 12:21:19 -0800
Message-ID: <1450124481-206978-4-git-send-email-anjali.singhai@intel.com>
References: <1450124481-206978-1-git-send-email-anjali.singhai@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	jeffrey.t.kirsher@intel.com, Kiran Patil <kiran.patil@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:60035 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932088AbbLNUD5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Dec 2015 15:03:57 -0500
In-Reply-To: <1450124481-206978-1-git-send-email-anjali.singhai@intel.com>
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
