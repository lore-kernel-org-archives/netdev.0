From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH v2 41/41] CAPI: Remove experimental tag from middleware feature
Date: Mon,  8 Feb 2010 21:12:45 +0100
Message-ID: <9a3963c0dc8c0c598a4509e425a2a5f882d6fb96.1265659937.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Marcel Holtmann <marcel@holtmann.org>
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate03.web.de ([217.72.192.234]:54108 "EHLO
	fmmailgate03.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755026Ab0BHUNS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 15:13:18 -0500
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
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
index d607d46..a168e8a 100644
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

