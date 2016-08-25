From: citestra <oussamamrkd2@gmail.com>
Subject: [PATCH net-next] drivers/net: Use priority level to printk() calls
Date: Fri, 26 Aug 2016 00:22:41 +0200
Message-ID: <1472163761-14015-1-git-send-email-oussamamrkd2@gmail.com>
Cc: citestra <oussamamrkd2@gmail.com>,
        Oussama Markad <markad.oussama@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34236 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754144AbcHYWXq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 18:23:46 -0400
Received: by mail-wm0-f66.google.com with SMTP id q128so9129927wma.1
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 15:22:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add priority level 'KERN_ERR' to a printk() call

Signed-off-by: Oussama Markad <markad.oussama@gmail.com>
Signed-off-by: citestra <oussamamrkd2@gmail.com>
---
 drivers/net/ethernet/amd/am79c961a.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/am79c961a.c b/drivers/net/ethernet/amd/am79c961a.c
index fcdf5dd..e4aad66 100644
--- a/drivers/net/ethernet/amd/am79c961a.c
+++ b/drivers/net/ethernet/amd/am79c961a.c
@@ -182,7 +182,7 @@ am79c961_ramtest(struct net_device *dev, unsigned int val)
 	am_readbuffer(dev, 0, buffer, 65536);
 	for (i = 0; i < 65536; i++) {
 		if (buffer[i] != val && !error) {
-			printk ("%s: buffer error (%02X %02X) %05X - ", dev->name, val, buffer[i], i);
+			printk (KERN_ERR "%s: buffer error (%02X %02X) %05X - ", dev->name, val, buffer[i], i);
 			error = 1;
 			errorcount ++;
 		} else if (error && buffer[i] == val) {
-- 
2.7.4
