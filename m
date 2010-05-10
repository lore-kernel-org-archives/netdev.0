From: kaber@trash.net
Subject: [PATCH 21/84] netfilter: xtables: resort osf kconfig text
Date: Mon, 10 May 2010 22:17:52 +0200
Message-ID: <1273522735-24672-22-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>

Restore alphabetical ordering of the list and put the xt_osf option
into its 'right' place again.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/netfilter/Kconfig |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 6ac28ef..8055786 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -774,6 +774,19 @@ config NETFILTER_XT_MATCH_MULTIPORT
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config NETFILTER_XT_MATCH_OSF
+	tristate '"osf" Passive OS fingerprint match'
+	depends on NETFILTER_ADVANCED && NETFILTER_NETLINK
+	help
+	  This option selects the Passive OS Fingerprinting match module
+	  that allows to passively match the remote operating system by
+	  analyzing incoming TCP SYN packets.
+
+	  Rules and loading software can be downloaded from
+	  http://www.ioremap.net/projects/osf
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 config NETFILTER_XT_MATCH_OWNER
 	tristate '"owner" match support'
 	depends on NETFILTER_ADVANCED
@@ -958,19 +971,6 @@ config NETFILTER_XT_MATCH_U32
 
 	  Details and examples are in the kernel module source.
 
-config NETFILTER_XT_MATCH_OSF
-	tristate '"osf" Passive OS fingerprint match'
-	depends on NETFILTER_ADVANCED && NETFILTER_NETLINK
-	help
-	  This option selects the Passive OS Fingerprinting match module
-	  that allows to passively match the remote operating system by
-	  analyzing incoming TCP SYN packets.
-
-	  Rules and loading software can be downloaded from
-	  http://www.ioremap.net/projects/osf
-
-	  To compile it as a module, choose M here.  If unsure, say N.
-
 endif # NETFILTER_XTABLES
 
 endmenu
-- 
1.7.0.4

