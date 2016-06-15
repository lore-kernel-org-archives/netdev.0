From: Fabien Siron <fabien.siron@epita.fr>
Subject: [PATCH] Add comment to warn about deprecated netlink rings attribute request
Date: Wed, 15 Jun 2016 15:37:49 +0000
Message-ID: <20160615153749.5220-1-fabien.siron@epita.fr>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	Fabien Siron <fabien.siron@epita.fr>
To: <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0060.outbound.protection.outlook.com ([157.55.234.60]:38720
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751092AbcFOPxV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jun 2016 11:53:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Fabien Siron <fabien.siron@epita.fr>
---
 include/uapi/linux/netlink_diag.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/netlink_diag.h b/include/uapi/linux/netlink_diag.h
index d793993..76b4d87 100644
--- a/include/uapi/linux/netlink_diag.h
+++ b/include/uapi/linux/netlink_diag.h
@@ -49,6 +49,7 @@ enum {
 #define NDIAG_SHOW_MEMINFO	0x00000001 /* show memory info of a socket */
 #define NDIAG_SHOW_GROUPS	0x00000002 /* show groups of a netlink socket */
 #ifndef __KERNEL__
+/* deprecated since 4.6 */
 #define NDIAG_SHOW_RING_CFG	0x00000004 /* show ring configuration */
 #endif
 
-- 
2.8.3
