From: Ben Dooks <ben@simtec.co.uk>
Subject: DM9000: Fix revision ID for DM9000B
Date: Fri, 23 Oct 2009 11:26:31 +0100
Message-ID: <20091023102631.373421273@fluff.org.uk>
Cc: Simtec Linux Team <linux@simtec.co.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:49909 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751727AbZJWK02 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 06:26:28 -0400
Content-Disposition: inline; filename=dm9000-fix-revb-id.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The DM9000B revision ID is 0x1A, not 0x1B as set in the curernt dm9000.h
header.

Fix bug reported by Paolo Zebelloni.

Signed-off-by: Ben Dooks <ben@simtec.co.uk>
Signed-off-by: Simtec Linux Team <linux@simtec.co.uk>
---
 drivers/net/dm9000.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: b/drivers/net/dm9000.h
===================================================================
--- a/drivers/net/dm9000.h	2009-10-22 12:33:48.000000000 +0100
+++ b/drivers/net/dm9000.h	2009-10-22 12:33:53.000000000 +0100
@@ -50,7 +50,7 @@
 #define DM9000_RCSR	       0x32
 
 #define CHIPR_DM9000A	       0x19
-#define CHIPR_DM9000B	       0x1B
+#define CHIPR_DM9000B	       0x1A
 
 #define DM9000_MRCMDX          0xF0
 #define DM9000_MRCMD           0xF2

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
