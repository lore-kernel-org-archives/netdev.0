From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 4/5] isdn/gigaset: enable Kernel CAPI support by default
Date: Wed, 10 Dec 2014 13:41:55 +0100 (CET)
Message-ID: <68a098f6b9a0b756accf76e5768bd8a1771e11fa.1418214588.git.tilman@imap.cc>
References: <cover.1418214588.git.tilman@imap.cc>
Cc: David Miller <davem@davemloft.net>, Hansjoerg Lipp <hjlipp@web.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([89.1.7.7]:33187 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755804AbaLJM75 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Dec 2014 07:59:57 -0500
In-Reply-To: <cover.1418214588.git.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel CAPI has been the recommended ISDN subsystem for the Gigaset
driver since kernel release 2.6.34.2. It provides full backwards
compatibility to the old I4L subsystem thanks to the capidrv module.
I4L has been marked as deprecated for more than seven years.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/isdn/gigaset/Kconfig b/drivers/isdn/gigaset/Kconfig
index dde5e09..83f62b8 100644
--- a/drivers/isdn/gigaset/Kconfig
+++ b/drivers/isdn/gigaset/Kconfig
@@ -20,7 +20,7 @@ if ISDN_DRV_GIGASET
 config GIGASET_CAPI
 	bool "Gigaset CAPI support"
 	depends on ISDN_CAPI='y'||(ISDN_CAPI='m'&&ISDN_DRV_GIGASET='m')
-	default ISDN_I4L='n'
+	default 'y'
 	help
 	  Build the Gigaset driver as a CAPI 2.0 driver interfacing with
 	  the Kernel CAPI subsystem. To use it with the old ISDN4Linux
-- 
1.9.2.459.g68773ac
