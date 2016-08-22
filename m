From: Mikko Rapeli <mikko.rapeli@iki.fi>
Subject: [PATCH v05 21/72] include/uapi/linux/if_pppox.h: include linux/if.h
Date: Mon, 22 Aug 2016 20:32:38 +0200
Message-ID: <1471890809-4383-22-git-send-email-mikko.rapeli@iki.fi>
References: <1471890809-4383-1-git-send-email-mikko.rapeli@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Mikko Rapeli <mikko.rapeli@iki.fi>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471890809-4383-1-git-send-email-mikko.rapeli@iki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes userspace compilation error:

error: ‘IFNAMSIZ’ undeclared here (not in a function)

Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
---
 include/uapi/linux/if_pppox.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/if_pppox.h b/include/uapi/linux/if_pppox.h
index e128769..473c3c4 100644
--- a/include/uapi/linux/if_pppox.h
+++ b/include/uapi/linux/if_pppox.h
@@ -21,6 +21,7 @@
 #include <asm/byteorder.h>
 
 #include <linux/socket.h>
+#include <linux/if.h>
 #include <linux/if_ether.h>
 #include <linux/if_pppol2tp.h>
 
-- 
2.8.1
