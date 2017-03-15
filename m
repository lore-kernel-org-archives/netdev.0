From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH net] MAINTAINERS: remove MACVLAN and VLAN entries
Date: Wed, 15 Mar 2017 18:39:46 +0100
Message-ID: <1489599586-31322-1-git-send-email-pablo@netfilter.org>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:47254 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751014AbdCOSdn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Mar 2017 14:33:43 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id A18CB1373AF
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 18:39:58 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 92C02DA86F
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 18:39:58 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 87191DA862
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 18:39:54 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

macvlan.c file seems to be both in VLAN and MACVLAN DRIVER, so remove
the MACVLAN DRIVER since this is redundant.

I propose with this patch to remove the VLAN (802.1Q) entry so this just
falls into the NETWORKING [GENERAL].

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
@David, please just place this in net-next if you find it more pertinent.
Thanks.

 MAINTAINERS | 15 ---------------
 1 file changed, 15 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index c265a5fe4848..4d68d9657ed0 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -7774,13 +7774,6 @@ F:	include/net/mac80211.h
 F:	net/mac80211/
 F:	drivers/net/wireless/mac80211_hwsim.[ch]
 
-MACVLAN DRIVER
-M:	Patrick McHardy <kaber@trash.net>
-L:	netdev@vger.kernel.org
-S:	Maintained
-F:	drivers/net/macvlan.c
-F:	include/linux/if_macvlan.h
-
 MAILBOX API
 M:	Jassi Brar <jassisinghbrar@gmail.com>
 L:	linux-kernel@vger.kernel.org
@@ -13384,14 +13377,6 @@ W:	https://linuxtv.org
 S:	Maintained
 F:	drivers/media/platform/vivid/*
 
-VLAN (802.1Q)
-M:	Patrick McHardy <kaber@trash.net>
-L:	netdev@vger.kernel.org
-S:	Maintained
-F:	drivers/net/macvlan.c
-F:	include/linux/if_*vlan.h
-F:	net/8021q/
-
 VLYNQ BUS
 M:	Florian Fainelli <f.fainelli@gmail.com>
 L:	openwrt-devel@lists.openwrt.org (subscribers-only)
-- 
2.1.4
