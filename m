From: paul.moore@hp.com
Subject: [PATCH v2 8/8] NetLabel: update docs with website information
Date: Mon, 25 Sep 2006 14:04:20 -0400
Message-ID: <20060925180644.042122000@hp.com>
References: <20060925180412.715069000@hp.com>
Cc: tgraf@suug.ch, jmorris@redhat.com, sds@epoch.ncsc.mil,
	Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:29856 "EHLO atlrel7.hp.com")
	by vger.kernel.org with ESMTP id S1751421AbWIYSGu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 14:06:50 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlabel-doc_update
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that all of the supporting pieces of NetLabel have a home at SourceForge
update the Kconfig help text and add an entry to the MAINTAINERS file.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 MAINTAINERS          |    7 +++++++
 net/netlabel/Kconfig |    5 ++++-
 2 files changed, 11 insertions(+), 1 deletion(-)

Index: net-2.6.19/MAINTAINERS
===================================================================
--- net-2.6.19.orig/MAINTAINERS
+++ net-2.6.19/MAINTAINERS
@@ -2008,6 +2008,13 @@ L:	netfilter@lists.netfilter.org
 L:	netfilter-devel@lists.netfilter.org
 S:	Supported
 
+NETLABEL
+P:	Paul Moore
+M:	paul.moore@hp.com
+W:	http://netlabel.sf.net
+L:	netdev@vger.kernel.org
+S:	Supported
+
 NETROM NETWORK LAYER
 P:	Ralf Baechle
 M:	ralf@linux-mips.org
Index: net-2.6.19/net/netlabel/Kconfig
===================================================================
--- net-2.6.19.orig/net/netlabel/Kconfig
+++ net-2.6.19/net/netlabel/Kconfig
@@ -9,6 +9,9 @@ config NETLABEL
 	---help---
 	  NetLabel provides support for explicit network packet labeling
 	  protocols such as CIPSO and RIPSO.  For more information see
-	  Documentation/netlabel.
+	  Documentation/netlabel as well as the NetLabel SourceForge project
+	  for configuration tools and additional documentation.
+
+	   * http://netlabel.sf.net
 
 	  If you are unsure, say N.

--
paul moore
linux security @ hp
