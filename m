From: Javier Martinez Canillas <martinez.javier@gmail.com>
Subject: [PATCH 1/5] tg3: use <linux/io.h> and <linux/uaccess.h> instead <asm/io.h> and <asm/uaccess.h>
Date: Tue,  1 Mar 2011 18:04:25 +0100
Message-ID: <1298999069-12740-1-git-send-email-martinez.javier@gmail.com>
Cc: Michael Chan <mchan@broadcom.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	netdev@vger.kernel.org, kernelnewbies@kernelnewbies.org,
	Javier Martinez Canillas <martinez.javier@gmail.com>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:57121 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755349Ab1CAREY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 12:04:24 -0500
Received: by ewy6 with SMTP id 6so1731330ewy.19
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2011 09:04:22 -0800 (PST)
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

