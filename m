From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 3/7] smsc75xx: add more information to register io failure warnings
Date: Mon, 30 Apr 2012 18:56:52 +0100
Message-ID: <1335808616-22513-4-git-send-email-steve.glendinning@shawell.net>
References: <1335808616-22513-1-git-send-email-steve.glendinning@shawell.net>
Cc: David Miller <davem@davemloft.net>,
	Stephane Fillod <fillods@users.sf.net>,
	Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:49413 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756336Ab2D3R5N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 13:57:13 -0400
In-Reply-To: <1335808616-22513-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephane Fillod <fillods@users.sf.net>
Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc75xx.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index f97207a..1de7785 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -98,7 +98,7 @@ static int __must_check smsc75xx_read_reg(struct usbnet *dev, u32 index,
 
 	if (unlikely(ret < 0))
 		netdev_warn(dev->net,
-			"Failed to read register index 0x%08x", index);
+			"Failed to read reg index 0x%08x: %d", index, ret);
 
 	le32_to_cpus(buf);
 	*data = *buf;
@@ -128,7 +128,7 @@ static int __must_check smsc75xx_write_reg(struct usbnet *dev, u32 index,
 
 	if (unlikely(ret < 0))
 		netdev_warn(dev->net,
-			"Failed to write register index 0x%08x", index);
+			"Failed to write reg index 0x%08x: %d", index, ret);
 
 	kfree(buf);
 
-- 
1.7.9.5
