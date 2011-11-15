From: akpm@linux-foundation.org
Subject: [patch 1/1] drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h: remove unused macro pr_fmt()
Date: Tue, 15 Nov 2011 14:55:29 -0800
Message-ID: <201111152255.pAFMtTo5005370@wpaz5.hot.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ASCII
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jeffrey.t.kirsher@intel.com, tomoya-linux@dsn.okisemi.com,
	toshiharu-linux@dsn.okisemi.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f202.google.com ([209.85.215.202]:47657 "EHLO
	mail-ey0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753657Ab1KOXCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 18:02:15 -0500
Received: by eyg5 with SMTP id 5so200860eyg.1
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2011 15:02:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Subject: drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h: remove unused macro pr_fmt()

In file included from drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_param.c:22:
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h:24:1: warning: "pr_fmt" redefined
In file included from include/linux/kernel.h:20,
                 from include/linux/cache.h:4,
                 from include/linux/time.h:7,
                 from include/linux/stat.h:60,
                 from include/linux/module.h:10,
                 from drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_param.c:21:
include/linux/printk.h:152:1: warning: this is the location of the previous definition

Cc: Tomoya <tomoya-linux@dsn.okisemi.com>
Cc: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: David Miller <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h |    2 --
 1 file changed, 2 deletions(-)

diff -puN drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h~drivers-net-ethernet-oki-semi-pch_gbe-pch_gbeh-remove-unused-macro-pr_fmt drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h~drivers-net-ethernet-oki-semi-pch_gbe-pch_gbeh-remove-unused-macro-pr_fmt
+++ a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
@@ -21,8 +21,6 @@
 #ifndef _PCH_GBE_H_
 #define _PCH_GBE_H_
 
-#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
-
 #include <linux/mii.h>
 #include <linux/delay.h>
 #include <linux/pci.h>
_
