From: zwu.kernel@gmail.com
Subject: [PATCH] vxlan: fix command usage in its doc
Date: Thu, 22 Nov 2012 18:10:01 +0800
Message-ID: <1353579001-31052-1-git-send-email-zwu.kernel@gmail.com>
Cc: davem@davemloft.net, zwu.kernel@gmail.com,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:37490 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754308Ab2KVUnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2012 15:43:10 -0500
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <zwu.kernel@gmail.com>;
	Thu, 22 Nov 2012 03:12:14 -0700
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 35B4419D8047
	for <netdev@vger.kernel.org>; Thu, 22 Nov 2012 03:10:15 -0700 (MST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qAMAAEbH384790
	for <netdev@vger.kernel.org>; Thu, 22 Nov 2012 03:10:14 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qAMAAEEA000346
	for <netdev@vger.kernel.org>; Thu, 22 Nov 2012 03:10:14 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

  Some commands don't work in its example doc. The patch will fix it.

Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
---
 Documentation/networking/vxlan.txt |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/vxlan.txt b/Documentation/networking/vxlan.txt
index 5b34b76..6d99351 100644
--- a/Documentation/networking/vxlan.txt
+++ b/Documentation/networking/vxlan.txt
@@ -32,7 +32,7 @@ no entry is in the forwarding table.
   # ip link delete vxlan0
 
 3. Show vxlan info
-  # ip -d show vxlan0
+  # ip -d link show vxlan0
 
 It is possible to create, destroy and display the vxlan
 forwarding table using the new bridge command.
@@ -41,7 +41,7 @@ forwarding table using the new bridge command.
   # bridge fdb add to 00:17:42:8a:b4:05 dst 192.19.0.2 dev vxlan0
 
 2. Delete forwarding table entry
-  # bridge fdb delete 00:17:42:8a:b4:05
+  # bridge fdb delete 00:17:42:8a:b4:05 dev vxlan0
 
 3. Show forwarding table
   # bridge fdb show dev vxlan0
-- 
1.7.6.5
