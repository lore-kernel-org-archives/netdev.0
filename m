From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-next] Documentation/sysctl/net.txt: fix (attribute removal).
Date: Fri, 17 May 2013 22:10:34 +0300
Message-ID: <1368817834-5915-1-git-send-email-ramirose@gmail.com>
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	Rami Rosen <ramirose@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f175.google.com ([209.85.215.175]:35350 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755886Ab3EQTL1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 15:11:27 -0400
Received: by mail-ea0-f175.google.com with SMTP id h10so2532098eaj.34
        for <netdev@vger.kernel.org>; Fri, 17 May 2013 12:11:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes mentioning the sysfsf net_device weight attribute
(class/net/<device>/weight)  
in Documentation/sysctl/net.txt, since the net sysfs weight attribute
was removed by the following patch:

[NET]: Make NAPI polling independent of struct net_device objects
 bea3348eef27e6044b6161fd04c3152215f96411

Signed-off-by: Rami Rosen <ramirose@gmail.com>
---
 Documentation/sysctl/net.txt | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/Documentation/sysctl/net.txt b/Documentation/sysctl/net.txt
index 98335b7..c1f8640 100644
--- a/Documentation/sysctl/net.txt
+++ b/Documentation/sysctl/net.txt
@@ -93,8 +93,7 @@ netdev_budget
 
 Maximum number of packets taken from all interfaces in one polling cycle (NAPI
 poll). In one polling cycle interfaces which are registered to polling are
-probed in a round-robin manner. The limit of packets in one such probe can be
-set per-device via sysfs class/net/<device>/weight .
+probed in a round-robin manner.
 
 netdev_max_backlog
 ------------------
-- 
1.8.1.4
