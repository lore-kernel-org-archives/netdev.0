From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] irda: Fix typo in irda
Date: Sat, 14 Jul 2012 02:22:47 +0900
Message-ID: <1342200167-14934-1-git-send-email-standby24x7@gmail.com>
Cc: linux-kernel@vger.kernel.org, trivial@kernel.org,
	Masanari Iida <standby24x7@gmail.com>
To: netdev@vger.kernel.org, samuel@sortiz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Correct spelling typo in irda.

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 net/irda/af_irda.c              | 2 +-
 net/irda/irlan/irlan_provider.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index bb14c34..bb738c9f 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -955,7 +955,7 @@ out:
  * The main difference with a "standard" connect is that with IrDA we need
  * to resolve the service name into a TSAP selector (in TCP, port number
  * doesn't have to be resolved).
- * Because of this service name resoltion, we can offer "auto-connect",
+ * Because of this service name resolution, we can offer "auto-connect",
  * where we connect to a service without specifying a destination address.
  *
  * Note : by consulting "errno", the user space caller may learn the cause
diff --git a/net/irda/irlan/irlan_provider.c b/net/irda/irlan/irlan_provider.c
index 32dcaac..4664855 100644
--- a/net/irda/irlan/irlan_provider.c
+++ b/net/irda/irlan/irlan_provider.c
@@ -296,7 +296,7 @@ void irlan_provider_send_reply(struct irlan_cb *self, int command,
 	skb = alloc_skb(IRLAN_MAX_HEADER + IRLAN_CMD_HEADER +
 			/* Bigger param length comes from CMD_GET_MEDIA_CHAR */
 			IRLAN_STRING_PARAMETER_LEN("FILTER_TYPE", "DIRECTED") +
-			IRLAN_STRING_PARAMETER_LEN("FILTER_TYPE", "BORADCAST") +
+			IRLAN_STRING_PARAMETER_LEN("FILTER_TYPE", "BROADCAST") +
 			IRLAN_STRING_PARAMETER_LEN("FILTER_TYPE", "MULTICAST") +
 			IRLAN_STRING_PARAMETER_LEN("ACCESS_TYPE", "HOSTED"),
 			GFP_ATOMIC);
-- 
1.7.11.2.138.g2b53359
