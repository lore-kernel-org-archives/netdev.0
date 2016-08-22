From: Mikko Rapeli <mikko.rapeli@iki.fi>
Subject: [PATCH v05 26/72] include/uapi/linux/if_pppox.h: include linux/in.h and linux/in6.h
Date: Mon, 22 Aug 2016 20:32:43 +0200
Message-ID: <1471890809-4383-27-git-send-email-mikko.rapeli@iki.fi>
References: <1471890809-4383-1-git-send-email-mikko.rapeli@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Mikko Rapeli <mikko.rapeli@iki.fi>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kapsi.fi ([217.30.184.167]:43622 "EHLO mail.kapsi.fi"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754202AbcHVShX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 Aug 2016 14:37:23 -0400
In-Reply-To: <1471890809-4383-1-git-send-email-mikko.rapeli@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes userspace compilation errors:

error: field ‘addr’ has incomplete type
 struct sockaddr_in addr; /* IP address and port to send to */

error: field ‘addr’ has incomplete type
 struct sockaddr_in6 addr; /* IP address and port to send to */

Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
---
 include/uapi/linux/if_pppox.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/uapi/linux/if_pppox.h b/include/uapi/linux/if_pppox.h
index 473c3c4..d37bbb1 100644
--- a/include/uapi/linux/if_pppox.h
+++ b/include/uapi/linux/if_pppox.h
@@ -24,6 +24,8 @@
 #include <linux/if.h>
 #include <linux/if_ether.h>
 #include <linux/if_pppol2tp.h>
+#include <linux/in.h>
+#include <linux/in6.h>
 
 /* For user-space programs to pick up these definitions
  * which they wouldn't get otherwise without defining __KERNEL__
-- 
2.8.1
