From: paul.moore@hp.com
Subject: [PATCH 6/6] NetLabel: update docs with website information
Date: Thu, 21 Sep 2006 12:57:09 -0400
Message-ID: <20060921170338.666423000@hp.com>
References: <20060921165703.251871000@hp.com>
Cc: sds@epoch.ncsc.mil, jmorris@redhat.com, tgraf@suug.ch,
	Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:50412 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S1751357AbWIURDk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2006 13:03:40 -0400
To: selinux@tycho.nsa.gov, netdev@vger.kernel.org
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
