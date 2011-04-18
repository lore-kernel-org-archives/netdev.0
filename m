From: David Miller <davem@davemloft.net>
Subject: [PATCH 23/42] isdn: jade: Fix set-but-unused variables.
Date: Sun, 17 Apr 2011 17:33:41 -0700 (PDT)
Message-ID: <20110417.173341.116383954.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51054
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753992Ab1DRAeQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:34:16 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id DA21524C087
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:33:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The variable 'i' is set but unused in JadeVersion().  Just
kill it off.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/isdn/hisax/jade.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/hisax/jade.c b/drivers/isdn/hisax/jade.c
index ea8f840..a06cea0 100644
--- a/drivers/isdn/hisax/jade.c
+++ b/drivers/isdn/hisax/jade.c
@@ -23,10 +23,9 @@
 int
 JadeVersion(struct IsdnCardState *cs, char *s)
 {
-    int ver,i;
+    int ver;
     int to = 50;
     cs->BC_Write_Reg(cs, -1, 0x50, 0x19);
-    i=0;
     while (to) {
     	udelay(1);
 	ver = cs->BC_Read_Reg(cs, -1, 0x60);
-- 
1.7.4.3

