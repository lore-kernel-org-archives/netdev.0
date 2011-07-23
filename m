From: Huang Weiyi <weiyi.huang@gmail.com>
Subject: [PATCH] bnad: remove duplicated #include
Date: Sat, 23 Jul 2011 16:19:12 +0800
Message-ID: <1311409152-668-1-git-send-email-weiyi.huang@gmail.com>
Cc: netdev@vger.kernel.org, Huang Weiyi <weiyi.huang@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:46215 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751471Ab1GWITc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jul 2011 04:19:32 -0400
Received: by pzk37 with SMTP id 37so4899732pzk.1
        for <netdev@vger.kernel.org>; Sat, 23 Jul 2011 01:19:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove duplicated #include('s) in
  drivers/net/bna/bnad.c

Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>
---
 drivers/net/bna/bnad.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index c89c9b2..b7e80ac 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -25,7 +25,6 @@
 #include <linux/if_ether.h>
 #include <linux/ip.h>
 #include <linux/prefetch.h>
-#include <linux/if_vlan.h>
 
 #include "bnad.h"
 #include "bna.h"
-- 
1.5.6.4

