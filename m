From: Joe Perches <joe@perches.com>
Subject: [PATCH 11/25] drivers/net/netxen: Use static const char arrays
Date: Mon, 13 Sep 2010 12:47:49 -0700
Message-ID: <8a4d5d728bb68e2c69d37e71fe426c525ebd3ee8.1284406638.git.joe@perches.com>
References: <cover.1284406638.git.joe@perches.com>
Cc: Amit Kumar Salecha <amit.salecha@qlogic.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1889 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755294Ab0IMTsb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Sep 2010 15:48:31 -0400
In-Reply-To: <cover.1284406638.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/netxen/netxen_nic.h      |    2 +-
 drivers/net/netxen/netxen_nic_main.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 6dca357..bd272aa 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -525,7 +525,7 @@ struct uni_data_desc{
 #define NX_UNIFIED_ROMIMAGE_NAME	"phanfw.bin"
 #define NX_FLASH_ROMIMAGE_NAME		"flash"
 
-extern char netxen_nic_driver_name[];
+extern const char netxen_nic_driver_name[];
 
 /* Number of status descriptors to handle per interrupt */
 #define MAX_STATUS_HANDLE	(64)
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 73d3145..521cbfe 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -46,7 +46,7 @@ MODULE_FIRMWARE(NX_P3_CT_ROMIMAGE_NAME);
 MODULE_FIRMWARE(NX_P3_MN_ROMIMAGE_NAME);
 MODULE_FIRMWARE(NX_UNIFIED_ROMIMAGE_NAME);
 
-char netxen_nic_driver_name[] = "netxen_nic";
+const char netxen_nic_driver_name[] = "netxen_nic";
 static char netxen_nic_driver_string[] = "QLogic/NetXen Network Driver v"
     NETXEN_NIC_LINUX_VERSIONID;
 
-- 
1.7.3.rc1

