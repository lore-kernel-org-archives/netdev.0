From: paul.moore@hp.com
Subject: [PATCH 7/7] NetLabel: tie NetLabel into the Kconfig system
Date: Fri, 14 Jul 2006 14:57:46 -0400
Message-ID: <20060714185918.218850000@flek.zko.hp.com>
References: <20060714185739.780700000@flek.zko.hp.com>
Cc: davem@davemloft.net, sds@epoch.ncsc.mil, jmorris@redhat.com,
	pratt@argus-systems.com, Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:56785 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S1161296AbWGNS7U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2006 14:59:20 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlabel-net_kconfig-2.6.18
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Modify the net/Kconfig file to enable selecting the NetLabel Kconfig options.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 net/Kconfig |    2 ++
 1 files changed, 2 insertions(+)

Index: linux-2.6.18-rc1/net/Kconfig
===================================================================
--- linux-2.6.18-rc1.orig/net/Kconfig
+++ linux-2.6.18-rc1/net/Kconfig
@@ -249,6 +249,8 @@ source "net/ieee80211/Kconfig"
 config WIRELESS_EXT
 	bool
 
+source "net/netlabel/Kconfig"
+
 endif   # if NET
 endmenu # Networking
 

--
paul moore
linux security @ hp
