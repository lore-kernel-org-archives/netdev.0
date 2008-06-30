From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [NETFILTER Kconfig help text]: bridge: add ebt_nflog watcher
Date: Mon, 30 Jun 2008 20:17:34 +0200
Message-ID: <m3bq1i6b41.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>
To: Peter Warasin <peter@endian.com>, Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:43643 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752903AbYF3SRg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jun 2008 14:17:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

is the following really correct?
e7bfd0a1a6c8f82977253dab19be9d9979c1ec1b

------------------------- net/bridge/netfilter/Kconfig -------------------------
index 4a3e2bf..7beeefa 100644
@@ -214,2 +214,16 @@ config BRIDGE_EBT_ULOG
 
+config BRIDGE_EBT_NFLOG
+	tristate "ebt: nflog support"
+	depends on BRIDGE_NF_EBTABLES
+	help
+	  This option enables the nflog watcher, which allows to LOG
+	  messages through the netfilter logging API, which can use
+	  either the old LOG target, the old ULOG target or nfnetlink_log
+	  as backend.
+
+	  This option adds the ulog watcher, that you can use in any rule
                               ^^^^^^^^^^^^
+	  in any ebtables table.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 endmenu


ulog watcher?
-- 
Krzysztof Halasa
