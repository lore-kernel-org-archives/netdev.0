From: Huang Weiyi <weiyi.huang@gmail.com>
Subject: [PATCH] qlge: remove duplicated #include
Date: Sat, 23 Jul 2011 16:20:25 +0800
Message-ID: <1311409225-2340-1-git-send-email-weiyi.huang@gmail.com>
Cc: netdev@vger.kernel.org, Huang Weiyi <weiyi.huang@gmail.com>
To: linux-driver@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:46215 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751471Ab1GWIUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jul 2011 04:20:40 -0400
Received: by mail-pz0-f42.google.com with SMTP id 37so4899732pzk.1
        for <netdev@vger.kernel.org>; Sat, 23 Jul 2011 01:20:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove duplicated #include('s) in
  drivers/net/qlge/qlge_main.c

Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>
---
 drivers/net/qlge/qlge_main.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 743e3ec..f07e96e 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -36,7 +36,6 @@
 #include <linux/ethtool.h>
 #include <linux/if_vlan.h>
 #include <linux/skbuff.h>
-#include <linux/if_vlan.h>
 #include <linux/delay.h>
 #include <linux/mm.h>
 #include <linux/vmalloc.h>
-- 
1.5.6.4

