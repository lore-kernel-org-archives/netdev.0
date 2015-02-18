From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH] ipvlan: Fix text that talks about ip util support
Date: Wed, 18 Feb 2015 15:15:57 -0800
Message-ID: <1424301357-25182-1-git-send-email-maheshb@google.com>
Cc: Mahesh Bandewar <maheshb@google.com>
To: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f201.google.com ([209.85.213.201]:46076 "EHLO
	mail-ig0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752345AbbBRXQC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2015 18:16:02 -0500
Received: by mail-ig0-f201.google.com with SMTP id b16so1818685igk.0
        for <netdev@vger.kernel.org>; Wed, 18 Feb 2015 15:16:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipvlan was added into 3.19 release and iproute2 added support
for the same in iproute2-3.19 package.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
CC: Stephen Hemminger <stephen@networkplumber.org>
---
 drivers/net/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 84673ebcf428..df51d6025a90 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -157,7 +157,7 @@ config IPVLAN
       making it transparent to the connected L2 switch.
 
       Ipvlan devices can be added using the "ip" command from the
-      iproute2 package starting with the iproute2-X.Y.ZZ release:
+      iproute2 package starting with the iproute2-3.19 release:
 
       "ip link add link <main-dev> [ NAME ] type ipvlan"
 
-- 
2.2.0.rc0.207.ga3a616c
