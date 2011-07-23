From: Huang Weiyi <weiyi.huang@gmail.com>
Subject: [PATCH] via-velocity: remove duplicated #include
Date: Sat, 23 Jul 2011 16:20:45 +0800
Message-ID: <1311409245-3324-1-git-send-email-weiyi.huang@gmail.com>
Cc: netdev@vger.kernel.org, Huang Weiyi <weiyi.huang@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:46215 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751471Ab1GWIVI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jul 2011 04:21:08 -0400
Received: by mail-pz0-f42.google.com with SMTP id 37so4899732pzk.1
        for <netdev@vger.kernel.org>; Sat, 23 Jul 2011 01:21:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove duplicated #include('s) in
  drivers/net/via-velocity.c

Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>
---
 drivers/net/via-velocity.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index a9aa4a3..deb1eca 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -77,7 +77,6 @@
 #include <linux/udp.h>
 #include <linux/crc-ccitt.h>
 #include <linux/crc32.h>
-#include <linux/if_vlan.h>
 
 #include "via-velocity.h"
 
-- 
1.5.6.4

