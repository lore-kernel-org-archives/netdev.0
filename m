From: yalin wang <yalin.wang2010@gmail.com>
Subject: [PATCH v2] net/fddi: remove HWM_REVERSE() macro
Date: Tue, 11 Aug 2015 09:57:21 +0800
Message-ID: <1FEC219B-7AF2-47C9-8EBB-786EE6EADCE4@gmail.com>
References: <6AE77A24-5AC5-47E4-8B9F-9BCDE0C6A8F9@gmail.com> <1439224589.2322.109.camel@perches.com> <11E10C05-909B-4453-ADEB-EE3085A22B29@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, open list <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33640 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751679AbbHKB50 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 21:57:26 -0400
In-Reply-To: <11E10C05-909B-4453-ADEB-EE3085A22B29@gmail.com>
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
