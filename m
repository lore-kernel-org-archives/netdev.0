From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH] phy: SMSC: fix unused warnings when built into kernel
Date: Fri,  6 Aug 2010 02:27:14 -0400
Message-ID: <1281076034-17390-1-git-send-email-vapier@gentoo.org>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:42847 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751962Ab0HFG1J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Aug 2010 02:27:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the SMSC phy is not built as a module, we get the warning:
	drivers/net/phy/smsc.c:257: warning: 'smsc_tbl' defined but not used

So mark the structure as maybe unused to avoid this.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 drivers/net/phy/smsc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
index 78fa988..11944ef 100644
--- a/drivers/net/phy/smsc.c
+++ b/drivers/net/phy/smsc.c
@@ -254,7 +254,7 @@ MODULE_LICENSE("GPL");
 module_init(smsc_init);
 module_exit(smsc_exit);
 
-static struct mdio_device_id smsc_tbl[] = {
+static __maybe_unused struct mdio_device_id smsc_tbl[] = {
 	{ 0x0007c0a0, 0xfffffff0 },
 	{ 0x0007c0b0, 0xfffffff0 },
 	{ 0x0007c0c0, 0xfffffff0 },
-- 
1.7.2

