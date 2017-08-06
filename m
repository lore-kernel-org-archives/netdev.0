From: Mikko Rapeli <mikko.rapeli@iki.fi>
Subject: [PATCH v06 20/36] uapi linux/scc.h: include linux/sockios.h
Date: Sun,  6 Aug 2017 18:44:11 +0200
Message-ID: <20170806164428.2273-21-mikko.rapeli@iki.fi>
References: <20170806164428.2273-1-mikko.rapeli@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Mikko Rapeli <mikko.rapeli@iki.fi>, netdev@vger.kernel.org,
        linux-hams@vger.kernel.org, Joerg Reuter <jreuter@yaina.de>
To: linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170806164428.2273-1-mikko.rapeli@iki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes userspace compilation error:

error: ‘SIOCDEVPRIVATE’ undeclared here (not in a function)
  SIOCSCCRESERVED = SIOCDEVPRIVATE

Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
Cc: netdev@vger.kernel.org
Cc: linux-hams@vger.kernel.org
Cc: Joerg Reuter <jreuter@yaina.de>
---
 include/uapi/linux/scc.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/scc.h b/include/uapi/linux/scc.h
index 72b6b8153374..2992b88ca4ce 100644
--- a/include/uapi/linux/scc.h
+++ b/include/uapi/linux/scc.h
@@ -3,6 +3,7 @@
 #ifndef _UAPI_SCC_H
 #define _UAPI_SCC_H
 
+#include <linux/sockios.h>
 
 /* selection of hardware types */
 
-- 
2.13.3
