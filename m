From: paul.moore@hp.com
Subject: [PATCH 7/7] NetLabel: tie NetLabel into the Kconfig system
Date: Mon, 17 Jul 2006 11:52:31 -0400
Message-ID: <20060717155825.957956000@hp.com>
References: <20060717155224.060020000@hp.com>
Cc: davem@davemloft.net, sds@epoch.ncsc.mil, jmorris@redhat.com,
	pratt@argus-systems.com, Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:40888 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S1750915AbWGQP62 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2006 11:58:28 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlabel-net_kconfig-2.6.18
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Modify the net/Kconfig file to enable selecting the NetLabel Kconfig options.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 net/Kconfig |    2 ++
 1 files changed, 2 insertions(+)

Index: linux-2.6.18-rc2/net/Kconfig
===================================================================
--- linux-2.6.18-rc2.orig/net/Kconfig
+++ linux-2.6.18-rc2/net/Kconfig
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
