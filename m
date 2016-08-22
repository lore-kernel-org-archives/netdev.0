From: Mikko Rapeli <mikko.rapeli@iki.fi>
Subject: [PATCH v05 41/72] include/uapi/linux/atm_zatm.h: include linux/time.h
Date: Mon, 22 Aug 2016 20:32:58 +0200
Message-ID: <1471890809-4383-42-git-send-email-mikko.rapeli@iki.fi>
References: <1471890809-4383-1-git-send-email-mikko.rapeli@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Mikko Rapeli <mikko.rapeli@iki.fi>,
        Chas Williams <3chas3@gmail.com>,
        linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471890809-4383-1-git-send-email-mikko.rapeli@iki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes userspace compile error:

error: field ‘real’ has incomplete type
 struct timeval real;  /* real (wall-clock) time */

Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
---
 include/uapi/linux/atm_zatm.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/atm_zatm.h b/include/uapi/linux/atm_zatm.h
index 9c9c6ad..5cd4d4d 100644
--- a/include/uapi/linux/atm_zatm.h
+++ b/include/uapi/linux/atm_zatm.h
@@ -14,6 +14,7 @@
 
 #include <linux/atmapi.h>
 #include <linux/atmioc.h>
+#include <linux/time.h>
 
 #define ZATM_GETPOOL	_IOW('a',ATMIOC_SARPRV+1,struct atmif_sioc)
 						/* get pool statistics */
-- 
2.8.1
