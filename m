From: <gregkh@linuxfoundation.org>
Subject: patch "isdn: i4l: Remove ASYNC_CTS_FLOW" added to tty tree
Date: Tue, 23 Sep 2014 21:20:30 -0700
Message-ID: <14115324303606@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
To: peter@hurleysoftware.com, gregkh@linuxfoundation.org,
	isdn@linux-pingi.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:41893 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751875AbaIXHy5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 03:54:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is a note to let you know that I've just added the patch titled

    isdn: i4l: Remove ASYNC_CTS_FLOW

to my tty git tree which can be found at
    git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/tty.git
in the tty-next branch.

The patch will show up in the next release of the linux-next tree
(usually sometime within the next 24 hours during the week.)

The patch will also be merged in the next major kernel release
during the merge window.

If you have any questions about this process, please let me know.


>From 317c1360200059a7a8a832294a58409c73b784bf Mon Sep 17 00:00:00 2001
From: Peter Hurley <peter@hurleysoftware.com>
Date: Wed, 10 Sep 2014 15:06:25 -0400
Subject: isdn: i4l: Remove ASYNC_CTS_FLOW

ISDN4Linux always enables CTS flow control and does not use the
tty_port_cts_enabled() helper function; remove ASYNC_CTS_FLOW
state enable/disable.

cc: Karsten Keil <isdn@linux-pingi.de>
cc: <netdev@vger.kernel.org>
Signed-off-by: Peter Hurley <peter@hurleysoftware.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 drivers/isdn/i4l/isdn_tty.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/isdn/i4l/isdn_tty.c b/drivers/isdn/i4l/isdn_tty.c
index 3c5f2491a16f..bc912611fe09 100644
--- a/drivers/isdn/i4l/isdn_tty.c
+++ b/drivers/isdn/i4l/isdn_tty.c
@@ -1043,11 +1043,6 @@ isdn_tty_change_speed(modem_info *info)
 	if (!(cflag & PARODD))
 		cval |= UART_LCR_EPAR;
 
-	/* CTS flow control flag and modem status interrupts */
-	if (cflag & CRTSCTS) {
-		port->flags |= ASYNC_CTS_FLOW;
-	} else
-		port->flags &= ~ASYNC_CTS_FLOW;
 	if (cflag & CLOCAL)
 		port->flags &= ~ASYNC_CHECK_CD;
 	else {
-- 
2.1.0
