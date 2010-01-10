From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH 30/31] CAPI: Remove experimental tag from middleware feature
Date: Sun, 10 Jan 2010 14:12:41 +0100
Message-ID: <9dd553d458def04edc7790f0320ffdf1f8909aa5.1264201408.git.jan.kiszka@web.de>
References: <cover.1264201406.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate02.web.de ([217.72.192.227]:50181 "EHLO
	fmmailgate02.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932175Ab0AVX1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 18:27:10 -0500
In-Reply-To: <cover.1264201406.git.jan.kiszka@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Despite all its bugs, the middleware support of our CAPI stack was
already in use for many, many moons. And after going through its code,
fixing all issues I found, I feel it deserves to officially become a
non-experimental feature.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/Kconfig |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/capi/Kconfig b/drivers/isdn/capi/Kconfig
index b2a0475..66647ed 100644
--- a/drivers/isdn/capi/Kconfig
+++ b/drivers/isdn/capi/Kconfig
@@ -17,8 +17,7 @@ config CAPI_TRACE
 	  If unsure, say Y.
 
 config ISDN_CAPI_MIDDLEWARE
-	bool "CAPI2.0 Middleware support (EXPERIMENTAL)"
-	depends on EXPERIMENTAL
+	bool "CAPI2.0 Middleware support"
 	help
 	  This option will enhance the capabilities of the /dev/capi20
 	  interface.  It will provide a means of moving a data connection,
-- 
1.6.0.2

