From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH] drivers: isdn: eicon: xdi_msg.h: Fix typo in #ifndef
Date: Fri, 22 Aug 2014 18:39:14 +0200
Message-ID: <1408725554-2524-1-git-send-email-linux@rasmusvillemoes.dk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Rasmus Villemoes <linux@rasmusvillemoes.dk>
To: Armin Schindler <mac@melware.de>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Test for definedness of the macro which is actually defined (the
change is hard to see: it is s/SSS/SSA/).

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 drivers/isdn/hardware/eicon/xdi_msg.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/isdn/hardware/eicon/xdi_msg.h b/drivers/isdn/hardware/eicon/xdi_msg.h
index 58368f7..2498c34 100644
--- a/drivers/isdn/hardware/eicon/xdi_msg.h
+++ b/drivers/isdn/hardware/eicon/xdi_msg.h
@@ -1,6 +1,6 @@
 /* $Id: xdi_msg.h,v 1.1.2.2 2001/02/16 08:40:36 armin Exp $ */
 
-#ifndef __DIVA_XDI_UM_CFG_MESSSGE_H__
+#ifndef __DIVA_XDI_UM_CFG_MESSAGE_H__
 #define __DIVA_XDI_UM_CFG_MESSAGE_H__
 
 /*
-- 
2.0.4
