From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] [BNX2]: Seems to not need net/tcp.h
Date: Sat, 7 Jul 2007 11:49:56 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0707071048200.18869@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-1554381597-1183797268=:18869"
Cc: Netdev <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:56672 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752609AbXGGIuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jul 2007 04:50:03 -0400
Content-ID: <Pine.LNX.4.64.0707071148100.18869@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1554381597-1183797268=:18869
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0707071148101.18869@kivilampi-30.cs.helsinki.fi>


Got bored to always recompile it for no reason.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 drivers/net/bnx2.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 88b33c6..56244f6 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -40,7 +40,6 @@
 #define BCM_VLAN 1
 #endif
 #include <net/ip.h>
-#include <net/tcp.h>
 #include <net/checksum.h>
 #include <linux/workqueue.h>
 #include <linux/crc32.h>
-- 
1.5.0.6
---696243703-1554381597-1183797268=:18869--
