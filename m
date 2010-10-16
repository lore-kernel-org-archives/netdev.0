From: Tracey Dent <tdent48227@gmail.com>
Subject: [PATCH] Drivers: atm: Makefile: replace the use of <module>-objs with <module>-y
Date: Fri, 15 Oct 2010 23:53:29 -0400
Message-ID: <1287201209-2101-1-git-send-email-tdent48227@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net,
	Tracey Dent <tdent48227@gmail.com>
To: chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:59566 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752787Ab0JPDxq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 23:53:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changed <module>-objs to <module>-y in Makefile.

Signed-off-by: Tracey Dent <tdent48227@gmail.com>
---
 drivers/atm/Makefile |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/atm/Makefile b/drivers/atm/Makefile
index 62c3cc1..c6c9ee9 100644
--- a/drivers/atm/Makefile
+++ b/drivers/atm/Makefile
@@ -2,7 +2,7 @@
 # Makefile for the Linux network (ATM) device drivers.
 #
 
-fore_200e-objs	:= fore200e.o
+fore_200e-y	:= fore200e.o
 
 obj-$(CONFIG_ATM_ZATM)		+= zatm.o uPD98402.o
 obj-$(CONFIG_ATM_NICSTAR)	+= nicstar.o
-- 
1.7.3.1.104.gc752e

