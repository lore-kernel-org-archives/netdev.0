From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 3/4] atl1: remove EXPERIMENTAL label
Date: Sat, 27 Sep 2008 09:17:22 -0500
Message-ID: <1222525043-4648-4-git-send-email-jacliburn@bellsouth.net>
References: <1222525043-4648-1-git-send-email-jacliburn@bellsouth.net>
Cc: csnook@redhat.com, jie.yang@atheros.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jay Cliburn <jacliburn@bellsouth.net>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost05.isp.att.net ([207.115.11.55]:46811 "EHLO
	fmailhost05.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751603AbYI0OW0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Sep 2008 10:22:26 -0400
In-Reply-To: <1222525043-4648-1-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the EXPERIMENTAL label from the atl1 driver and change the vendor
name to include Attansic's successor, Atheros.  We'll leave Attansic in
the name since Attansic's PCI ID (1969) is encoded in the PCI config and
is what users encounter on their systems.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/Kconfig |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 4a11296..1c8addf 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2281,12 +2281,13 @@ config QLA3XXX
 	  will be called qla3xxx.
 
 config ATL1
-	tristate "Attansic L1 Gigabit Ethernet support (EXPERIMENTAL)"
-	depends on PCI && EXPERIMENTAL
+	tristate "Atheros/Attansic L1 Gigabit Ethernet support"
+	depends on PCI
 	select CRC32
 	select MII
 	help
-	  This driver supports the Attansic L1 gigabit ethernet adapter.
+	  This driver supports the Atheros/Attansic L1 gigabit ethernet
+	  adapter.
 
 	  To compile this driver as a module, choose M here.  The module
 	  will be called atl1.
-- 
1.5.5.1

