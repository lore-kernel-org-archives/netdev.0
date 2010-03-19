From: Paulius Zaleckas <paulius.zaleckas@gmail.com>
Subject: [PATCH v2] if_tunnel.h: add missing ams/byteorder.h include
Date: Fri, 19 Mar 2010 17:09:26 +0200
Message-ID: <20100319150926.11037.39136.stgit@pauliusz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: contact@saschahlusiak.de, eric.dumazet@gmail.com,
	Fred.L.Templin@boeing.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When compiling userspace application which includes
if_tunnel.h and uses GRE_* defines you will get undefined
reference to __cpu_to_be16.

Fix this by adding missing #include <asm/byteorder.h>

Cc: stable@kernel.org
Signed-off-by: Paulius Zaleckas <paulius.zaleckas@gmail.com>
---

 include/linux/if_tunnel.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
index 1822d63..16b92d0 100644
--- a/include/linux/if_tunnel.h
+++ b/include/linux/if_tunnel.h
@@ -2,6 +2,7 @@
 #define _IF_TUNNEL_H_
 
 #include <linux/types.h>
+#include <asm/byteorder.h>
 
 #ifdef __KERNEL__
 #include <linux/ip.h>
