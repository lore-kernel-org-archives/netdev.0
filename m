From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1] drivers/net/hyperv/netvsc.c: remove unnecessary null test before kfree
Date: Sat, 28 Jun 2014 20:44:19 +0200
Message-ID: <1403981059-10189-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>, netdev@vger.kernel.org
To: haiyangz@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay010.isp.belgacom.be ([195.238.6.177]:13726 "EHLO
	mailrelay010.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755908AbaF1Spz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jun 2014 14:45:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix checkpatch warning:
WARNING: kfree(NULL) is safe this check is probably not required

Cc: Haiyang Zhang <haiyangz@microsoft.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/hyperv/netvsc.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 4ed38ea..f13e0ac 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -1094,9 +1094,7 @@ close:
 	vmbus_close(device->channel);
 
 cleanup:
-
-	if (net_device)
-		kfree(net_device);
+	kfree(net_device);
 
 	return ret;
 }
-- 
1.8.4.5
