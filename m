From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH 1/5] irda: irproc.c: Remove unneeded linux/miscdevice.h include
Date: Thu, 15 Dec 2016 11:42:46 +0100
Message-ID: <20161215104250.16813-1-clabbe.montjoie@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: arnd@arndb.de, gregkh@linuxfoundation.org, samuel@sortiz.org,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34146 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752922AbcLOLCm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 06:02:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

irproc.c does not use any miscdevice so this patch remove this
unnecessary inclusion.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 net/irda/irproc.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/irda/irproc.c b/net/irda/irproc.c
index b9ac598..77cfdde 100644
--- a/net/irda/irproc.c
+++ b/net/irda/irproc.c
@@ -23,7 +23,6 @@
  *
  ********************************************************************/
 
-#include <linux/miscdevice.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/module.h>
-- 
2.10.2
