From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: [PATCH] ATM: he: fix section mismatch
Date: Sat, 26 Aug 2006 12:42:38 -0700
Message-ID: <20060826124238.580c21d1.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, akpm <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:33745 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S1750763AbWHZTjZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Aug 2006 15:39:25 -0400
Received: from midway.site ([71.117.233.155]) by xenotime.net for <netdev@vger.kernel.org>; Sat, 26 Aug 2006 12:39:23 -0700
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>

Fix section mismatch:
WARNING: drivers/atm/he.o - Section mismatch: reference to .init.text: from .text between 'he_start' (at offset 0x218a) and 'he_service_tbrq'

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
---
 drivers/atm/he.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

--- linux-2618-rc4g1-all.orig/drivers/atm/he.c
+++ linux-2618-rc4g1-all/drivers/atm/he.c
@@ -785,7 +785,7 @@ he_init_cs_block_rcm(struct he_dev *he_d
 	return 0;
 }
 
-static int __init
+static int __devinit
 he_init_group(struct he_dev *he_dev, int group)
 {
 	int i;


---
