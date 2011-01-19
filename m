From: kaber@trash.net
Subject: [PATCH 71/79] netfilter: Kconfig: NFQUEUE is useless without NETFILTER_NETLINK_QUEUE
Date: Wed, 19 Jan 2011 20:15:11 +0100
Message-ID: <1295464519-21763-72-git-send-email-kaber@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1295464519-21763-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

NFLOG already does the same thing for NETFILTER_NETLINK_LOG.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 93918f0..e2480bd 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -487,6 +487,7 @@ config NETFILTER_XT_TARGET_NFLOG
 config NETFILTER_XT_TARGET_NFQUEUE
 	tristate '"NFQUEUE" target Support'
 	depends on NETFILTER_ADVANCED
+	select NETFILTER_NETLINK_QUEUE
 	help
 	  This target replaced the old obsolete QUEUE target.
 
-- 
1.7.2.3

