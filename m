From: Mithlesh Thukral <mithlesh@netxen.com>
Subject: [PATCH 7/7] NetXen: Fix for vmalloc issues
Date: Fri, 20 Apr 2007 07:57:26 -0700
Message-ID: <200704201457.l3KEvQAi004598@dut39.unminc.com>
Cc: amitkale@netxen.com, jeff@garzik.org, netxenproj@linsyssoft.com,
	rob@netxen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:19021 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S2992847AbXDTO51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2007 10:57:27 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen: Fix vmalloc errors on seen on some X86 high end machines.

Signed-off by: Milan Bag <mbag@netxen.com> 
Acked-by: Mithlesh Thukral <mithlesh@netxen.com>

---

 drivers/net/netxen/netxen_nic.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 5095a3f..ad6688e 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -131,8 +131,8 @@ #define NX_P2_C1		0x25
 #define FIRST_PAGE_GROUP_START	0
 #define FIRST_PAGE_GROUP_END	0x100000
 
-#define SECOND_PAGE_GROUP_START	0x4000000
-#define SECOND_PAGE_GROUP_END	0x66BC000
+#define SECOND_PAGE_GROUP_START	0x6000000
+#define SECOND_PAGE_GROUP_END	0x68BC000
 
 #define THIRD_PAGE_GROUP_START	0x70E4000
 #define THIRD_PAGE_GROUP_END	0x8000000
