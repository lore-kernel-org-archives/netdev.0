From: Mikko Rapeli <mikko.rapeli@iki.fi>
Subject: [PATCH v06 35/36] uapi linux/tls.h: don't include <net/tcp.h> in user space
Date: Sun,  6 Aug 2017 18:44:26 +0200
Message-ID: <20170806164428.2273-36-mikko.rapeli@iki.fi>
References: <20170806164428.2273-1-mikko.rapeli@iki.fi>
Cc: Mikko Rapeli <mikko.rapeli@iki.fi>,
        Dave Watson <davejwatson@fb.com>,
        Ilya Lesokhin <ilyal@mellanox.com>,
        Aviad Yehezkel <aviadye@mellanox.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170806164428.2273-1-mikko.rapeli@iki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It is not needed and not part of uapi headers, but causes
user space compilation error:

fatal error: net/tcp.h: No such file or directory
 #include <net/tcp.h>
                     ^

Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
Cc: Dave Watson <davejwatson@fb.com>
Cc: Ilya Lesokhin <ilyal@mellanox.com>
Cc: Aviad Yehezkel <aviadye@mellanox.com>
---
 include/uapi/linux/tls.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/uapi/linux/tls.h b/include/uapi/linux/tls.h
index cc1d21db35d8..d87c698623f2 100644
--- a/include/uapi/linux/tls.h
+++ b/include/uapi/linux/tls.h
@@ -37,7 +37,9 @@
 #include <asm/byteorder.h>
 #include <linux/socket.h>
 #include <linux/tcp.h>
+#ifdef __KERNEL__
 #include <net/tcp.h>
+#endif
 
 /* TLS socket options */
 #define TLS_TX			1	/* Set transmit parameters */
-- 
2.13.3
