From: Vincent Sanders <vincent.sanders@collabora.co.uk>
Subject: [PATCH net-next 12/15] netlink: connector: Add idx and val identifiers for netfilter D-Bus
Date: Fri, 29 Jun 2012 17:45:51 +0100
Message-ID: <1340988354-26981-13-git-send-email-vincent.sanders@collabora.co.uk>
References: <1340988354-26981-1-git-send-email-vincent.sanders@collabora.co.uk>
Cc: Javier Martinez Canillas <javier.martinez@collabora.co.uk>,
	Alban Crequy <alban.crequy@collabora.co.uk>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1340988354-26981-1-git-send-email-vincent.sanders@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Javier Martinez Canillas <javier.martinez@collabora.co.uk>

The D-bus IPC system implements a transport that uses AF_BUS sockets to
send D-Bus messages to the peers. This allows decouple the routing logic
from the daemon and move it to the kernel which has the advantage of
reducing the number of context switches and the messages copied to
user-space.

A D-Bus protocol aware netfilter module decide which peer can recive a
given message based on a set of D-Bus match rules. These match rules
are set from user-space using the netlink connector API.

Signed-off-by: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
---
 include/linux/connector.h |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/linux/connector.h b/include/linux/connector.h
index c27be60..519d010 100644
--- a/include/linux/connector.h
+++ b/include/linux/connector.h
@@ -44,8 +44,10 @@
 #define CN_VAL_DRBD			0x1
 #define CN_KVP_IDX			0x9	/* HyperV KVP */
 #define CN_KVP_VAL			0x1	/* queries from the kernel */
+#define CN_IDX_NFDBUS                   0xA     /* netfilter D-Bus */
+#define CN_VAL_NFDBUS                   0x1
 
-#define CN_NETLINK_USERS		10	/* Highest index + 1 */
+#define CN_NETLINK_USERS		11	/* Highest index + 1 */
 
 /*
  * Maximum connector's message size.
-- 
1.7.10
