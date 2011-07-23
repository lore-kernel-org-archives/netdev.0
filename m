From: Huang Weiyi <weiyi.huang@gmail.com>
Subject: [PATCH] igb: remove duplicated #include
Date: Sat, 23 Jul 2011 16:20:01 +0800
Message-ID: <1311409201-2324-1-git-send-email-weiyi.huang@gmail.com>
Cc: netdev@vger.kernel.org, Huang Weiyi <weiyi.huang@gmail.com>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:46215 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751471Ab1GWIUP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jul 2011 04:20:15 -0400
Received: by mail-pz0-f42.google.com with SMTP id 37so4899732pzk.1
        for <netdev@vger.kernel.org>; Sat, 23 Jul 2011 01:20:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove duplicated #include('s) in
  drivers/net/igb/igb_main.c

Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>
---
 drivers/net/igb/igb_main.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index cb8c6bb..dc59905 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -47,7 +47,6 @@
 #include <linux/if_ether.h>
 #include <linux/aer.h>
 #include <linux/prefetch.h>
-#include <linux/if_vlan.h>
 #ifdef CONFIG_IGB_DCA
 #include <linux/dca.h>
 #endif
-- 
1.5.6.4

