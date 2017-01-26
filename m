From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 3/7] uapi: install batman_adv.h header
Date: Thu, 26 Jan 2017 17:44:00 +0100
Message-ID: <20170126164404.16074-4-sw@simonwunderlich.de>
References: <20170126164404.16074-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:54048 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753382AbdAZQoP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 11:44:15 -0500
In-Reply-To: <20170126164404.16074-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

09748a22f4ab ("batman-adv: add generic netlink family for batman-adv")
introduced the new batman_adv.h which describes the netlink attributes and
commands of batman-adv. But the Kbuild entry to install the header was not
added.

All currently known tools ship their own copy of batman_adv.h but it should
be installed anyway to later be able to migrate to the system batman_adv.h.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 include/uapi/linux/Kbuild | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/Kbuild b/include/uapi/linux/Kbuild
index a8b93e685239..7fdceb2ac5b7 100644
--- a/include/uapi/linux/Kbuild
+++ b/include/uapi/linux/Kbuild
@@ -64,6 +64,7 @@ header-y += auto_fs.h
 header-y += auxvec.h
 header-y += ax25.h
 header-y += b1lli.h
+header-y += batman_adv.h
 header-y += baycom.h
 header-y += bcm933xx_hcs.h
 header-y += bfs_fs.h
-- 
2.11.0
