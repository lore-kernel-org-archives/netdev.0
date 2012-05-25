From: Rostislav Lisovy <lisovy@gmail.com>
Subject: [PATCH 1/2] can: Added constants containing length of CAN identifiers
Date: Fri, 25 May 2012 11:12:36 +0200
Message-ID: <1337937157-7680-1-git-send-email-lisovy@gmail.com>
Cc: linux-can@vger.kernel.org, pisa@cmp.felk.cvut.cz,
	sojkam1@fel.cvut.cz, oliver@hartkopp.net,
	Rostislav Lisovy <lisovy@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:45421 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751890Ab2EYJMt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2012 05:12:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The necessary information might be determined out of the CAN_*_MASK,
however it is undesirable to misuse masks for such purpose.

Signed-off-by: Rostislav Lisovy <lisovy@gmail.com>
---
 include/linux/can.h |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/linux/can.h b/include/linux/can.h
index 9a19bcb..08d1610 100644
--- a/include/linux/can.h
+++ b/include/linux/can.h
@@ -38,6 +38,9 @@
  */
 typedef __u32 canid_t;
 
+#define CAN_SFF_ID_BITS		11
+#define CAN_EFF_ID_BITS		29
+
 /*
  * Controller Area Network Error Frame Mask structure
  *
-- 
1.7.9.5
