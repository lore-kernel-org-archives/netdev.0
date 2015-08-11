From: yalin wang <yalin.wang2010@gmail.com>
Subject: Re: [PATCH v2 Resend] net/fddi: remove HWM_REVERSE() macro
Date: Tue, 11 Aug 2015 14:57:03 +0800
Message-ID: <C6958AF1-72C6-4C27-951A-92E84326978B@gmail.com>
References: <1FEC219B-7AF2-47C9-8EBB-786EE6EADCE4@gmail.com> <39055924-5AA5-4DE0-8872-D2F107EA82F1@gmail.com> <20150810.223750.1908561238664673104.davem@davemloft.net> <03416E4A-6121-41C4-B209-AD60308FE317@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <03416E4A-6121-41C4-B209-AD60308FE317@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

HWM_REVERSE() macro is unused, remove it.

Signed-off-by: yalin wang <yalin.wang2010@gmail.com>
---
 drivers/net/fddi/skfp/h/hwmtm.h | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/drivers/net/fddi/skfp/h/hwmtm.h b/drivers/net/fddi/skfp/h/hwmtm.h
index 5924d42..4ca2341 100644
--- a/drivers/net/fddi/skfp/h/hwmtm.h
+++ b/drivers/net/fddi/skfp/h/hwmtm.h
@@ -74,15 +74,6 @@
 #define NULL 		0
 #endif
 
-#ifdef	LITTLE_ENDIAN
-#define HWM_REVERSE(x)	(x)
-#else
-#define	HWM_REVERSE(x)		((((x)<<24L)&0xff000000L)	+	\
-				 (((x)<< 8L)&0x00ff0000L)	+	\
-				 (((x)>> 8L)&0x0000ff00L)	+	\
-				 (((x)>>24L)&0x000000ffL))
-#endif
-
 #define C_INDIC		(1L<<25)
 #define A_INDIC		(1L<<26)
 #define	RD_FS_LOCAL	0x80
-- 
1.9.1
