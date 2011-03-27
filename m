From: Javier Martinez Canillas <martinez.javier@gmail.com>
Subject: [PATCH 1/3] tg3: use <linux/io.h> and <linux/uaccess.h> instead <asm/io.h> and <asm/uaccess.h>
Date: Sun, 27 Mar 2011 04:42:31 +0200
Message-ID: <1301193753-10045-1-git-send-email-martinez.javier@gmail.com>
Cc: Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org,
	Javier Martinez Canillas <martinez.javier@gmail.com>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:36904 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752569Ab1C0CmL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Mar 2011 22:42:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is proper style to include linux/foo.h instead asm/foo.h if both exist

Signed-off-by: Javier Martinez Canillas <martinez.javier@gmail.com>
---
 drivers/net/tg3.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 6be4185..4410d73 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -48,9 +48,9 @@
 #include <net/ip.h>
 
 #include <asm/system.h>
-#include <asm/io.h>
+#include <linux/io.h>
 #include <asm/byteorder.h>
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 
 #ifdef CONFIG_SPARC
 #include <asm/idprom.h>
-- 
1.7.2.3

