From: yalin wang <yalin.wang2010@gmail.com>
Subject: [PATCH v2 Resend] net/fddi: remove HWM_REVERSE() macro
Date: Tue, 11 Aug 2015 13:11:22 +0800
Message-ID: <39055924-5AA5-4DE0-8872-D2F107EA82F1@gmail.com>
References: <1FEC219B-7AF2-47C9-8EBB-786EE6EADCE4@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	open list <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:32776 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750976AbbHKFL0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 01:11:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HWM_REVERSE() macro is unused, remove it.

Signed-off-by: yalin wang <yalin.wang2010@gmail.com>
---
drivers/net/fddi/skfp/h/hwmtm.h | 10 ----------
1 file changed, 10 deletions(-)

diff --git a/drivers/net/fddi/skfp/h/hwmtm.h b/drivers/net/fddi/skfp/h/hwmtm.h
index 5924d42..4ca2341 100644
--- a/drivers/net/fddi/skfp/h/hwmtm.h
+++ b/drivers/net/fddi/skfp/h/hwmtm.h
@@ -74,15 +74,6 @@
#define NULL           0
#endif

-#ifdef LITTLE_ENDIAN
-#define HWM_REVERSE(x) (x)
-#else
-#define        HWM_REVERSE(x)          ((((x)<<24L)&0xff000000L)       +       \
-                                (((x)<< 8L)&0x00ff0000L)       +       \
-                                (((x)>> 8L)&0x0000ff00L)       +       \
-                                (((x)>>24L)&0x000000ffL))
-#endif
-
#define C_INDIC                (1L<<25)
#define A_INDIC                (1L<<26)
#define        RD_FS_LOCAL     0x80
-- 
1.9.1
