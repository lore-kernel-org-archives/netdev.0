From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: [PATCH] wavelan: fix section mismatch
Date: Thu, 25 May 2006 11:09:21 -0700
Message-ID: <20060525110921.afaa98ce.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev <netdev@vger.kernel.org>,
	akpm <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:17803 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S1030307AbWEYSHt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 May 2006 14:07:49 -0400
Received: from midway.site ([71.245.102.105]) by xenotime.net for <netdev@vger.kernel.org>; Thu, 25 May 2006 11:07:48 -0700
To: ismail@pardus.org.tr, jt@hpl.hp.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>

Fix section mismatch warning:
WARNING: drivers/net/wireless/wavelan.o - Section mismatch: reference to
.init.text: from .text between 'init_module' (at offset 0x371e) and
'cleanup_module'

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
---
 drivers/net/wireless/wavelan.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

--- linux-2617-rc5.orig/drivers/net/wireless/wavelan.c
+++ linux-2617-rc5/drivers/net/wireless/wavelan.c
@@ -4306,7 +4306,7 @@ out:
  * Insertion of the module
  * I'm now quite proud of the multi-device support.
  */
-int init_module(void)
+int __init init_module(void)
 {
 	int ret = -EIO;		/* Return error if no cards found */
 	int i;


---
