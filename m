From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Subject: [PATCH] atm: firestream: remove duplicate define
Date: Mon, 21 Oct 2013 10:12:41 +0200
Message-ID: <1382343161-3243-1-git-send-email-michael.opdenacker@free-electrons.com>
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Michael Opdenacker <michael.opdenacker@free-electrons.com>
To: chas@cmf.nrl.navy.mil
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes a duplicate define in drivers/atm/firestream.h

Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>
---
 drivers/atm/firestream.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/atm/firestream.h b/drivers/atm/firestream.h
index 49e783e..364eded 100644
--- a/drivers/atm/firestream.h
+++ b/drivers/atm/firestream.h
@@ -420,7 +420,6 @@ struct fs_transmit_config {
 #define RC_FLAGS_BFPS_BFP27 (0xd << 17)
 #define RC_FLAGS_BFPS_BFP47 (0xe << 17)
 
-#define RC_FLAGS_BFPS       (0x1 << 17)
 #define RC_FLAGS_BFPP       (0x1 << 21)
 #define RC_FLAGS_TEVC       (0x1 << 22)
 #define RC_FLAGS_TEP        (0x1 << 23)
-- 
1.8.1.2
