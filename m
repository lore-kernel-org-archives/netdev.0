From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] IBMLANA no longer has to depend on MCA_LEGACY
Date: Wed, 30 Jan 2008 22:02:35 +0200
Message-ID: <20080130200235.GW29368@does.not.exist>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Garzik <jgarzik@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5.pp.htv.fi ([213.243.153.39]:37584 "EHLO smtp5.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758557AbYA3UCB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 15:02:01 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the no longer required dependency of IBMLANA
on MCA_LEGACY.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
d83989118e59f403200ea9c71d2293337b49df01 
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index af40ff4..578ae2c 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1199,7 +1199,7 @@ config NE2_MCA
 
 config IBMLANA
 	tristate "IBM LAN Adapter/A support"
-	depends on MCA && MCA_LEGACY
+	depends on MCA
 	---help---
 	  This is a Micro Channel Ethernet adapter.  You need to set
 	  CONFIG_MCA to use this driver.  It is both available as an in-kernel

