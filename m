From: "Dmitry V. Levin" <ldv@altlinux.org>
Subject: [PATCH] uapi: fix linux/llc.h userspace compilation error
Date: Thu, 23 Feb 2017 01:38:26 +0300
Message-ID: <20170222223826.GB14311@altlinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Include <linux/if.h> to fix the following linux/llc.h userspace
compilation error:

/usr/include/linux/llc.h:26:27: error: 'IFHWADDRLEN' undeclared here (not in a function)
  unsigned char   sllc_mac[IFHWADDRLEN];

Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
---
 include/uapi/linux/llc.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/llc.h b/include/uapi/linux/llc.h
index 9c987a4..a6c17f6 100644
--- a/include/uapi/linux/llc.h
+++ b/include/uapi/linux/llc.h
@@ -14,6 +14,7 @@
 #define _UAPI__LINUX_LLC_H
 
 #include <linux/socket.h>
+#include <linux/if.h> 		/* For IFHWADDRLEN. */
 
 #define __LLC_SOCK_SIZE__ 16	/* sizeof(sockaddr_llc), word align. */
 struct sockaddr_llc {
-- 
ldv
