From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH net 1/2] sxgbe: fix duplicate #include headers
Date: Sat,  5 Apr 2014 00:29:00 -0600
Message-ID: <1396679341-23502-2-git-send-email-sakiwit@gmail.com>
References: <1396679341-23502-1-git-send-email-sakiwit@gmail.com>
Cc: Byungho An <bh74.an@samsung.com>, Girish K S <ks.giri@samsung.com>,
	Siva Reddy Kallam <siva.kallam@samsung.com>,
	Vipul Pandya <vipul.pandya@samsung.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:39229 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751700AbaDEGce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Apr 2014 02:32:34 -0400
Received: by mail-pd0-f173.google.com with SMTP id z10so4260438pdj.4
        for <netdev@vger.kernel.org>; Fri, 04 Apr 2014 23:32:34 -0700 (PDT)
In-Reply-To: <1396679341-23502-1-git-send-email-sakiwit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 1edb9ca69e8a ("net: sxgbe: add basic framework for
Samsung 10Gb ethernet driver") added support for Samsung 10Gb
ethernet driver(sxgbe) with a minor issue of including linux/io.h
header twice in sxgbe_dma.c file. Fix the duplicate #include by
deleting the top one so that all the rest good #include headers
would be preserved in the alphabetical order.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
Cc: Byungho An <bh74.an@samsung.com>
Cc: Girish K S <ks.giri@samsung.com>
Cc: Siva Reddy Kallam <siva.kallam@samsung.com>
Cc: Vipul Pandya <vipul.pandya@samsung.com>
---
 drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c
index 28f89c41d0cd..4d989ff6c978 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c
@@ -9,7 +9,6 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
-#include <linux/io.h>
 #include <linux/delay.h>
 #include <linux/export.h>
 #include <linux/io.h>
