From: Steven King <sfking@fdwdc.com>
Subject: [PATCH] dm9000: some coldfire boards need this
Date: Fri, 11 May 2012 09:49:46 -0700
Message-ID: <201205110949.46767.sfking@fdwdc.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm28-vm0.access.bullet.mail.mud.yahoo.com ([66.94.236.229]:32372
	"HELO nm28-vm0.access.bullet.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753950Ab2EKQ4J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 12:56:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some coldfire boards (ie m5253demo) have a dm9000 onboard.

Signed-off-by: Steven King <sfking@fdwdc.com>
---
 drivers/net/ethernet/davicom/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/davicom/Kconfig b/drivers/net/ethernet/davicom/Kconfig
index 972b62b..9745fe5 100644
--- a/drivers/net/ethernet/davicom/Kconfig
+++ b/drivers/net/ethernet/davicom/Kconfig
@@ -4,7 +4,7 @@
 
 config DM9000
 	tristate "DM9000 support"
-	depends on ARM || BLACKFIN || MIPS
+	depends on ARM || BLACKFIN || MIPS || COLDFIRE
 	select CRC32
 	select NET_CORE
 	select MII
