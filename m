From: Huang Weiyi <weiyi.huang@gmail.com>
Subject: [PATCH] net: sh_eth: remove duplicated #include
Date: Tue, 30 Aug 2011 21:09:12 +0800
Message-ID: <1314709752-5012-1-git-send-email-weiyi.huang@gmail.com>
Cc: netdev@vger.kernel.org, Huang Weiyi <weiyi.huang@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:39886 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751531Ab1H3NJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 09:09:33 -0400
Received: by pzk37 with SMTP id 37so10287002pzk.1
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2011 06:09:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove duplicated #include('s) in
  drivers/net/sh_eth.c

Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>
---
 drivers/net/sh_eth.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index 1c1666e..190f619 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -31,7 +31,6 @@
 #include <linux/phy.h>
 #include <linux/cache.h>
 #include <linux/io.h>
-#include <linux/interrupt.h>
 #include <linux/pm_runtime.h>
 #include <linux/slab.h>
 #include <linux/ethtool.h>
-- 
1.6.1.3
