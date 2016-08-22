From: Mikko Rapeli <mikko.rapeli@iki.fi>
Subject: [PATCH v05 25/72] include/uapi/linux/if_pppol2tp.h: include linux/in.h and linux/in6.h
Date: Mon, 22 Aug 2016 20:32:42 +0200
Message-ID: <1471890809-4383-26-git-send-email-mikko.rapeli@iki.fi>
References: <1471890809-4383-1-git-send-email-mikko.rapeli@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Mikko Rapeli <mikko.rapeli@iki.fi>,
        James Chapman <jchapman@katalix.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kapsi.fi ([217.30.184.167]:50675 "EHLO mail.kapsi.fi"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754642AbcHVShX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 Aug 2016 14:37:23 -0400
In-Reply-To: <1471890809-4383-1-git-send-email-mikko.rapeli@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes userspace compilation errors like:

error: field ‘addr’ has incomplete type
 struct sockaddr_in addr; /* IP address and port to send to */
                    ^
error: field ‘addr’ has incomplete type
 struct sockaddr_in6 addr; /* IP address and port to send to */

Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
---
 include/uapi/linux/if_pppol2tp.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_pppol2tp.h b/include/uapi/linux/if_pppol2tp.h
index 163e8ad..4bd1f55 100644
--- a/include/uapi/linux/if_pppol2tp.h
+++ b/include/uapi/linux/if_pppol2tp.h
@@ -16,7 +16,8 @@
 #define _UAPI__LINUX_IF_PPPOL2TP_H
 
 #include <linux/types.h>
-
+#include <linux/in.h>
+#include <linux/in6.h>
 
 /* Structure used to connect() the socket to a particular tunnel UDP
  * socket over IPv4.
-- 
2.8.1
