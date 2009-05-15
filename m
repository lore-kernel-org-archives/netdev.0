From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 4/5] mac89x0: remove PRINTK()
Date: Sat, 16 May 2009 00:22:41 +0400
Message-ID: <1242418962-1272-4-git-send-email-a.beregalov@gmail.com>
References: <1242418962-1272-1-git-send-email-a.beregalov@gmail.com>
 <1242418962-1272-2-git-send-email-a.beregalov@gmail.com>
 <1242418962-1272-3-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:20455 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752597AbZEOUXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2009 16:23:09 -0400
Received: by fg-out-1718.google.com with SMTP id d23so204353fga.17
        for <netdev@vger.kernel.org>; Fri, 15 May 2009 13:23:10 -0700 (PDT)
In-Reply-To: <1242418962-1272-3-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are no users of it.

Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/mac89x0.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/mac89x0.c b/drivers/net/mac89x0.c
index 384e072..e24175a 100644
--- a/drivers/net/mac89x0.c
+++ b/drivers/net/mac89x0.c
@@ -73,8 +73,6 @@ static char *version =
    or override something. */
 #include <linux/module.h>
 
-#define PRINTK(x) printk x
-
 /*
   Sources:
 
-- 
1.6.3

