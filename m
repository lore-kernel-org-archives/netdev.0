From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] vxlan: remove unused including <linux/version.h>
Date: Sun, 7 Oct 2012 21:23:06 +0800
Message-ID: <CAPgLHd-AeX16JeZJv6D6K_wFr2_r4Zp=Q_Hw5BK-iF+mSWRE4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:59093 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751096Ab2JGNXG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Oct 2012 09:23:06 -0400
Received: by mail-qa0-f53.google.com with SMTP id s11so1351184qaa.19
        for <netdev@vger.kernel.org>; Sun, 07 Oct 2012 06:23:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Remove including <linux/version.h> that don't need it.

dpatch engine is used to auto generate this patch.
(https://github.com/weiyj/dpatch)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/vxlan.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 51de9ed..6f95580 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -28,7 +28,6 @@
 #include <linux/igmp.h>
 #include <linux/etherdevice.h>
 #include <linux/if_ether.h>
-#include <linux/version.h>
 #include <linux/hash.h>
 #include <net/ip.h>
 #include <net/icmp.h>
