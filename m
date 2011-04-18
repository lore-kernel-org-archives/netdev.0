From: David Miller <davem@davemloft.net>
Subject: [PATCH 41/42] isdn: i4l: isdn_tty: Fix unused-but-set variables.
Date: Sun, 17 Apr 2011 17:34:30 -0700 (PDT)
Message-ID: <20110417.173430.42803462.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51108
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754205Ab1DRAfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:35:05 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id C44A924C087
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:34:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The variable 'fcr' is set but not used in isdn_tty_change_speed().

Just kill it off.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/isdn/i4l/isdn_tty.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/i4l/isdn_tty.c b/drivers/isdn/i4l/isdn_tty.c
index 607d846..d850427 100644
--- a/drivers/isdn/i4l/isdn_tty.c
+++ b/drivers/isdn/i4l/isdn_tty.c
@@ -998,7 +998,6 @@ isdn_tty_change_speed(modem_info * info)
 {
 	uint cflag,
 	 cval,
-	 fcr,
 	 quot;
 	int i;
 
@@ -1037,7 +1036,6 @@ isdn_tty_change_speed(modem_info * info)
 		cval |= UART_LCR_PARITY;
 	if (!(cflag & PARODD))
 		cval |= UART_LCR_EPAR;
-	fcr = 0;
 
 	/* CTS flow control flag and modem status interrupts */
 	if (cflag & CRTSCTS) {
-- 
1.7.4.3

