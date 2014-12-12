From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net] net: ethernet: davicom: Allow to select DM9000 for nios2
Date: Fri, 12 Dec 2014 10:21:11 +0100
Message-ID: <1418376071-28709-1-git-send-email-tklauser@distanz.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:58242 "EHLO mail.zhinst.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933200AbaLLJVN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Dec 2014 04:21:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This chip is present on older revisions of the DE2 development kit.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/davicom/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/davicom/Kconfig b/drivers/net/ethernet/davicom/Kconfig
index 316c5e5..7ec2d74 100644
--- a/drivers/net/ethernet/davicom/Kconfig
+++ b/drivers/net/ethernet/davicom/Kconfig
@@ -4,7 +4,7 @@
 
 config DM9000
 	tristate "DM9000 support"
-	depends on ARM || BLACKFIN || MIPS || COLDFIRE
+	depends on ARM || BLACKFIN || MIPS || COLDFIRE || NIOS2
 	select CRC32
 	select MII
 	---help---
-- 
2.2.0
