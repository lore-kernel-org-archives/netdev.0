From: Mikko Rapeli <mikko.rapeli@iki.fi>
Subject: [PATCH v05 22/72] include/uapi/linux/if_tunnel.h: include linux/if.h, linux/ip.h and linux/in6.h
Date: Mon, 22 Aug 2016 20:32:39 +0200
Message-ID: <1471890809-4383-23-git-send-email-mikko.rapeli@iki.fi>
References: <1471890809-4383-1-git-send-email-mikko.rapeli@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Mikko Rapeli <mikko.rapeli@iki.fi>,
        Stephen Hemminger <stephen@networkplumber.org>,
        "David S. Miller" <davem@davemloft.net>,
        Philip Prindeville <philipp@redfish-solutions.com>,
        netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471890809-4383-1-git-send-email-mikko.rapeli@iki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes userspace compilation errors like:

error: field ‘iph’ has incomplete type
error: field ‘prefix’ has incomplete type

Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
---
 include/uapi/linux/if_tunnel.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
index 1046f55..777b6cd 100644
--- a/include/uapi/linux/if_tunnel.h
+++ b/include/uapi/linux/if_tunnel.h
@@ -2,6 +2,9 @@
 #define _UAPI_IF_TUNNEL_H_
 
 #include <linux/types.h>
+#include <linux/if.h>
+#include <linux/ip.h>
+#include <linux/in6.h>
 #include <asm/byteorder.h>
 
 
-- 
2.8.1
