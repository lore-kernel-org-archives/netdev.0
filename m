From: David Miller <davem@davemloft.net>
Subject: [PATCH 20/42] isdn: elsa_ser: Fix set-but-unused variables.
Date: Sun, 17 Apr 2011 17:33:33 -0700 (PDT)
Message-ID: <20110417.173333.35044668.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51045
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753961Ab1DRAeH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:34:07 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 5C43124C089
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:33:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The variable 'bits' is set but unused in
change_speed().  Just kill it off.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/isdn/hisax/elsa_ser.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/hisax/elsa_ser.c b/drivers/isdn/hisax/elsa_ser.c
index cbda379..3fa9f61 100644
--- a/drivers/isdn/hisax/elsa_ser.c
+++ b/drivers/isdn/hisax/elsa_ser.c
@@ -109,11 +109,10 @@ static void change_speed(struct IsdnCardState *cs, int baud)
 {
 	int	quot = 0, baud_base;
 	unsigned cval, fcr = 0;
-	int	bits;
 
 
 	/* byte size and parity */
-	cval = 0x03; bits = 10;
+	cval = 0x03;
 	/* Determine divisor based on baud rate */
 	baud_base = BASE_BAUD;
 	quot = baud_base / baud;
-- 
1.7.4.3

