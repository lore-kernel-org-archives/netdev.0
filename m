From: akpm@linux-foundation.org
Subject: [patch for 2.6.32? 1/2] hso: fix debug routines
Date: Tue, 17 Nov 2009 14:50:31 -0800
Message-ID: <200911172250.nAHMoVWa013146@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	antti.kaijanmaki@nomovok.com, greg@kroah.com,
	randy.dunlap@oracle.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:56118 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756566AbZKQWu5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 17:50:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Antti Kaijanm=E4ki <antti.kaijanmaki@nomovok.com>

Signed-off-by: Antti Kaijanm=E4ki <antti.kaijanmaki@nomovok.com>
Cc: Greg KH <greg@kroah.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Randy Dunlap <randy.dunlap@oracle.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/usb/hso.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/net/usb/hso.c~hso-fix-debug-routines drivers/net/usb/=
hso.c
--- a/drivers/net/usb/hso.c~hso-fix-debug-routines
+++ a/drivers/net/usb/hso.c
@@ -378,7 +378,7 @@ static void dbg_dump(int line_count, con
 }
=20
 #define DUMP(buf_, len_)	\
-	dbg_dump(__LINE__, __func__, buf_, len_)
+	dbg_dump(__LINE__, __func__, (unsigned char *)buf_, len_)
=20
 #define DUMP1(buf_, len_)			\
 	do {					\
@@ -1527,7 +1527,7 @@ static void tiocmget_intr_callback(struc
 		dev_warn(&usb->dev,
 			 "hso received invalid serial state notification\n");
 		DUMP(serial_state_notification,
-		     sizeof(hso_serial_state_notifation))
+		     sizeof(struct hso_serial_state_notification));
 	} else {
=20
 		UART_state_bitmap =3D le16_to_cpu(serial_state_notification->
_
