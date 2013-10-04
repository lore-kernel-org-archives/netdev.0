From: Matthew Whitehead <tedheadster@gmail.com>
Subject: [PATCH net-next] net: fujitsu: Remove ISA depdendency from Kconfig
Date: Fri,  4 Oct 2013 17:03:08 -0400
Message-ID: <1380920588-4121-1-git-send-email-tedheadster@gmail.com>
Cc: Matthew Whitehead <tedheadster@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:49699 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752629Ab3JDVDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 17:03:16 -0400
Received: by mail-qa0-f46.google.com with SMTP id j7so1455536qaq.5
        for <netdev@vger.kernel.org>; Fri, 04 Oct 2013 14:03:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There no longer are ISA drivers in the fujitsu directory, so remove the
dependency from the Kconfig.

Signed-off-by: Matthew Whitehead <tedheadster@gmail.com>
---
 drivers/net/ethernet/fujitsu/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/fujitsu/Kconfig b/drivers/net/ethernet/fujitsu/Kconfig
index 6231bc0..1085257 100644
--- a/drivers/net/ethernet/fujitsu/Kconfig
+++ b/drivers/net/ethernet/fujitsu/Kconfig
@@ -5,7 +5,7 @@
 config NET_VENDOR_FUJITSU
 	bool "Fujitsu devices"
 	default y
-	depends on ISA || PCMCIA
+	depends on PCMCIA
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
 	  and read the Ethernet-HOWTO, available from
-- 
1.7.2.5
