From: Vernon Sauder <vernoninhand@gmail.com>
Subject: [PATCH] fix smc911x.c printf typo
Date: Tue, 11 Nov 2008 23:05:48 -0500
Message-ID: <491A561C.5040105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Nicolas Pitre <nico@cam.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.26]:40900 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750845AbYKLEHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 23:07:20 -0500
Received: by qw-out-2122.google.com with SMTP id 3so133232qwe.37
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2008 20:07:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vernon Sauder <VernonInHand@gmail.com>

Fix printf format typo in smc911x driver.

I sent this to Dustin McIntire <dustin@sensoria.com> but the email
server rejected it.

Signed-off-by: Vernon Sauder <VernonInHand@gmail.com>
---
Patch against 2.6.28-rc4 Linus git tree.

 drivers/net/smc911x.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index 5051554..b965fec 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -1813,7 +1813,7 @@ static int __init smc911x_probe(struct net_device
*dev)
 	val = SMC_GET_BYTE_TEST(lp);
 	DBG(SMC_DEBUG_MISC, "%s: endian probe returned 0x%04x\n", CARDNAME, val);
 	if (val != 0x87654321) {
-		printk(KERN_ERR "Invalid chip endian 0x08%x\n",val);
+		printk(KERN_ERR "Invalid chip endian 0x%08x\n",val);
 		retval = -ENODEV;
 		goto err_out;
 	}
-- 
1.5.2.4

