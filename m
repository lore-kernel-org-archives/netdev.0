From: Randy Dunlap <rdunlap@infradead.org>
Subject: [PATCH] netfilter: fix connlimit Kconfig prompt string
Date: Wed, 06 Nov 2013 21:48:22 -0800
Message-ID: <527B29A6.6090802@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, lailavrazda1979@gmail.com
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@infradead.org>

Under Core Netfilter Configuration, connlimit match support has
an extra double quote at the end of it.

Fixes a portion of kernel bugzilla #52671:
  https://bugzilla.kernel.org/show_bug.cgi?id=52671

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
Reported-by: lailavrazda1979@gmail.com
---
 net/netfilter/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- lnx-312.orig/net/netfilter/Kconfig
+++ lnx-312/net/netfilter/Kconfig
@@ -857,7 +857,7 @@ config NETFILTER_XT_MATCH_CONNLABEL
 	  connection simultaneously.
 
 config NETFILTER_XT_MATCH_CONNLIMIT
-	tristate '"connlimit" match support"'
+	tristate '"connlimit" match support'
 	depends on NF_CONNTRACK
 	depends on NETFILTER_ADVANCED
 	---help---
