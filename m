From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 4/5] documentation: fix wrt. headers rename
Date: Tue,  4 Aug 2009 03:11:40 +0400
Message-ID: <1249341101-11593-3-git-send-email-dbaryshkov@gmail.com>
References: <1249339902-10613-2-git-send-email-dbaryshkov@gmail.com>
 <1249341101-11593-1-git-send-email-dbaryshkov@gmail.com>
 <1249341101-11593-2-git-send-email-dbaryshkov@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Sergey Lapin <slapin@ossfans.org>,
	linux-zigbee-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:58098 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753779AbZHCXMI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2009 19:12:08 -0400
Received: by mail-fx0-f217.google.com with SMTP id 17so2946973fxm.37
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2009 16:12:09 -0700 (PDT)
In-Reply-To: <1249341101-11593-2-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
---
 Documentation/networking/ieee802154.txt |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/Documentation/networking/ieee802154.txt b/Documentation/networking/ieee802154.txt
index 1d4ed66..1c0c82c 100644
--- a/Documentation/networking/ieee802154.txt
+++ b/Documentation/networking/ieee802154.txt
@@ -22,7 +22,7 @@ int sd = socket(PF_IEEE802154, SOCK_DGRAM, 0);
 .....
 
 The address family, socket addresses etc. are defined in the
-include/net/ieee802154/af_ieee802154.h header or in the special header
+include/net/af_ieee802154.h header or in the special header
 in our userspace package (see either linux-zigbee sourceforge download page
 or git tree at git://linux-zigbee.git.sourceforge.net/gitroot/linux-zigbee).
 
@@ -33,7 +33,7 @@ MLME - MAC Level Management
 ============================
 
 Most of IEEE 802.15.4 MLME interfaces are directly mapped on netlink commands.
-See the include/net/ieee802154/nl802154.h header. Our userspace tools package
+See the include/net/nl802154.h header. Our userspace tools package
 (see above) provides CLI configuration utility for radio interfaces and simple
 coordinator for IEEE 802.15.4 networks as an example users of MLME protocol.
 
@@ -54,7 +54,7 @@ Those types of devices require different approach to be hooked into Linux kernel
 HardMAC
 =======
 
-See the header include/net/ieee802154/netdevice.h. You have to implement Linux
+See the header include/net/ieee802154_netdev.h. You have to implement Linux
 net_device, with .type = ARPHRD_IEEE802154. Data is exchanged with socket family
 code via plain sk_buffs. The control block of sk_buffs will contain additional
 info as described in the struct ieee802154_mac_cb.
@@ -72,5 +72,4 @@ SoftMAC
 We are going to provide intermediate layer implementing IEEE 802.15.4 MAC
 in software. This is currently WIP.
 
-See header include/net/ieee802154/mac802154.h and several drivers in
-drivers/ieee802154/
+See header include/net/mac802154.h and several drivers in drivers/ieee802154/.
-- 
1.6.3.3

