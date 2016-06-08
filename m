From: Andreas Ziegler <andreas.ziegler@fau.de>
Subject: [PATCH] drivers/net/fsl_ucc: Do not prefix header guard with CONFIG_
Date: Wed,  8 Jun 2016 11:40:28 +0200
Message-ID: <1465378828-7077-1-git-send-email-andreas.ziegler@fau.de>
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	Valentin Rothberg <valentinrothberg@gmail.com>,
	linux-kernel@vger.kernel.org,
	Andreas Ziegler <andreas.ziegler@fau.de>
To: Zhao Qiang <qiang.zhao@nxp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The CONFIG_ prefix should only be used for options which
can be configured through Kconfig and not for guarding headers.

Signed-off-by: Andreas Ziegler <andreas.ziegler@fau.de>
---
 drivers/net/wan/fsl_ucc_hdlc.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wan/fsl_ucc_hdlc.h b/drivers/net/wan/fsl_ucc_hdlc.h
index 525786a..881ecde 100644
--- a/drivers/net/wan/fsl_ucc_hdlc.h
+++ b/drivers/net/wan/fsl_ucc_hdlc.h
@@ -8,8 +8,8 @@
  * option) any later version.
  */
 
-#ifndef CONFIG_UCC_HDLC_H
-#define CONFIG_UCC_HDLC_H
+#ifndef _UCC_HDLC_H_
+#define _UCC_HDLC_H_
 
 #include <linux/kernel.h>
 #include <linux/list.h>
-- 
1.9.1
