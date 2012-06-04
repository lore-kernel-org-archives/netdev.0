From: Rostislav Lisovy <lisovy@gmail.com>
Subject: [PATCH 1/2] can: Add constants containing length of CAN identifiers
Date: Mon,  4 Jun 2012 18:09:35 +0200
Message-ID: <1338826176-11646-1-git-send-email-lisovy@gmail.com>
Cc: linux-can@vger.kernel.org, lartc@vger.kernel.org,
	pisa@cmp.felk.cvut.cz, sojkam1@fel.cvut.cz,
	Rostislav Lisovy <lisovy@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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

