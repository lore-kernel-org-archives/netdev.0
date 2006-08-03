From: paul.moore@hp.com
Subject: [PATCH-v01 7/7] NetLabel: tie NetLabel into the Kconfig system
Date: Thu, 03 Aug 2006 16:09:35 -0400
Message-ID: <20060803201559.266161000@flek.zko.hp.com>
References: <20060803200928.721027000@flek.zko.hp.com>
Cc: linda.knippers@hp.com, sds@tycho.nsa.gov, jmorris@namei.org,
	davem@davemloft.net, Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:29063 "EHLO atlrel7.hp.com")
	by vger.kernel.org with ESMTP id S932581AbWHCUQD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2006 16:16:03 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlabel-net_kconfig-2.6.19
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Modify the net/Kconfig file to enable selecting the NetLabel Kconfig options.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 net/Kconfig |    2 ++
 1 files changed, 2 insertions(+)

Index: net-2.6.19/net/Kconfig
===================================================================
--- net-2.6.19.orig/net/Kconfig
+++ net-2.6.19/net/Kconfig
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
