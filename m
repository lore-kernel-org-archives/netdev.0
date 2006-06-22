From: paul.moore@hp.com
Subject: [RFC 8/8] NetLabel: tie NetLabel into the Kconfig system
Date: Thu, 22 Jun 2006 18:49:19 -0400
Message-ID: <20060622225411.495345000@flek.zko.hp.com>
References: <20060622224910.885573000@flek.zko.hp.com>
Cc: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:20655 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S1161365AbWFVWye (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 18:54:34 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=netlabel-net_kconfig-2.6.17
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Modify the net/Kconfig file to enable selecting the NetLabel Kconfig options.
---
 net/Kconfig |    2 ++
 1 files changed, 2 insertions(+)

Index: linux-2.6.17.i686-quilt/net/Kconfig
===================================================================
--- linux-2.6.17.i686-quilt.orig/net/Kconfig
+++ linux-2.6.17.i686-quilt/net/Kconfig
@@ -228,6 +228,8 @@ source "net/tux/Kconfig"
 config WIRELESS_EXT
 	bool
 
+source "net/netlabel/Kconfig"
+
 endif   # if NET
 endmenu # Networking
 

--
paul moore
linux security @ hp
